package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/charmbracelet/bubbletea"
	"github.com/pradeep/nix-tui/internal/app"
	"github.com/pradeep/nix-tui/internal/logging"
	"github.com/pradeep/nix-tui/internal/output"
)

func main() {
	logging.Init()

	m := app.New()
	// Render TUI to stderr so stdout stays clean for JSON output
	p := tea.NewProgram(m, tea.WithAltScreen(), tea.WithOutput(os.Stderr))

	finalModel, err := p.Run()
	if err != nil {
		logging.Error("app", fmt.Sprintf("TUI error: %v", err))
		result := output.Result{Action: "error", Error: err.Error()}
		data, _ := json.Marshal(result)
		fmt.Println(string(data))
		os.Exit(1)
	}

	// Output result for shell wrapper
	model := finalModel.(app.Model)
	if model.Result != nil {
		data, _ := json.Marshal(model.Result)
		fmt.Println(string(data))
	}
}
