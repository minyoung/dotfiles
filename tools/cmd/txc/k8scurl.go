package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"
)

const k8scurlUsage = `usage: txc k8scurl [flags] TARGET PATH

TARGET is svc/NAME (the default when no prefix is given), deploy/NAME, or
pod/NAME. PATH is the request path, e.g. /healthz or /metrics?verbose=1.

k8scurl runs "kubectl port-forward" to a local port, makes the HTTP request
against it, prints the response body, and tears the forward down.

flags:
  -n, --namespace NS    namespace (default: the current context's namespace)
      --context CTX      kubeconfig context
  -p, --port PORT        service or container port, by name or number; required
                         only when the target exposes more than one
  -X, --request METHOD   HTTP method (default GET, or POST when -d is given)
  -d, --data DATA        request body; @file reads a file, @- reads stdin
  -f, --fail             exit non-zero and print nothing on HTTP status >= 400
  -m, --max-time DUR     overall timeout (default 30s; e.g. 5s, 2m)

The global -v/--verbose flag (or TXC_DEBUG=1) traces each step to stderr.`

type k8scurlOpts struct {
	namespace string
	context   string
	port      string
	method    string
	data      string
	target    string
	path      string
	timeout   string
	fail      bool
}

// defaultK8scurlTimeout bounds the whole operation so a stuck port-forward or a
// hung endpoint fails loudly instead of hanging forever. Override with -m.
const defaultK8scurlTimeout = "30s"

// k8scurl port-forwards to an in-cluster Service, Deployment, or Pod and makes
// a single HTTP request against the forwarded local port. It resolves the
// remote port from the target's spec (unless -p is given), lets kubectl pick a
// free local port, and returns the response body.
func k8scurl(args []string) (string, error) {
	o, help, err := parseK8scurlArgs(args)
	if err != nil {
		return "", err
	}
	if help {
		return k8scurlUsage, nil
	}
	debugf("parsed: target=%q path=%q method=%s namespace=%q context=%q port=%q data=%dB timeout=%s",
		o.target, o.path, o.method, o.namespace, o.context, o.port, len(o.data), o.timeout)

	deadline, err := time.ParseDuration(o.timeout)
	if err != nil {
		return "", fmt.Errorf("bad -m/--max-time %q: %w", o.timeout, err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), deadline)
	defer cancel()

	ns := o.namespace
	if ns == "" {
		debugf("no -n given; asking kubectl for the current context namespace")
		ns, err = currentNamespace(o.getArgs())
		if err != nil {
			return "", err
		}
	}
	debugf("namespace=%s", ns)

	getArgs := append(o.getArgs(), "-n", ns)
	kind, name := splitTarget(o.target)

	debugf("resolving remote port for %s/%s", kind, name)
	remotePort, err := resolveRemotePort(getArgs, kind, name, o.port)
	if err != nil {
		return "", err
	}
	debugf("remote port=%s", remotePort)

	fwdArgs := append(o.forwardArgs(), "-n", ns)
	localPort, stop, err := portForward(ctx, fwdArgs, kind+"/"+name, remotePort)
	if err != nil {
		return "", err
	}
	defer stop()
	debugf("forwarding 127.0.0.1:%d -> %s/%s:%s", localPort, kind, name, remotePort)

	status, body, err := doHTTP(ctx, localPort, o.method, o.path, o.data)
	if err != nil {
		return "", err
	}
	debugf("HTTP %d, %d bytes", status, len(body))

	if o.fail && status >= 400 {
		return "", fmt.Errorf("HTTP %d", status)
	}
	return strings.TrimRight(body, "\n"), nil
}

// getArgs are the kubectl flags for the read-only `get`/`config` calls that
// resolve the namespace and port.
func (o *k8scurlOpts) getArgs() []string {
	a := o.forwardArgs()
	if o.timeout != "" {
		a = append(a, "--request-timeout="+o.timeout)
	}
	return a
}

