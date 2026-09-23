package main

import (
	"fmt"
	"io"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

// command is a single txc subcommand. run receives the subcommand's raw
// argument list and returns the text to print.
//
// Most commands take a single string (from args or stdin); they wrap a
// func(string) (string, error) with inputCmd, which reads that string and
// hands it over. A command that needs its own flags parses args directly.
type command struct {
	name string
	help string
	run  func(args []string) (string, error)
}

// verbose turns on step-by-step tracing to stderr. It applies to every txc
// command and is set by a global -v/--verbose flag (stripped from the argument
// list before the subcommand parses it) or the TXC_DEBUG environment variable.
var verbose bool

// infof writes a line to stderr unconditionally. Use it for the handful of
// facts worth confirming on every run (what a command is about to act on);
// step-by-step detail belongs in debugf.
func infof(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "[txc] "+format+"\n", args...)
}

// debugf writes a trace line to stderr when verbose mode is on.
func debugf(format string, args ...any) {
	if !verbose {
		return
	}
	fmt.Fprintf(os.Stderr, "[txc] "+format+"\n", args...)
}

// stripVerbose removes every -v/--verbose entry from args, reporting whether at
// least one was present. The flag is global, so it is pulled out here rather
// than in each subcommand's own parser.
func stripVerbose(args []string) (rest []string, found bool) {
	rest = make([]string, 0, len(args))
	for _, a := range args {
		if a == "-v" || a == "--verbose" {
			found = true
			continue
		}
		rest = append(rest, a)
	}
	return rest, found
}

// inputCmd adapts a plain string-in/string-out command to command.run: it
// reads the single input string from args or stdin (see readInput) and passes
// it to fn.
func inputCmd(fn func(input string) (string, error)) func(args []string) (string, error) {
	return func(args []string) (string, error) {
		in, err := readInput(args)
		if err != nil {
			return "", err
		}
		return fn(in)
	}
}

// commands holds every txc subcommand. The built-ins are listed here; a
// machine-local drop-in file (*_local.go, git-ignored) can add its own from an
// init() via register, so the repo stays unaware of machine-specific commands.
var commands = []command{
	{
		name: "urlencode",
		help: "percent-encode a string for use in a URL query",
		run: inputCmd(func(in string) (string, error) {
			return url.QueryEscape(in), nil
		}),
	},
	{
		name: "urldecode",
		help: "decode a percent-encoded URL; split query params onto indented lines",
		run:  inputCmd(urldecode),
	},
	{
		name: "fromunix",
		help: "format a unix timestamp (seconds) as local time, ISO 8601, and relative to now",
		run:  inputCmd(fromunix),
	},
	{
		name: "k8ssecret",
		help: "kubectl-get a Secret with its data base64-decoded (-o yaml|json; other flags pass to kubectl)",
		run:  k8ssecret,
	},
	{
		name: "k8scurl",
		help: "HTTP request to an in-cluster Service/Deployment/Pod via kubectl port-forward (see -h)",
		run:  k8scurl,
	},
}

// urldecode percent-decodes its input. If the input contains a literal '?',
// it is treated as a URL: the query is split on '&' with each parameter placed
// on its own line, indented, prefixed by '?' (first) or '&' (rest). Each piece
// is decoded independently so an encoded '&' or '?' in a value is preserved.
func urldecode(in string) (string, error) {
	rawBase, query, hasQuery := strings.Cut(in, "?")
	if !hasQuery {
		return url.QueryUnescape(in)
	}

	base, err := url.QueryUnescape(rawBase)
	if err != nil {
		return "", err
	}

	if query == "" {
		return base + "\n  ?", nil
	}

	var b strings.Builder
	b.WriteString(base)
	for j, part := range strings.Split(query, "&") {
		val, err := url.QueryUnescape(part)
		if err != nil {
			return "", err
		}
		sep := byte('&')
		if j == 0 {
			sep = '?'
		}
		b.WriteString("\n  ")
		b.WriteByte(sep)
		b.WriteString(val)
	}
	return b.String(), nil
}

// now returns the current time. It is a variable so tests can pin it.
var now = time.Now

