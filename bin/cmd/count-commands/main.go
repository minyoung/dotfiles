// count-commands logs shell command start/end events (called from
// .zshrc's preexec/precmd hooks) into the commands sqlite db.
package main

import (
	"fmt"
	"os"
	"time"

	"dotfiles-bin/internal/commandlog"
)

func now() float64 {
	return float64(time.Now().UnixNano()) / 1e9
}

func printError(err error) {
	fmt.Printf("%s!!%s %s %s!!%s\n",
		commandlog.ColorRed, commandlog.ColorReset, err, commandlog.ColorRed, commandlog.ColorReset)
}

func printCommandInfo(timestamp float64, userCommand string) {
	cwd, _ := os.Getwd()
	date := time.Unix(int64(timestamp), 0).Local().Format("2006-01-02 15:04:05 MST")
	commandlog.PrintBox(fmt.Sprintf("%s%s %s@ %s%s%s\n%s",
		commandlog.ColorCyan, cwd, commandlog.ColorReset,
		commandlog.ColorYellow, date, commandlog.ColorReset,
		userCommand), commandlog.ColorGray)
}

func initDB() {
	db, err := commandlog.GetDB()
	if err != nil {
		printError(err)
		os.Exit(1)
	}
	defer db.Close()

	if err := commandlog.CreateCommandTable(db); err != nil {
		printError(err)
		os.Exit(1)
	}
}

func logCommand(args []string) {
	if len(args) < 4 {
		fmt.Fprintln(os.Stderr, "usage: count-commands log_command UUID USER_STRING ALIAS_EXPANSION EXPANDED_STRING")
		os.Exit(1)
	}
	uuid, userString, expandedString := args[0], args[1], args[3]
	timestamp := now()

	func() {
		db, err := commandlog.GetDB()
		if err != nil {
			printError(err)
			return
		}
		defer db.Close()

		if err := commandlog.InsertCommand(db, uuid, timestamp, userString, expandedString); err != nil {
			printError(err)
		}
	}()

	printCommandInfo(timestamp, expandedString)
}

func printCommandEndInfo(timestamp float64, row commandlog.CommandRow) {
	duration := timestamp - row.Timestamp
	if duration < 1 || duration > 43200 {
		return
	}

	ignoredCommands := map[string]bool{"vim": true, "man": true, "less": true, "tmux": true, "nvim": true}
	if ignoredCommands[row.Command] {
		return
	}

	ignoredUserStrings := []string{"g d", "g show", "g log"}
	normalized := commandlog.NormalizeUserString(row.UserString)
	for _, prefix := range ignoredUserStrings {
		if len(normalized) >= len(prefix) && normalized[:len(prefix)] == prefix {
			return
		}
	}

	elapsedColor := commandlog.ColorGreen
	if duration > 3600 {
		elapsedColor = commandlog.ColorRed
	} else if duration > 60 {
		elapsedColor = commandlog.ColorLightRed
	}

	cwd, _ := os.Getwd()
	start := time.Unix(int64(row.Timestamp), 0).Local().Format("2006-01-02 15:04:05 MST")
	end := time.Unix(int64(timestamp), 0).Local().Format("2006-01-02 15:04:05 MST")

	commandlog.PrintBox(fmt.Sprintf("%s%s\n%s%s %s~ %s%s\n%sElapsed: %s\n\n%s%s",
		commandlog.ColorCyan, cwd,
		commandlog.ColorYellow, start, commandlog.ColorRed, commandlog.ColorYellow, end,
		elapsedColor, commandlog.FormatDuration(duration),
		commandlog.ColorReset, row.ExpandedString), commandlog.ColorGray)
}

func logCommandEnd(args []string) {
	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "usage: count-commands log_command_end UUID")
		os.Exit(1)
	}
	uuid := args[0]
	timestamp := now()

	db, err := commandlog.GetDB()
	if err != nil {
		printError(err)
		return
	}
	defer db.Close()

	row, err := commandlog.UpdateCommandEnd(db, uuid, timestamp)
	if err != nil {
		printError(err)
		return
	}
	printCommandEndInfo(timestamp, row)
}

func main() {
	if os.Getenv("KILL_COMMAND_LOGGING") != "" {
		return
	}
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: count-commands {log_command|log_command_end} ...")
		os.Exit(1)
	}

	action := os.Args[1]
	args := os.Args[2:]
	switch action {
	case "init":
		initDB()
	case "log_command":
		logCommand(args)
	case "log_command_end":
		logCommandEnd(args)
	default:
		fmt.Printf("Unknown count-commands action: %s\n", action)
	}
}
