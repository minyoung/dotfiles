// Package commandlog holds the shared bits between count-commands and
// top-commands: where the sqlite db lives, how to open it, and the
// ANSI color / box-drawing helpers used to print command info.
package commandlog

import (
	"database/sql"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	_ "modernc.org/sqlite"
)

const (
	ColorReset    = "\033[0m"
	ColorRed      = "\033[31m"
	ColorLightRed = "\033[91m"
	ColorGreen    = "\033[92m"
	ColorYellow   = "\033[93m"
	ColorGray     = "\033[37m"
	ColorCyan     = "\033[96m"
)

// DBPath returns ~/bin/Data/count-commands/commands.sqlite3.
func DBPath() string {
	home, err := os.UserHomeDir()
	if err != nil {
		home = os.Getenv("HOME")
	}
	return filepath.Join(home, "bin", "Data", "count-commands", "commands.sqlite3")
}

// FormatDuration renders a duration in seconds as e.g. "1h 2m 3.45s".
func FormatDuration(duration float64) string {
	var b strings.Builder
	if duration > 3600 {
		b.WriteString(fmt.Sprintf("%dh ", int(duration/3600)))
		duration = math.Mod(duration, 3600)
	}
	if duration > 60 {
		b.WriteString(fmt.Sprintf("%dm ", int(duration/60)))
		duration = math.Mod(duration, 60)
	}
	b.WriteString(fmt.Sprintf("%.2fs", duration))
	return b.String()
}

// NormalizeUserString collapses runs of whitespace down to single spaces.
func NormalizeUserString(s string) string {
	return strings.Join(strings.Fields(s), " ")
}

var ansiEscape = regexp.MustCompile(`\033\[\d+m`)

// PrintBox prints text_block surrounded by a box drawn in color.
func PrintBox(textBlock string, color string) {
	lines := strings.Split(textBlock, "\n")
	cleaned := ansiEscape.ReplaceAllString(strings.ReplaceAll(textBlock, "\t", strings.Repeat(" ", 6)), "")
	cleanLines := strings.Split(cleaned, "\n")

	lineLength := 0
	for _, l := range cleanLines {
		if n := len([]rune(l)); n > lineLength {
			lineLength = n
		}
	}

	border := fmt.Sprintf("%s+-%s-+%s", color, strings.Repeat("-", lineLength), ColorReset)

	fmt.Println(border)
	for i, line := range lines {
		padding := strings.Repeat(" ", lineLength-len([]rune(cleanLines[i])))
		fmt.Printf("%s|%s %s%s %s|\n", color, ColorReset, line, padding, color)
	}
	fmt.Println(border)
}

// GetDB opens (creating the parent directory if needed) the commands db.
func GetDB() (*sql.DB, error) {
	dbPath := DBPath()
	if err := os.MkdirAll(filepath.Dir(dbPath), 0o755); err != nil {
		return nil, err
	}
	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		return nil, err
	}
	if _, err := db.Exec("PRAGMA busy_timeout = 300"); err != nil {
		db.Close()
		return nil, err
	}
	return db, nil
}

// CreateCommandTable ensures the commands table exist.
func CreateCommandTable(db *sql.DB) error {
	_, err := db.Exec(`
		CREATE TABLE IF NOT EXISTS commands (
			uuid TEXT,
			hostname TEXT,
			timestamp INTEGER,
			duration INTEGER DEFAULT -1,
			command TEXT,
			user_string TEXT,
			expanded_string TEXT,
			PRIMARY KEY(uuid))`)
	return err
}

// InsertCommand records the start of a command.
func InsertCommand(db *sql.DB, uuid string, timestamp float64, userString, expandedString string) error {
	fields := strings.Fields(userString)
	command := ""
	if len(fields) > 0 {
		command = fields[0]
	}
	hostname, err := os.Hostname()
	if err != nil {
		hostname = ""
	}
	_, err = db.Exec(`
		INSERT INTO commands
			(uuid, hostname, timestamp, command, user_string, expanded_string)
		VALUES (?, ?, ?, ?, ?, ?)`,
		uuid, hostname, timestamp, command, userString, expandedString)
	return err
}

// CommandRow mirrors a row from the commands table.
type CommandRow struct {
	Timestamp      float64
	Command        string
	UserString     string
	ExpandedString string
}

// UpdateCommandEnd sets duration on the row for uuid and returns the row
// as it was before the update (matching the Python implementation, which
// reads the row, then writes the duration derived from it).
func UpdateCommandEnd(db *sql.DB, uuid string, timestamp float64) (CommandRow, error) {
	var row CommandRow
	err := db.QueryRow(`
		UPDATE commands SET duration = ? - timestamp WHERE uuid = ?
		RETURNING timestamp, command, user_string, expanded_string`,
		timestamp, uuid,
	).Scan(&row.Timestamp, &row.Command, &row.UserString, &row.ExpandedString)
	return row, err
}