// forwardArgs are the kubectl flags safe to pass to `port-forward` (no
// --request-timeout, which would cut the forward off mid-request).
func (o *k8scurlOpts) forwardArgs() []string {
	var a []string
	if o.context != "" {
		a = append(a, "--context", o.context)
	}
	return a
}

// parseK8scurlArgs splits the argument list into txc's own flags and the two
// positionals (TARGET, PATH). The HTTP method defaults to GET, or POST when a
// body is supplied without an explicit -X.
func parseK8scurlArgs(args []string) (*k8scurlOpts, bool, error) {
	o := &k8scurlOpts{}

	pos, help, err := parseFlags(args, false,
		boolFlag(&o.fail, "-f", "--fail"),
		strFlag(&o.timeout, "-m", "--max-time", "--request-timeout"),
		strFlag(&o.namespace, "-n", "--namespace"),
		strFlag(&o.context, "--context"),
		strFlag(&o.port, "-p", "--port"),
		strFlag(&o.method, "-X", "--request"),
		strFlag(&o.data, "-d", "--data"),
	)
	if err != nil {
		return nil, false, err
	}
	if help {
		return nil, true, nil
	}

	switch {
	case len(pos) < 2:
		return nil, false, fmt.Errorf("need TARGET and PATH arguments (see -h)")
	case len(pos) > 2:
		return nil, false, fmt.Errorf("unexpected argument %q", pos[2])
	}
	o.target, o.path = pos[0], pos[1]

	if o.timeout == "" {
		o.timeout = defaultK8scurlTimeout
	}
	if o.method == "" {
		if o.data != "" {
			o.method = "POST"
		} else {
			o.method = "GET"
		}
	} else {
		o.method = strings.ToUpper(o.method)
	}
	return o, false, nil
}

// splitTarget parses a "kind/name" target, defaulting to a Service when the
// kind prefix is omitted, and normalises the kind to its plural form.
func splitTarget(t string) (kind, name string) {
	k, n, ok := strings.Cut(t, "/")
	if !ok {
		return "services", t
	}
	switch k {
	case "svc", "service", "services":
		return "services", n
	case "deploy", "deployment", "deployments":
		return "deployments", n
	case "po", "pod", "pods":
		return "pods", n
	default:
		return k, n
	}
}

// resolveRemotePort returns the port to forward to: the explicit -p value if
// given, otherwise the sole port declared on the target, otherwise an error
// naming the candidates.
func resolveRemotePort(getArgs []string, kind, name, explicit string) (string, error) {
	var singular string
	switch kind {
	case "services":
		singular = "service"
	case "deployments":
		singular = "deployment"
	case "pods":
		singular = "pod"
	default:
		return "", fmt.Errorf("unsupported target kind %q (use svc/, deploy/, or pod/)", kind)
	}

	obj, err := getJSON(getArgs, singular, name)
	if err != nil {
		return "", err
	}

	var choices []portChoice
	switch kind {
	case "services":
		choices = toPortChoices(dig(obj, "spec", "ports"))
	case "pods":
		choices = containerPortChoices(obj)
	case "deployments":
		choices = containerPortChoices(dig(obj, "spec", "template"))
	}
	return pickPort(singular+" "+name, choices, explicit)
}

// portChoice is one candidate port discovered on a Service or container.
type portChoice struct {
	name   string
	number int64
}

// ref is the token handed to kubectl port-forward. A numeric port is the most
// portable, so it wins over the name when both are known.
func (p portChoice) ref() string {
	if p.number > 0 {
		return strconv.FormatInt(p.number, 10)
	}
	return p.name
}

func (p portChoice) String() string {
	if p.name != "" && p.number > 0 {
		return fmt.Sprintf("%s (%d)", p.name, p.number)
	}
	if p.name != "" {
		return p.name
	}
	return strconv.FormatInt(p.number, 10)
}

