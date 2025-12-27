package logging

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"time"
)

// LogEntry matches the shell/nvim JSON log schema
type LogEntry struct {
	Timestamp  string `json:"ts"`
	Level      string `json:"level"`
	Component  string `json:"component"`
	Message    string `json:"msg"`
	Source     string `json:"source"`
	Pid        int    `json:"pid"`
	DurationMs int    `json:"duration_ms,omitempty"`
	ExitCode   int    `json:"exit_code,omitempty"`
	Error      string `json:"error,omitempty"`
}

var (
	logFile    string
	jsonLog    bool
	debugLevel int
)

// Init initializes the logging system from environment variables
func Init() {
	// Default log file location
	stateHome := os.Getenv("XDG_STATE_HOME")
	if stateHome == "" {
		home := os.Getenv("HOME")
		stateHome = filepath.Join(home, ".local", "state")
	}
	logFile = filepath.Join(stateHome, "dotfiles", "logs", "dotfiles.jsonl")

	// Check if JSON logging is enabled
	jsonLog = os.Getenv("DOTFILES_JSON_LOG") == "1"

	// Debug level
	if d := os.Getenv("DEBUG_DOTFILES"); d != "" {
		debugLevel, _ = strconv.Atoi(d)
	}
}

func log(level, component, message string) {
	entry := LogEntry{
		Timestamp: time.Now().UTC().Format("2006-01-02T15:04:05.000Z"),
		Level:     level,
		Component: component,
		Message:   message,
		Source:    "go",
		Pid:       os.Getpid(),
	}

	if jsonLog {
		if data, err := json.Marshal(entry); err == nil {
			writeToFile(string(data))
		}
	}

	// Console output for DEBUG level when enabled
	if debugLevel > 0 && (level == "DEBUG" || level == "INFO") {
		fmt.Fprintf(os.Stderr, "[%s] %s: %s\n", level, component, message)
	}

	// Always show WARN and ERROR on stderr
	if level == "WARN" || level == "ERROR" {
		fmt.Fprintf(os.Stderr, "[%s] %s: %s\n", level, component, message)
	}
}

func writeToFile(line string) {
	if logFile == "" {
		return
	}

	// Ensure directory exists
	dir := filepath.Dir(logFile)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return
	}

	f, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return
	}
	defer f.Close()

	f.WriteString(line + "\n")
}

// Debug logs at DEBUG level
func Debug(component, message string) {
	if debugLevel > 0 {
		log("DEBUG", component, message)
	}
}

// Info logs at INFO level
func Info(component, message string) {
	log("INFO", component, message)
}

// Warn logs at WARN level
func Warn(component, message string) {
	log("WARN", component, message)
}

// Error logs at ERROR level
func Error(component, message string) {
	log("ERROR", component, message)
}

// Timed logs execution time of a function
func Timed(component, description string, fn func() error) error {
	start := time.Now()
	err := fn()
	duration := time.Since(start)

	entry := LogEntry{
		Timestamp:  time.Now().UTC().Format("2006-01-02T15:04:05.000Z"),
		Level:      "INFO",
		Component:  component,
		Message:    description,
		Source:     "go",
		Pid:        os.Getpid(),
		DurationMs: int(duration.Milliseconds()),
	}

	if err != nil {
		entry.Level = "ERROR"
		entry.Error = err.Error()
	}

	if jsonLog {
		if data, jsonErr := json.Marshal(entry); jsonErr == nil {
			writeToFile(string(data))
		}
	}

	return err
}
