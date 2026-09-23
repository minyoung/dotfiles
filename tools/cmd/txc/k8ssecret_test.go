package main

import (
	"reflect"
	"strings"
	"testing"
)

const sampleSecret = `{
  "apiVersion": "v1",
  "kind": "Secret",
  "metadata": {"name": "superset-config", "namespace": "mw-superset"},
  "type": "Opaque",
  "data": {
    "SECRET_KEY": "c3VwZXItc2VjcmV0",
    "count": "MTIz"
  }
}`

func TestParseK8sSecretArgs(t *testing.T) {
	cases := []struct {
		name    string
		args    []string
		output  string
		through []string
	}{
		{"default", []string{"superset-config"}, "yaml", []string{"superset-config"}},
		{"n flag passes through", []string{"-n", "mw-superset", "superset-config"}, "yaml", []string{"-n", "mw-superset", "superset-config"}},
		{"o separate", []string{"-o", "json", "s"}, "json", []string{"s"}},
		{"output separate", []string{"--output", "json", "s"}, "json", []string{"s"}},
		{"o equals", []string{"-o=json", "s"}, "json", []string{"s"}},
		{"output equals", []string{"--output=json", "s"}, "json", []string{"s"}},
		{"o after positional and other flags", []string{"s", "--context", "kind-dev", "-o", "json"}, "json", []string{"s", "--context", "kind-dev"}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			out, through, help, err := parseK8sSecretArgs(tc.args)
			if err != nil {
				t.Fatalf("err: %v", err)
			}
			if help {
				t.Fatal("unexpected help")
			}
			if out != tc.output {
				t.Errorf("output = %q, want %q", out, tc.output)
			}
			if !reflect.DeepEqual(through, tc.through) {
				t.Errorf("passthrough = %#v, want %#v", through, tc.through)
			}
		})
	}
}

func TestParseK8sSecretArgsHelp(t *testing.T) {
	if _, _, help, _ := parseK8sSecretArgs([]string{"--help"}); !help {
		t.Error("expected help for --help")
	}
}

func TestParseK8sSecretArgsMissingValue(t *testing.T) {
	if _, _, _, err := parseK8sSecretArgs([]string{"s", "-o"}); err == nil {
		t.Error("expected error for dangling -o")
	}
}

func TestDecodeSecretYAML(t *testing.T) {
	got, err := decodeSecret([]byte(sampleSecret), "yaml")
	if err != nil {
		t.Fatalf("decodeSecret: %v", err)
	}
	for _, want := range []string{
		"SECRET_KEY: super-secret",
		"count: \"123\"",
		"namespace: mw-superset",
	} {
		if !strings.Contains(got, want) {
			t.Errorf("yaml output missing %q\ngot:\n%s", want, got)
		}
	}
}

func TestDecodeSecretJSON(t *testing.T) {
	got, err := decodeSecret([]byte(sampleSecret), "json")
	if err != nil {
		t.Fatalf("decodeSecret: %v", err)
	}
	for _, want := range []string{
		`"SECRET_KEY": "super-secret"`,
		`"count": "123"`,
	} {
		if !strings.Contains(got, want) {
			t.Errorf("json output missing %q\ngot:\n%s", want, got)
		}
	}
}

func TestDecodeSecretList(t *testing.T) {
	in := `{"apiVersion":"v1","kind":"SecretList","items":[
		{"metadata":{"name":"a"},"data":{"x":"YQ=="}},
		{"metadata":{"name":"b"},"data":{"zz":"Yg=="}}
	]}`
	got, err := decodeSecret([]byte(in), "yaml")
	if err != nil {
		t.Fatalf("decodeSecret: %v", err)
	}
	if !strings.Contains(got, "x: a") || !strings.Contains(got, "zz: b") {
		t.Errorf("list items not decoded:\n%s", got)
	}
}

func TestDecodeSecretInvalidBase64(t *testing.T) {
	in := `{"data": {"bad": "not base64!!"}}`
	if _, err := decodeSecret([]byte(in), "yaml"); err == nil {
		t.Error("expected error for invalid base64, got nil")
	}
}

func TestDecodeSecretUnknownFormat(t *testing.T) {
	if _, err := decodeSecret([]byte(sampleSecret), "toml"); err == nil {
		t.Error("expected error for unknown format, got nil")
	}
}

func TestDecodeSecretNoDataBlock(t *testing.T) {
	in := `{"apiVersion": "v1", "kind": "Secret", "metadata": {"name": "x"}}`
	got, err := decodeSecret([]byte(in), "yaml")
	if err != nil {
		t.Fatalf("decodeSecret: %v", err)
	}
	if !strings.Contains(got, "name: x") {
		t.Errorf("unexpected output:\n%s", got)
	}
}
