// top-commands reports the most-used shell commands (or, given a
// command name, its most common invocations) from the commands db
// logged by count-commands.
package main

import (
	"database/sql"
	"fmt"
	"os"
	"sort"
	"strings"
	"time"

	"dotfiles-bin/internal/commandlog"

	_ "modernc.org/sqlite"
)

// six 4-week "months" back, matching the Python original.
var sinceTimestamp = time.Now().Unix() - 60*60*24*7*4*6

func printTableHeader(cols ...string) {
	widths := make([]int, len(cols))
	total := 0
	for i, c := range cols {
		widths[i] = len(c)
		total += widths[i]
	}
	fmt.Println(strings.Join(cols, "  "))
	fmt.Println(strings.Repeat("-", total+2*(len(cols)-1)))
}

func top(db *sql.DB) error {
	var total int
	if err := db.QueryRow(`SELECT count(*) FROM commands WHERE timestamp > ?`, sinceTimestamp).Scan(&total); err != nil {
		return err
	}
	if total == 0 {
		fmt.Println("No commands logged in the selected window.")
		return nil
	}
	percentage := 100 / float64(total)

	rows, err := db.Query(`
		SELECT count(*) AS counts, command
		FROM commands
		WHERE timestamp > ?
		GROUP BY command
		ORDER BY counts DESC
		LIMIT 20`, sinceTimestamp)
	if err != nil {
		return err
	}
	defer rows.Close()

	printTableHeader("count", "     %", "command")
	for rows.Next() {
		var count int
		var command string
		if err := rows.Scan(&count, &command); err != nil {
			return err
		}
		fmt.Printf("%5d %6.2f%% %s\n", count, float64(count)*percentage, command)
	}
	return rows.Err()
}

func sub(db *sql.DB, command string, filters []string) error {
	userFilter := strings.Join(append([]string{command}, filters...), " ")

	rows, err := db.Query(`
		SELECT user_string
		FROM commands
		WHERE timestamp > ? AND command = ?`, sinceTimestamp, command)
	if err != nil {
		return err
	}
	defer rows.Close()

	counts := map[string]int{}
	total := 0
	for rows.Next() {
		var userString string
		if err := rows.Scan(&userString); err != nil {
			return err
		}
		normalized := commandlog.NormalizeUserString(userString)
		if strings.HasPrefix(normalized, userFilter) {
			counts[normalized]++
			total++
		}
	}
	if err := rows.Err(); err != nil {
		return err
	}
	if total == 0 {
		fmt.Println("No matching commands logged in the selected window.")
		return nil
	}
	percentage := 100 / float64(total)

	type entry struct {
		key   string
		count int
	}
	entries := make([]entry, 0, len(counts))
	for k, v := range counts {
		entries = append(entries, entry{k, v})
	}
	sort.Slice(entries, func(i, j int) bool {
		if entries[i].count != entries[j].count {
			return entries[i].count > entries[j].count
		}
		return entries[i].key > entries[j].key
	})
	if len(entries) > 20 {
		entries = entries[:20]
	}

	printTableHeader("count", "     %", "command")
	for _, e := range entries {
		fmt.Printf("%5d %6.2f%% %s\n", e.count, float64(e.count)*percentage, e.key)
	}
	return nil
}

func main() {
	args := os.Args[1:]

	dbPath := commandlog.DBPath()
	if _, err := os.Stat(dbPath); err != nil {
		fmt.Printf("Commands database does not exist: %s\n", dbPath)
		os.Exit(1)
	}

	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	defer db.Close()

	if len(args) == 0 {
		err = top(db)
	} else {
		err = sub(db, args[0], args[1:])
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
