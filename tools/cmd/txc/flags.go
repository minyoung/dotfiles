package main

import (
	"fmt"
	"strings"
)

// flagSpec describes one flag a subcommand accepts. names lists every spelling
// that selects it, each with its leading dashes ("-n", "--namespace"); the
// spelling actually used is echoed back in error messages. Exactly one of
// strVal / boolVal is set: a strVal flag consumes "--name value" or
// "--name=value"; a boolVal flag is set true by its presence alone.
type flagSpec struct {
	names   []string
	strVal  *string
	boolVal *bool
}

// strFlag defines a value flag writing into dst, e.g.
// strFlag(&o.namespace, "-n", "--namespace").
func strFlag(dst *string, names ...string) flagSpec {
	return flagSpec{names: names, strVal: dst}
}

// boolFlag defines a presence flag writing true into dst.
func boolFlag(dst *bool, names ...string) flagSpec {
	return flagSpec{names: names, boolVal: dst}
}

// parseFlags walks args against specs, assigning recognised flags to their
// destinations. Every non-flag argument is returned in rest, in the order
// seen; help is true as soon as -h or --help appears.
//
// Flags and non-flags may be interleaved freely. "--" stops flag parsing:
// everything after it is copied into rest verbatim. A bare "-" is a non-flag
// (it lands in rest). An argument that looks like a flag but matches no spec
// is copied into rest when keepUnknown is set, and is an error otherwise;
// keepUnknown is how the snowflake command forwards "snow"'s own flags
// untouched.
func parseFlags(args []string, keepUnknown bool, specs ...flagSpec) (rest []string, help bool, err error) {
	byName := make(map[string]flagSpec)
	for _, s := range specs {
		for _, n := range s.names {
			byName[n] = s
		}
	}

	for i := 0; i < len(args); i++ {
		a := args[i]

		switch {
		case a == "--":
			return append(rest, args[i+1:]...), false, nil
		case a == "-h" || a == "--help":
			return nil, true, nil
		case a == "-" || !strings.HasPrefix(a, "-"):
			rest = append(rest, a)
			continue
		}

		name, val, hasVal := strings.Cut(a, "=")

		s, ok := byName[name]
		if !ok {
			if keepUnknown {
				rest = append(rest, a)
				continue
			}
			return nil, false, fmt.Errorf("unknown flag %q", name)
		}

		switch {
		case s.boolVal != nil:
			if hasVal {
				return nil, false, fmt.Errorf("%s takes no value", name)
			}
			*s.boolVal = true
		case hasVal:
			*s.strVal = val
		case i+1 >= len(args):
			return nil, false, fmt.Errorf("missing value for %s", name)
		default:
			i++
			*s.strVal = args[i]
		}
	}
	return rest, false, nil
}
