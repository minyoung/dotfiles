package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"os/exec"
	"strings"
	"unicode/utf8"

	"gopkg.in/yaml.v3"
)

const k8ssecretUsage = "usage: txc k8ssecret [-o yaml|json] <secret-name> [kubectl flags...]\n" +
	"\n" +
	"Every argument except -o/--output is forwarded to `kubectl get secret`,\n" +
	"so -n, --context, --field-selector, label selectors, etc. all work."

// k8ssecret runs `kubectl get secret ... -o json` and returns the result with
// every value under `data` base64-decoded. Output defaults to YAML; pass
// -o/--output json for JSON. All other arguments are passed straight through to
// kubectl, which handles namespace, context, and selector flags as usual.
func k8ssecret(args []string) (string, error) {
	output, passthrough, help, err := parseK8sSecretArgs(args)
	if err != nil {
		return "", err
	}
	if help {
		return k8ssecretUsage, nil
	}

	raw, err := kubectlGetSecret(passthrough)
	if err != nil {
		return "", err
	}
	return decodeSecret(raw, output)
}

// parseK8sSecretArgs pulls out -o/--output (txc's own render format) and
// returns everything else untouched for kubectl.
func parseK8sSecretArgs(args []string) (output string, passthrough []string, help bool, err error) {
	output = "yaml"
	passthrough, help, err = parseFlags(args, true, strFlag(&output, "-o", "--output"))
	return output, passthrough, help, err
}

// kubectlGetSecret shells out to `kubectl get secret <args...> -o json` and
// returns the raw JSON.
func kubectlGetSecret(args []string) ([]byte, error) {
	kargs := append([]string{"get", "secret", "-o", "json"}, args...)

	cmd := exec.Command("kubectl", kargs...)
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	out, err := cmd.Output()
	if err != nil {
		if msg := strings.TrimSpace(stderr.String()); msg != "" {
			return nil, fmt.Errorf("%s", msg)
		}
		return nil, fmt.Errorf("kubectl: %w", err)
	}
	return out, nil
}

// decodeSecret takes kubectl's JSON (a single Secret or a SecretList),
// base64-decodes each entry under `data`, and re-renders it as YAML (default)
// or pretty JSON. A decoded value that is not valid UTF-8 is left as its
// original base64 string.
func decodeSecret(raw []byte, output string) (string, error) {
	var obj map[string]any
	if err := json.Unmarshal(raw, &obj); err != nil {
		return "", fmt.Errorf("parsing kubectl output: %w", err)
	}

	if items, ok := obj["items"].([]any); ok {
		for _, it := range items {
			if m, ok := it.(map[string]any); ok {
				if err := decodeDataBlock(m); err != nil {
					return "", err
				}
			}
		}
	} else if err := decodeDataBlock(obj); err != nil {
		return "", err
	}

	switch output {
	case "yaml", "yml":
		var b bytes.Buffer
		enc := yaml.NewEncoder(&b)
		enc.SetIndent(2)
		if err := enc.Encode(obj); err != nil {
			return "", err
		}
		return strings.TrimRight(b.String(), "\n"), nil
	case "json":
		b, err := json.MarshalIndent(obj, "", "  ")
		if err != nil {
			return "", err
		}
		return string(b), nil
	default:
		return "", fmt.Errorf("unknown output format %q (want yaml or json)", output)
	}
}

// decodeDataBlock base64-decodes the string values under obj["data"] in place.
func decodeDataBlock(obj map[string]any) error {
	data, ok := obj["data"].(map[string]any)
	if !ok {
		return nil
	}
	for k, v := range data {
		s, ok := v.(string)
		if !ok {
			continue
		}
		dec, err := base64.StdEncoding.DecodeString(s)
		if err != nil {
			return fmt.Errorf("data[%q]: %w", k, err)
		}
		if utf8.Valid(dec) {
			data[k] = string(dec)
		}
	}
	return nil
}