// toPortChoices reads a list of Service `spec.ports` or container `ports`
// entries (`port` or `containerPort`, plus optional `name`).
func toPortChoices(raw any) []portChoice {
	list, _ := raw.([]any)
	var cs []portChoice
	for _, r := range list {
		m, ok := r.(map[string]any)
		if !ok {
			continue
		}
		var pc portChoice
		if s, ok := m["name"].(string); ok {
			pc.name = s
		}
		switch {
		case isNumber(m["port"]):
			pc.number = toInt64(m["port"])
		case isNumber(m["containerPort"]):
			pc.number = toInt64(m["containerPort"])
		}
		if pc.number == 0 && pc.name == "" {
			continue
		}
		cs = append(cs, pc)
	}
	return cs
}

// containerPortChoices collects every declared container port from a pod-like
// object (a Pod, or a Deployment's `spec.template`).
func containerPortChoices(podish any) []portChoice {
	containers, _ := dig(podish, "spec", "containers").([]any)
	var raw []any
	for _, c := range containers {
		m, ok := c.(map[string]any)
		if !ok {
			continue
		}
		if ps, ok := m["ports"].([]any); ok {
			raw = append(raw, ps...)
		}
	}
	return toPortChoices(raw)
}

// pickPort returns the explicit port if given, the sole discovered port if
// there is exactly one, or an error naming the candidates otherwise.
func pickPort(what string, choices []portChoice, explicit string) (string, error) {
	if explicit != "" {
		return explicit, nil
	}
	switch len(choices) {
	case 0:
		return "", fmt.Errorf("%s declares no ports; pass --port", what)
	case 1:
		return choices[0].ref(), nil
	default:
		names := make([]string, len(choices))
		for i, c := range choices {
			names[i] = c.String()
		}
		sort.Strings(names)
		return "", fmt.Errorf("%s exposes multiple ports (%s); pass --port", what, strings.Join(names, ", "))
	}
}

var forwardingLineRe = regexp.MustCompile(`127\.0\.0\.1:(\d+)`)

// portForward starts `kubectl port-forward <target> :<remotePort>` in the
// background, waits for it to report the local port it bound, and returns that
// port plus a stop func that kills the forward. It fails if the forward exits
// or the context is cancelled before it is ready.
func portForward(ctx context.Context, fwdArgs []string, target, remotePort string) (int, func(), error) {
	args := append([]string{}, fwdArgs...)
	args = append(args, "port-forward", target, ":"+remotePort)
	debugf("kubectl %s", strings.Join(args, " "))

	cmd := exec.CommandContext(ctx, "kubectl", args...)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return 0, nil, err
	}
	var stderr bytes.Buffer
	if verbose {
		cmd.Stderr = io.MultiWriter(&stderr, os.Stderr)
	} else {
		cmd.Stderr = &stderr
	}
	if err := cmd.Start(); err != nil {
		return 0, nil, fmt.Errorf("kubectl port-forward: %w", err)
	}
	stop := func() {
		_ = cmd.Process.Kill()
		_ = cmd.Wait()
	}

	type result struct {
		port int
		err  error
	}
	ready := make(chan result, 1)
	go func() {
		sc := bufio.NewScanner(stdout)
		for sc.Scan() {
			line := sc.Text()
			debugf("  port-forward: %s", line)
			if m := forwardingLineRe.FindStringSubmatch(line); m != nil {
				p, _ := strconv.Atoi(m[1])
				ready <- result{port: p}
				return
			}
		}
		msg := strings.TrimSpace(stderr.String())
		if msg == "" && sc.Err() != nil {
			msg = sc.Err().Error()
		}
		ready <- result{err: fmt.Errorf("port-forward exited before it was ready: %s", msg)}
	}()

	select {
	case <-ctx.Done():
		stop()
		return 0, nil, fmt.Errorf("port-forward: %w", ctx.Err())
	case r := <-ready:
		if r.err != nil {
			stop()
			return 0, nil, r.err
		}
		return r.port, stop, nil
	}
}