// fromunix parses a unix timestamp in seconds and renders it three ways:
// a readable line in the machine's local time zone, ISO 8601 (RFC 3339) with
// the local UTC offset, and how far it is from now in plain words.
func fromunix(in string) (string, error) {
	sec, err := strconv.ParseInt(strings.TrimSpace(in), 10, 64)
	if err != nil {
		return "", fmt.Errorf("not a unix timestamp: %q", strings.TrimSpace(in))
	}
	t := time.Unix(sec, 0).Local()
	return fmt.Sprintf(
		"Relative: %s\nLocal:    %s\nISO8601:  %s",
		relTime(now().Sub(t)),
		t.Format("Mon Jan _2 2006 15:04:05 MST"),
		t.Format(time.RFC3339),
	), nil
}

// relTime renders d, a signed offset from now (positive = in the past), in
// human terms: "5 minutes ago", "in 3 days", or "just now" for a sub-minute
// gap. Larger units use 7-day weeks, 30-day months, and 365-day years.
func relTime(d time.Duration) string {
	future := d < 0
	if future {
		d = -d
	}

	var val int64
	var unit string
	switch {
	case d < time.Minute:
		return "just now"
	case d < time.Hour:
		val, unit = int64(d/time.Minute), "minute"
	case d < 24*time.Hour:
		val, unit = int64(d/time.Hour), "hour"
	case d < 7*24*time.Hour:
		val, unit = int64(d/(24*time.Hour)), "day"
	case d < 30*24*time.Hour:
		val, unit = int64(d/(7*24*time.Hour)), "week"
	case d < 365*24*time.Hour:
		val, unit = int64(d/(30*24*time.Hour)), "month"
	default:
		val, unit = int64(d/(365*24*time.Hour)), "year"
	}
	if val != 1 {
		unit += "s"
	}

	if future {
		return fmt.Sprintf("in %d %s", val, unit)
	}
	return fmt.Sprintf("%d %s ago", val, unit)
}

func main() {
	args, gotVerbose := stripVerbose(os.Args[1:])
	if v := os.Getenv("TXC_DEBUG"); gotVerbose || (v != "" && v != "0") {
		verbose = true
	}

	if len(args) < 1 {
		usage(os.Stderr)
		os.Exit(2)
	}

	name := args[0]
	if name == "-h" || name == "--help" || name == "help" {
		usage(os.Stdout)
		return
	}

	var cmd *command
	for i := range commands {
		if commands[i].name == name {
			cmd = &commands[i]
			break
		}
	}
	if cmd == nil {
		fmt.Fprintf(os.Stderr, "txc: unknown command %q\n\n", name)
		usage(os.Stderr)
		os.Exit(2)
	}

	out, err := cmd.run(args[1:])
	if err != nil {
		fmt.Fprintf(os.Stderr, "txc %s: %v\n", cmd.name, err)
		os.Exit(1)
	}
	if out != "" {
		fmt.Println(out)
	}
}

// readInput returns the joined args, or stdin if no args were given.
// A single trailing newline from stdin is stripped.
func readInput(args []string) (string, error) {
	if len(args) > 0 {
		return strings.Join(args, " "), nil
	}
	b, err := io.ReadAll(os.Stdin)
	if err != nil {
		return "", err
	}
	s := string(b)
	s = strings.TrimSuffix(s, "\n")
	s = strings.TrimSuffix(s, "\r")
	return s, nil
}

func usage(w io.Writer) {
	_, _ = fmt.Fprintln(w, "usage: txc [-v] <command> [string]")
	_, _ = fmt.Fprintln(w, "")
	_, _ = fmt.Fprintln(w, "If [string] is omitted, input is read from stdin.")
	_, _ = fmt.Fprintln(w, "")
	_, _ = fmt.Fprintln(w, "global flags:")
	_, _ = fmt.Fprintln(w, "  -v, --verbose   trace each step to stderr (also: TXC_DEBUG=1)")
	_, _ = fmt.Fprintln(w, "")
	_, _ = fmt.Fprintln(w, "commands:")
	for _, c := range commands {
		_, _ = fmt.Fprintf(w, "  %-12s %s\n", c.name, c.help)
	}
}
