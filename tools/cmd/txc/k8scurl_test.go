package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strconv"
	"strings"
	"testing"
)

func TestParseK8scurlArgs(t *testing.T) {
	cases := []struct {
		name        string
		args        []string
		wantTarget  string
		wantPath    string
		wantNS      string
		wantContext string
		wantPort    string
		wantMethod  string
		wantData    string
	}{
		{
			name:       "minimal",
			args:       []string{"svc/api", "/healthz"},
			wantTarget: "svc/api", wantPath: "/healthz", wantMethod: "GET",
		},
		{
			name:       "flags separate",
			args:       []string{"-n", "prod", "--context", "kind-dev", "-p", "http", "deploy/api", "/metrics"},
			wantTarget: "deploy/api", wantPath: "/metrics", wantMethod: "GET",
			wantNS: "prod", wantContext: "kind-dev", wantPort: "http",
		},
		{
			name:       "flags equals",
			args:       []string{"--namespace=prod", "-p=8080", "--request=DELETE", "api", "/x"},
			wantTarget: "api", wantPath: "/x", wantNS: "prod", wantPort: "8080", wantMethod: "DELETE",
		},
		{
			name:       "data implies post",
			args:       []string{"svc/api", "/submit", "-d", `{"a":1}`},
			wantTarget: "svc/api", wantPath: "/submit", wantMethod: "POST", wantData: `{"a":1}`,
		},
		{
			name:       "explicit method with data",
			args:       []string{"svc/api", "/submit", "-d", "x", "-X", "put"},
			wantTarget: "svc/api", wantPath: "/submit", wantMethod: "PUT", wantData: "x",
		},
		{
			name:       "flags after positionals",
			args:       []string{"pod/api-abc", "/debug/pprof", "-n", "prod"},
			wantTarget: "pod/api-abc", wantPath: "/debug/pprof", wantNS: "prod", wantMethod: "GET",
		},
		{
			name:       "arbitrary method passes through uppercased",
			args:       []string{"svc/api", "/x", "-X", "patch"},
			wantTarget: "svc/api", wantPath: "/x", wantMethod: "PATCH",
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			o, help, err := parseK8scurlArgs(tc.args)
			if err != nil {
				t.Fatalf("err: %v", err)
			}
			if help {
				t.Fatal("unexpected help")
			}
			got := *o
			got.timeout = "" // asserted separately in TestParseK8scurlArgsTimeout
			want := k8scurlOpts{
				namespace: tc.wantNS, context: tc.wantContext, port: tc.wantPort,
				method: tc.wantMethod, data: tc.wantData,
				target: tc.wantTarget, path: tc.wantPath,
			}
			if got != want {
				t.Errorf("got  %+v\nwant %+v", got, want)
			}
		})
	}
}

func TestParseK8scurlArgsErrors(t *testing.T) {
	cases := [][]string{
		{"svc/api"},                  // missing PATH
		{"svc/api", "/x", "extra"},   // too many positionals
		{"svc/api", "/x", "-n"},      // dangling flag value
		{"--bogus", "svc/api", "/x"}, // unknown flag
	}
	for _, args := range cases {
		if _, _, err := parseK8scurlArgs(args); err == nil {
			t.Errorf("parseK8scurlArgs(%q): expected error", args)
		}
	}
}

func TestParseK8scurlArgsHelp(t *testing.T) {
	if _, help, _ := parseK8scurlArgs([]string{"-h"}); !help {
		t.Error("expected help for -h")
	}
}

func TestParseK8scurlArgsTimeout(t *testing.T) {
	o, _, err := parseK8scurlArgs([]string{"svc/api", "/x"})
	if err != nil || o.timeout != defaultK8scurlTimeout {
		t.Errorf("default timeout = %q (err %v), want %q", o.timeout, err, defaultK8scurlTimeout)
	}
	for _, args := range [][]string{
		{"-m", "5s", "svc/api", "/x"},
		{"--max-time=5s", "svc/api", "/x"},
		{"--request-timeout=5s", "svc/api", "/x"},
	} {
		o, _, err := parseK8scurlArgs(args)
		if err != nil || o.timeout != "5s" {
			t.Errorf("%q: timeout = %q (err %v), want 5s", args, o.timeout, err)
		}
	}
}

func TestK8scurlArgSplits(t *testing.T) {
	o := &k8scurlOpts{timeout: "5s", context: "kind-dev"}

	// Read-only kubectl calls carry the request timeout...
	if got := o.getArgs(); !reflect.DeepEqual(
		got, []string{"--context", "kind-dev", "--request-timeout=5s"}) {
		t.Errorf("getArgs = %q", got)
	}
	// ...but port-forward must not, or it would be cut off mid-request.
	if got := o.forwardArgs(); !reflect.DeepEqual(got, []string{"--context", "kind-dev"}) {
		t.Errorf("forwardArgs = %q", got)
	}
}

