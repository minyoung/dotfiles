package main

import (
	"reflect"
	"testing"
	"time"
)

func getCmd(t *testing.T, name string) command {
	t.Helper()
	for _, c := range commands {
		if c.name == name {
			return c
		}
	}
	t.Fatalf("command %q not found", name)
	return command{}
}

// runStr invokes a command with a single string input, as if it were the sole
// command-line argument.
func runStr(c command, in string) (string, error) {
	return c.run([]string{in})
}

func TestURLEncodeDecode(t *testing.T) {
	enc := getCmd(t, "urlencode")
	dec := getCmd(t, "urldecode")

	cases := []struct{ in, encoded string }{
		{"foo bar", "foo+bar"},
		{"a+b & c=d", "a%2Bb+%26+c%3Dd"},
		{"plain", "plain"},
		{"日本語", "%E6%97%A5%E6%9C%AC%E8%AA%9E"},
	}

	for _, tc := range cases {
		got, err := runStr(enc, tc.in)
		if err != nil {
			t.Fatalf("encode(%q): %v", tc.in, err)
		}
		if got != tc.encoded {
			t.Errorf("encode(%q) = %q, want %q", tc.in, got, tc.encoded)
		}
		back, err := runStr(dec, got)
		if err != nil {
			t.Fatalf("decode(%q): %v", got, err)
		}
		if back != tc.in {
			t.Errorf("decode(%q) = %q, want %q", got, back, tc.in)
		}
	}
}

func TestURLDecodeFormatsQuery(t *testing.T) {
	dec := getCmd(t, "urldecode")

	cases := []struct{ in, want string }{
		{
			"https://www.example.org/?param=1&foo=bar",
			"https://www.example.org/\n  ?param=1\n  &foo=bar",
		},
		{
			"https://x/path?q=a%20b&r=a%26b",
			"https://x/path\n  ?q=a b\n  &r=a&b",
		},
		{
			"https://x/?only=1",
			"https://x/\n  ?only=1",
		},
		// No literal '?': behaves like a plain decode.
		{"foo%20bar%3Fbaz", "foo bar?baz"},
	}

	for _, tc := range cases {
		got, err := runStr(dec, tc.in)
		if err != nil {
			t.Fatalf("decode(%q): %v", tc.in, err)
		}
		if got != tc.want {
			t.Errorf("decode(%q) =\n%q\nwant\n%q", tc.in, got, tc.want)
		}
	}
}

func TestURLDecodeError(t *testing.T) {
	dec := getCmd(t, "urldecode")
	if _, err := runStr(dec, "bad%zz"); err == nil {
		t.Error("expected error for invalid escape, got nil")
	}
}

func TestFromUnix(t *testing.T) {
	orig := time.Local
	time.Local = time.FixedZone("TST", -7*3600)
	defer func() { time.Local = orig }()

	origNow := now
	now = func() time.Time { return time.Unix(1000000000+5*86400, 0) }
	defer func() { now = origNow }()

	cmd := getCmd(t, "fromunix")

	got, err := runStr(cmd, "1000000000")
	if err != nil {
		t.Fatalf("fromunix: %v", err)
	}
	want := "Relative: 5 days ago\n" +
		"Local:    Sat Sep  8 2001 18:46:40 TST\n" +
		"ISO8601:  2001-09-08T18:46:40-07:00"
	if got != want {
		t.Errorf("fromunix(1000000000) =\n%q\nwant\n%q", got, want)
	}

	if _, err := runStr(cmd, "not-a-number"); err == nil {
		t.Error("expected error for non-numeric input, got nil")
	}
}

func TestRelTime(t *testing.T) {
	cases := []struct {
		d    time.Duration
		want string
	}{
		{30 * time.Second, "just now"},
		{-30 * time.Second, "just now"},
		{1 * time.Minute, "1 minute ago"},
		{5 * time.Minute, "5 minutes ago"},
		{-90 * time.Minute, "in 1 hour"},
		{25 * time.Hour, "1 day ago"},
		{10 * 24 * time.Hour, "1 week ago"},
		{45 * 24 * time.Hour, "1 month ago"},
		{-800 * 24 * time.Hour, "in 2 years"},
	}
	for _, tc := range cases {
		if got := relTime(tc.d); got != tc.want {
			t.Errorf("relTime(%v) = %q, want %q", tc.d, got, tc.want)
		}
	}
}

func TestStripVerbose(t *testing.T) {
	cases := []struct {
		args      []string
		want      []string
		wantFound bool
	}{
		{[]string{"k8scurl", "svc/api", "/x"}, []string{"k8scurl", "svc/api", "/x"}, false},
		{[]string{"-v", "k8scurl", "svc/api", "/x"}, []string{"k8scurl", "svc/api", "/x"}, true},
		{[]string{"k8scurl", "-v", "svc/api", "/x"}, []string{"k8scurl", "svc/api", "/x"}, true},
		{[]string{"k8scurl", "svc/api", "/x", "--verbose"}, []string{"k8scurl", "svc/api", "/x"}, true},
		{[]string{"--verbose", "-v", "urlencode", "hi"}, []string{"urlencode", "hi"}, true},
	}
	for _, tc := range cases {
		got, found := stripVerbose(tc.args)
		if found != tc.wantFound || !reflect.DeepEqual(got, tc.want) {
			t.Errorf("stripVerbose(%q) = (%q, %v), want (%q, %v)", tc.args, got, found, tc.want, tc.wantFound)
		}
	}
}

func TestReadInputJoinsArgs(t *testing.T) {
	got, err := readInput([]string{"foo", "bar"})
	if err != nil {
		t.Fatal(err)
	}
	if got != "foo bar" {
		t.Errorf("readInput = %q, want %q", got, "foo bar")
	}
}