// doHTTP makes the request against the forwarded local port and returns the
// status code and response body.
func doHTTP(ctx context.Context, localPort int, method, path, data string) (int, string, error) {
	body, err := readData(data)
	if err != nil {
		return 0, "", err
	}

	u := fmt.Sprintf("http://127.0.0.1:%d/%s", localPort, strings.TrimLeft(path, "/"))
	var r io.Reader
	if body != "" {
		r = strings.NewReader(body)
	}
	req, err := http.NewRequestWithContext(ctx, method, u, r)
	if err != nil {
		return 0, "", err
	}
	debugf("%s %s", method, u)

	resp, err := (&http.Client{}).Do(req)
	if err != nil {
		return 0, "", err
	}
	defer func() { _ = resp.Body.Close() }()

	b, err := io.ReadAll(resp.Body)
	if err != nil {
		return resp.StatusCode, "", err
	}
	return resp.StatusCode, string(b), nil
}

// readData resolves a curl-style -d value: literal text, @file, or @- (stdin).
func readData(d string) (string, error) {
	switch {
	case d == "":
		return "", nil
	case d == "@-":
		b, err := io.ReadAll(os.Stdin)
		return string(b), err
	case strings.HasPrefix(d, "@"):
		b, err := os.ReadFile(d[1:])
		return string(b), err
	default:
		return d, nil
	}
}

// currentNamespace asks kubectl for the namespace of the active context,
// falling back to "default" when the context does not set one.
func currentNamespace(getArgs []string) (string, error) {
	args := append([]string{}, getArgs...)
	args = append(args, "config", "view", "--minify", "-o", "jsonpath={..namespace}")
	out, err := runKubectl(args)
	if err != nil {
		return "", err
	}
	if ns := strings.TrimSpace(string(out)); ns != "" {
		return ns, nil
	}
	return "default", nil
}

// getJSON runs `kubectl get <kind> <name> -o json` and decodes it.
func getJSON(getArgs []string, kind, name string) (map[string]any, error) {
	args := append([]string{}, getArgs...)
	args = append(args, "get", kind, name, "-o", "json")
	out, err := runKubectl(args)
	if err != nil {
		return nil, err
	}
	var m map[string]any
	if err := json.Unmarshal(out, &m); err != nil {
		return nil, fmt.Errorf("parsing %s/%s: %w", kind, name, err)
	}
	return m, nil
}

// runKubectl executes kubectl and returns stdout. On failure it surfaces
// kubectl's own stderr message when there is one. In verbose mode it logs the
// command and its duration.
func runKubectl(args []string) ([]byte, error) {
	debugf("kubectl %s", strings.Join(args, " "))

	cmd := exec.Command("kubectl", args...)
	var stderr bytes.Buffer
	if verbose {
		cmd.Stderr = io.MultiWriter(&stderr, os.Stderr)
	} else {
		cmd.Stderr = &stderr
	}

	start := time.Now()
	out, err := cmd.Output()
	debugf("  -> %s, %d bytes stdout, err=%v", time.Since(start).Round(time.Millisecond), len(out), err)

	if err != nil {
		if msg := strings.TrimSpace(stderr.String()); msg != "" {
			return nil, fmt.Errorf("%s", msg)
		}
		return nil, fmt.Errorf("kubectl: %w", err)
	}
	return out, nil
}

// dig walks nested map[string]any values, returning nil if any hop is missing
// or not a map.
func dig(m any, keys ...string) any {
	cur := m
	for _, k := range keys {
		mm, ok := cur.(map[string]any)
		if !ok {
			return nil
		}
		cur = mm[k]
	}
	return cur
}

func isNumber(v any) bool {
	switch v.(type) {
	case float64, json.Number:
		return true
	default:
		return false
	}
}

func toInt64(v any) int64 {
	switch n := v.(type) {
	case float64:
		return int64(n)
	case json.Number:
		i, _ := n.Int64()
		return i
	default:
		return 0
	}
}