func TestParseK8scurlArgsFail(t *testing.T) {
	for _, args := range [][]string{
		{"-f", "svc/api", "/x"},
		{"svc/api", "/x", "--fail"},
	} {
		o, _, err := parseK8scurlArgs(args)
		if err != nil || !o.fail {
			t.Errorf("%q: fail = %v (err %v)", args, o.fail, err)
		}
	}
	if o, _, _ := parseK8scurlArgs([]string{"svc/api", "/x"}); o.fail {
		t.Error("fail should default to false")
	}
}

func TestSplitTarget(t *testing.T) {
	cases := []struct{ in, kind, name string }{
		{"api", "services", "api"},
		{"svc/api", "services", "api"},
		{"service/api", "services", "api"},
		{"deploy/api", "deployments", "api"},
		{"deployment/api", "deployments", "api"},
		{"po/api-abc", "pods", "api-abc"},
		{"pod/api-abc", "pods", "api-abc"},
		{"job/thing", "job", "thing"},
	}
	for _, tc := range cases {
		k, n := splitTarget(tc.in)
		if k != tc.kind || n != tc.name {
			t.Errorf("splitTarget(%q) = (%q, %q), want (%q, %q)", tc.in, k, n, tc.kind, tc.name)
		}
	}
}

func TestPickPort(t *testing.T) {
	one := []portChoice{{name: "http", number: 8080}}
	many := []portChoice{{name: "http", number: 8080}, {name: "grpc", number: 9090}}

	if got, err := pickPort("svc x", one, ""); err != nil || got != "8080" {
		t.Errorf("single port: got %q err %v", got, err)
	}
	if got, err := pickPort("svc x", many, "grpc"); err != nil || got != "grpc" {
		t.Errorf("explicit overrides: got %q err %v", got, err)
	}
	if _, err := pickPort("svc x", many, ""); err == nil {
		t.Error("ambiguous ports: expected error")
	}
	if _, err := pickPort("svc x", nil, ""); err == nil {
		t.Error("no ports: expected error")
	}
}

func TestToPortChoices(t *testing.T) {
	var svcPorts any
	if err := json.Unmarshal([]byte(`[{"name":"http","port":80,"targetPort":8080},{"port":443}]`), &svcPorts); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	got := toPortChoices(svcPorts)
	want := []portChoice{{name: "http", number: 80}, {number: 443}}
	if !reflect.DeepEqual(got, want) {
		t.Errorf("toPortChoices = %+v, want %+v", got, want)
	}
}

func TestContainerPortChoices(t *testing.T) {
	var tmpl any
	if err := json.Unmarshal([]byte(`{
		"spec": {"containers": [
			{"name": "app", "ports": [{"name": "http", "containerPort": 8080}]},
			{"name": "sidecar", "ports": [{"containerPort": 9090}]}
		]}
	}`), &tmpl); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	got := containerPortChoices(tmpl)
	want := []portChoice{{name: "http", number: 8080}, {number: 9090}}
	if !reflect.DeepEqual(got, want) {
		t.Errorf("containerPortChoices = %+v, want %+v", got, want)
	}
}

func TestDoHTTP(t *testing.T) {
	var gotMethod, gotPath, gotBody string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotMethod = r.Method
		gotPath = r.URL.RequestURI()
		b, _ := io.ReadAll(r.Body)
		gotBody = string(b)
		w.WriteHeader(503)
		_, _ = fmt.Fprint(w, "unhealthy\n")
	}))
	defer srv.Close()

	port, err := strconv.Atoi(strings.TrimPrefix(srv.URL, "http://127.0.0.1:"))
	if err != nil {
		t.Fatalf("test server port: %v", err)
	}

	status, body, err := doHTTP(context.Background(), port, "POST", "/submit?x=1", "payload")
	if err != nil {
		t.Fatalf("doHTTP: %v", err)
	}
	if status != 503 || body != "unhealthy\n" {
		t.Errorf("status=%d body=%q", status, body)
	}
	if gotMethod != "POST" || gotPath != "/submit?x=1" || gotBody != "payload" {
		t.Errorf("server saw method=%q path=%q body=%q", gotMethod, gotPath, gotBody)
	}
}

func TestReadData(t *testing.T) {
	if got, _ := readData(""); got != "" {
		t.Errorf("empty: %q", got)
	}
	if got, _ := readData("literal"); got != "literal" {
		t.Errorf("literal: %q", got)
	}
	if _, err := readData("@/no/such/file/here"); err == nil {
		t.Error("missing file: expected error")
	}
}

func TestDig(t *testing.T) {
	var obj any
	if err := json.Unmarshal([]byte(`{"spec":{"selector":{"matchLabels":{"app":"api"}}}}`), &obj); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	got, ok := dig(obj, "spec", "selector", "matchLabels").(map[string]any)
	if !ok || got["app"] != "api" {
		t.Errorf("dig matchLabels = %+v (ok=%v)", got, ok)
	}
	if dig(obj, "spec", "nope", "x") != nil {
		t.Error("missing hop should be nil")
	}
}
