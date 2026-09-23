package main

// register adds a subcommand to the txc command set. It is meant to be called
// from an init() function so that machine-local, git-ignored drop-in files
// (named *_local.go) can contribute a command without any change to committed
// code.
//
// Built-in commands are listed directly in the commands literal, which is
// fully initialised before any init() runs, so registered commands always
// sort after the built-ins in dispatch and in usage output.
func register(c command) {
	commands = append(commands, c)
}
