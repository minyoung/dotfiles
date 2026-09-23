package main

import (
	"reflect"
	"testing"
)

func TestParseFlags(t *testing.T) {
	type opts struct {
		ns, ctx, timeout string
		fail             bool
	}
	// specs rebuilds the spec list against a fresh opts each call, since the
	// specs close over pointers into it.
	specs := func(o *opts) []flagSpec {
		return []flagSpec{
			boolFlag(&o.fail, "-f", "--fail"),
			strFlag(&o.timeout, "-m", "--max-time", "--request-timeout"),
			strFlag(&o.ns, "-n", "--namespace"),
			strFlag(&o.ctx, "--context"),
		}
	}

	cases := []struct {
		name       string
		args       []string
		keepUnknwn bool
		want       opts
		wantRest   []string
	}{
		{"empty", nil, false, opts{}, nil},
		{"separate value", []string{"-n", "prod"}, false, opts{ns: "prod"}, nil},
		{"equals value", []string{"--namespace=prod"}, false, opts{ns: "prod"}, nil},
		{"short equals value", []string{"-n=prod"}, false, opts{ns: "prod"}, nil},
		{"bool by presence", []string{"--fail"}, false, opts{fail: true}, nil},
		{"alias to same dest", []string{"--request-timeout", "5s"}, false, opts{timeout: "5s"}, nil},
		{
			"interleaved with positionals",
			[]string{"a", "-n", "prod", "b", "--fail", "c"}, false,
			opts{ns: "prod", fail: true}, []string{"a", "b", "c"},
		},
		{
			"double dash stops parsing",
			[]string{"-n", "prod", "--", "-n", "lit", "--fail"}, false,
			opts{ns: "prod"}, []string{"-n", "lit", "--fail"},
		},
		{"bare dash is a positional", []string{"-"}, false, opts{}, []string{"-"}},
		{
			"keepUnknown forwards unknown flags in order",
			[]string{"-x", "-n", "prod", "-D", "k=v", "--other", "z"}, true,
			opts{ns: "prod"}, []string{"-x", "-D", "k=v", "--other", "z"},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			var got opts
			rest, help, err := parseFlags(tc.args, tc.keepUnknwn, specs(&got)...)
			if err != nil {
				t.Fatalf("err: %v", err)
			}
			if help {
				t.Fatal("unexpected help")
			}
			if got != tc.want {
				t.Errorf("opts = %+v, want %+v", got, tc.want)
			}
			if !reflect.DeepEqual(rest, tc.wantRest) {
				t.Errorf("rest = %#v, want %#v", rest, tc.wantRest)
			}
		})
	}
}

func TestParseFlagsHelp(t *testing.T) {
	var s string
	for _, args := range [][]string{{"-h"}, {"--help"}, {"-n", "x", "-h"}} {
		if _, help, err := parseFlags(args, false, strFlag(&s, "-n")); err != nil || !help {
			t.Errorf("%q: help = false (err %v)", args, err)
		}
	}
}

func TestParseFlagsErrors(t *testing.T) {
	var s string
	var b bool
	cases := []struct {
		name string
		args []string
	}{
		{"dangling value", []string{"-n"}},
		{"unknown flag without keepUnknown", []string{"--bogus"}},
		{"value given to bool flag", []string{"--fail=1"}},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			_, _, err := parseFlags(tc.args, false,
				strFlag(&s, "-n", "--namespace"),
				boolFlag(&b, "-f", "--fail"),
			)
			if err == nil {
				t.Errorf("%q: expected error", tc.args)
			}
		})
	}
}
