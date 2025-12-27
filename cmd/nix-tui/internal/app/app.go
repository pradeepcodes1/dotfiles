package app

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/charmbracelet/bubbles/spinner"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/pradeep/nix-tui/internal/flake"
	"github.com/pradeep/nix-tui/internal/home"
	"github.com/pradeep/nix-tui/internal/output"
	"github.com/pradeep/nix-tui/internal/profile"
)

// Colors
var (
	purple = lipgloss.Color("#b4befe")
	teal   = lipgloss.Color("#94e2d5")
	red    = lipgloss.Color("#f38ba8")
	yellow = lipgloss.Color("#f9e2af")
	green  = lipgloss.Color("#a6e3a1")
	dim    = lipgloss.Color("#6c7086")
	text   = lipgloss.Color("#cdd6f4")
)

// Styles
var (
	title     = lipgloss.NewStyle().Foreground(purple).Bold(true)
	highlight = lipgloss.NewStyle().Foreground(purple).Bold(true)
	muted     = lipgloss.NewStyle().Foreground(dim)
	danger    = lipgloss.NewStyle().Foreground(red).Bold(true)
	success   = lipgloss.NewStyle().Foreground(green).Bold(true)
	warn      = lipgloss.NewStyle().Foreground(yellow)
	tag       = lipgloss.NewStyle().Background(teal).Foreground(lipgloss.Color("#1e1e2e")).Padding(0, 1)
)

type Model struct {
	state   State
	blocked string // profile name if blocked

	// Config
	flakesDir, nixHomesDir, realHome string
	store                            *profile.Store

	// Data
	profiles []profile.Profile
	flakes   []flake.Flake

	// UI state
	cursor   int
	selected map[string]bool
	input    textinput.Model
	spinner  spinner.Model
	w, h     int

	// Operation
	opProfile *profile.Profile
	isEdit    bool
	logs      []string
	done      bool
	err       error
	deleting  bool
	firstRun  bool
	logChan   <-chan string
	doneChan  <-chan error

	Result *output.Result
}

type logMsg string
type doneMsg struct{ err error }

func New() Model {
	realHome := os.Getenv("REAL_HOME")
	if realHome == "" {
		realHome = os.Getenv("HOME")
	}
	currentHome := os.Getenv("HOME")
	nixHomesDir := filepath.Join(realHome, ".nix-homes")
	flakesDir := filepath.Join(realHome, "nix")

	ti := textinput.New()
	ti.Placeholder = "my-profile"
	ti.CharLimit, ti.Width, ti.Prompt = 30, 20, ""

	sp := spinner.New()
	sp.Spinner = spinner.MiniDot
	sp.Style = lipgloss.NewStyle().Foreground(purple)

	m := Model{
		state:       StateMenu,
		flakesDir:   flakesDir,
		nixHomesDir: nixHomesDir,
		realHome:    realHome,
		store:       profile.NewStore(filepath.Join(realHome, ".config", "nix-profiles.json"), nixHomesDir),
		selected:    make(map[string]bool),
		input:       ti,
		spinner:     sp,
	}

	// Block if inside a profile
	if strings.HasPrefix(currentHome, nixHomesDir+"/") {
		m.blocked = strings.TrimPrefix(currentHome, nixHomesDir+"/")
		m.state = StateBlocked
	}

	return m
}

func (m Model) Init() tea.Cmd {
	return func() tea.Msg {
		p, _ := m.store.Load()
		f, _ := flake.Discover(m.flakesDir)
		return initMsg{p, f}
	}
}

type initMsg struct {
	profiles []profile.Profile
	flakes   []flake.Flake
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.w, m.h = msg.Width, msg.Height
	case tea.KeyMsg:
		return m.handleKey(msg)
	case initMsg:
		m.profiles, m.flakes = msg.profiles, msg.flakes
	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd
	case logMsg:
		m.logs = append(m.logs, string(msg))
		return m, m.waitLog()
	case doneMsg:
		m.done, m.err = true, msg.err
	}
	return m, nil
}

func (m Model) handleKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	key := msg.String()

	// Global quit
	if key == "ctrl+c" {
		return m, tea.Quit
	}

	switch m.state {
	case StateBlocked:
		m.Result = output.NewCancel()
		return m, tea.Quit

	case StateMenu:
		return m.menuKey(key)

	case StateNewName:
		return m.nameKey(msg)

	case StateNewFlakes, StateEditFlakes:
		return m.flakeKey(key)

	case StateNewConfirm, StateEditConfirm:
		if key == "y" {
			return m.startProgress()
		}
		if key == "n" || key == "esc" {
			m.state = StateMenu
		}

	case StateDeleteConfirm:
		if key == "y" {
			return m.doDelete()
		}
		if key == "n" || key == "esc" {
			m.state = StateMenu
		}

	case StateProgress:
		if m.done && key == "enter" {
			if m.err != nil {
				m.state = StateMenu
				return m, nil
			}
			if m.isEdit {
				m.Result = output.NewCancel()
				return m, tea.Quit
			}
			m.state = StateSuccess
		}

	case StateSuccess:
		if m.deleting {
			return m, nil
		}
		switch key {
		case "enter":
			m.Result = output.NewSwitch(m.opProfile.Name, m.opProfile.Home, m.opProfile.GetFlakes(), false)
			return m, tea.Quit
		case "d":
			m.deleting = true
			return m, m.doCleanup()
		case "q", "esc":
			m.Result = output.NewCancel()
			return m, tea.Quit
		}
	}

	return m, nil
}

func (m Model) menuKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "up", "k":
		if m.cursor > 0 {
			m.cursor--
		}
	case "down", "j":
		if m.cursor < len(m.profiles)-1 {
			m.cursor++
		}
	case "enter":
		if len(m.profiles) > 0 {
			p := &m.profiles[m.cursor]
			m.Result = output.NewSwitch(p.Name, p.Home, p.GetFlakes(), false)
			return m, tea.Quit
		}
	case "n":
		m.input.Reset()
		m.input.Focus()
		m.state = StateNewName
		return m, textinput.Blink
	case "e":
		if len(m.profiles) > 0 {
			m.opProfile = &m.profiles[m.cursor]
			m.selected = make(map[string]bool)
			for _, f := range m.opProfile.GetFlakes() {
				m.selected[f] = true
			}
			m.cursor = 0
			m.state = StateEditFlakes
		}
	case "d":
		if len(m.profiles) > 0 {
			m.opProfile = &m.profiles[m.cursor]
			m.state = StateDeleteConfirm
		}
	case "q", "esc":
		m.Result = output.NewCancel()
		return m, tea.Quit
	}
	return m, nil
}

func (m Model) nameKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch msg.String() {
	case "enter":
		if m.input.Value() != "" {
			m.selected = make(map[string]bool)
			m.cursor = 0
			m.state = StateNewFlakes
		}
	case "esc":
		m.state = StateMenu
	default:
		var cmd tea.Cmd
		m.input, cmd = m.input.Update(msg)
		return m, cmd
	}
	return m, nil
}

func (m Model) flakeKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "up", "k":
		if m.cursor > 0 {
			m.cursor--
		}
	case "down", "j":
		if m.cursor < len(m.flakes)-1 {
			m.cursor++
		}
	case "tab", " ":
		if len(m.flakes) > 0 {
			name := m.flakes[m.cursor].Name
			m.selected[name] = !m.selected[name]
		}
	case "enter":
		if m.state == StateNewFlakes {
			m.state = StateNewConfirm
		} else {
			m.state = StateEditConfirm
		}
	case "esc":
		m.state = StateMenu
	}
	return m, nil
}

func (m Model) startProgress() (tea.Model, tea.Cmd) {
	flakes := m.selectedFlakes()

	if m.state == StateNewConfirm {
		m.opProfile = profile.New(m.input.Value(), flakes, m.nixHomesDir)
		m.store.Add(m.opProfile)
		m.isEdit = false
	} else {
		m.opProfile.Flakes = flakes
		m.opProfile.Flake = ""
		m.store.Update(m.opProfile)
		m.isEdit = true
	}

	m.state = StateProgress
	m.logs, m.done, m.err = nil, false, nil

	// Create channels once
	logCh := make(chan string, 100)
	doneCh := make(chan error, 1)
	m.logChan = logCh
	m.doneChan = doneCh

	// Start installation goroutine
	go func() {
		p := m.opProfile
		firstRun, err := home.Setup(p.Home, m.realHome)
		if err != nil {
			logCh <- fmt.Sprintf("Error: %v", err)
			close(logCh)
			doneCh <- err
			return
		}

		if firstRun {
			logCh <- "Setting up home directory..."
		}

		err = flake.InstallFlakesWithLogs(p.Home, m.flakesDir, p.GetFlakes(), logCh)
		if err == nil && firstRun {
			flake.RunFirstTimeSetup(p.Home, logCh)
		}

		close(logCh)
		doneCh <- err
	}()

	return m, tea.Batch(m.spinner.Tick, m.waitLog())
}

func (m Model) selectedFlakes() []string {
	var out []string
	for _, f := range m.flakes {
		if m.selected[f.Name] {
			out = append(out, f.Name)
		}
	}
	return out
}

func (m Model) waitLog() tea.Cmd {
	logCh := m.logChan
	doneCh := m.doneChan
	return func() tea.Msg {
		select {
		case msg, ok := <-logCh:
			if ok {
				return logMsg(msg)
			}
			// Channel closed, get result
			return doneMsg{<-doneCh}
		}
	}
}

func (m Model) doDelete() (tea.Model, tea.Cmd) {
	m.store.Delete(m.opProfile.Name)
	if m.opProfile.Home != "" && m.opProfile.Home != m.realHome {
		os.RemoveAll(m.opProfile.Home)
	}
	m.profiles, _ = m.store.Load()
	m.cursor = 0
	m.state = StateMenu
	return m, nil
}

func (m Model) doCleanup() tea.Cmd {
	return func() tea.Msg {
		m.store.Delete(m.opProfile.Name)
		if m.opProfile.Home != "" && m.opProfile.Home != m.realHome {
			os.RemoveAll(m.opProfile.Home)
		}
		return doneMsg{}
	}
}

// View renders the UI
func (m Model) View() string {
	var v string
	switch m.state {
	case StateBlocked:
		v = m.viewBlocked()
	case StateMenu:
		v = m.viewMenu()
	case StateNewName:
		v = m.viewName()
	case StateNewFlakes, StateEditFlakes:
		v = m.viewFlakes()
	case StateNewConfirm, StateEditConfirm:
		v = m.viewConfirm()
	case StateDeleteConfirm:
		v = m.viewDelete()
	case StateProgress:
		return m.viewProgress() // Full screen, no centering
	case StateSuccess:
		v = m.viewSuccess()
	}
	return m.center(v)
}

func (m Model) center(s string) string {
	if m.w == 0 || m.h == 0 {
		return s
	}
	return lipgloss.Place(m.w, m.h, lipgloss.Center, lipgloss.Center, s)
}

func (m Model) viewBlocked() string {
	return warn.Render("⚠  Cannot run inside profile: "+m.blocked) + "\n\n" +
		muted.Render("Exit this environment first.") + "\n\n" +
		muted.Render("Press any key to exit")
}

func (m Model) viewMenu() string {
	var b strings.Builder
	b.WriteString(title.Render("❄  Nix Environments") + "\n\n")

	if len(m.profiles) == 0 {
		b.WriteString(muted.Render("No profiles. Press n to create one.") + "\n")
	} else {
		maxLen := 0
		for _, p := range m.profiles {
			if len(p.Name) > maxLen {
				maxLen = len(p.Name)
			}
		}
		for i, p := range m.profiles {
			cursor := "  "
			if i == m.cursor {
				cursor = highlight.Render("▸ ")
			}
			name := fmt.Sprintf("%-*s", maxLen, p.Name)
			if i == m.cursor {
				name = highlight.Render(name)
			}
			flakes := muted.Render(p.FlakesDisplay())
			if i == m.cursor {
				var tags []string
				for _, f := range p.GetFlakes() {
					tags = append(tags, tag.Render(f))
				}
				if len(tags) > 0 {
					flakes = strings.Join(tags, " ")
				}
			}
			b.WriteString(cursor + name + "  " + flakes + "\n")
		}
	}

	b.WriteString("\n" + m.help("n", "new", "e", "edit", "d", "del", "↵", "switch", "q", "quit"))
	return b.String()
}

func (m Model) viewName() string {
	path := "~/.nix-homes/<name>"
	if m.input.Value() != "" {
		path = "~/.nix-homes/" + m.input.Value()
	}
	return title.Render("✦  New Profile") + "\n\n" +
		muted.Render("Name: ") + m.input.View() + "\n" +
		muted.Render("Path: ") + path + "\n\n" +
		m.help("↵", "next", "esc", "back")
}

func (m Model) viewFlakes() string {
	var b strings.Builder
	name := m.input.Value()
	if m.state == StateEditFlakes {
		name = m.opProfile.Name
	}
	b.WriteString(title.Render("✦  Select Flakes") + "  " + highlight.Render(name) + "\n\n")

	for i, f := range m.flakes {
		cursor := "  "
		if i == m.cursor {
			cursor = highlight.Render("▸ ")
		}
		check := muted.Render("○")
		if m.selected[f.Name] {
			check = success.Render("●")
		}
		name := f.Name
		if i == m.cursor {
			name = highlight.Render(name)
		}
		b.WriteString(cursor + check + " " + name + "\n")
	}

	b.WriteString("\n" + m.help("␣", "toggle", "↵", "confirm", "esc", "back"))
	return b.String()
}

func (m Model) viewConfirm() string {
	var b strings.Builder
	name := m.input.Value()
	action := "Create"
	if m.state == StateEditConfirm {
		name = m.opProfile.Name
		action = "Update"
	}

	b.WriteString(title.Render("✦  "+action+" Profile") + "\n\n")
	b.WriteString(muted.Render("Name:   ") + highlight.Render(name) + "\n")
	if m.state == StateNewConfirm {
		b.WriteString(muted.Render("Home:   ") + "~/.nix-homes/" + name + "\n")
	}
	b.WriteString(muted.Render("Flakes: "))
	for i, f := range m.selectedFlakes() {
		if i > 0 {
			b.WriteString(" ")
		}
		b.WriteString(tag.Render(f))
	}
	b.WriteString("\n\n" + m.help("y", "confirm", "esc", "back"))
	return b.String()
}

func (m Model) viewDelete() string {
	return danger.Render("⚠  Delete Profile") + "\n\n" +
		muted.Render("Name: ") + danger.Render(m.opProfile.Name) + "\n" +
		muted.Render("Home: ") + m.opProfile.Home + "\n\n" +
		warn.Render("This will permanently delete the profile and home directory.") + "\n\n" +
		m.help("y", "delete", "esc", "cancel")
}

func (m Model) viewProgress() string {
	w := m.w
	if w < 60 {
		w = 60
	}
	h := m.h
	if h < 20 {
		h = 20
	}

	// Header
	header := m.opProfile.Name
	if m.done {
		if m.err != nil {
			header = danger.Render("✗  ") + header
		} else {
			header = success.Render("✓  ") + header
		}
	}
	headerPad := (w - lipgloss.Width(header)) / 2
	out := strings.Repeat(" ", headerPad) + header + "\n"
	out += muted.Render(strings.Repeat("─", w)) + "\n"

	// Logs
	logH := h - 6
	start := 0
	if len(m.logs) > logH {
		start = len(m.logs) - logH
	}
	for i := start; i < len(m.logs); i++ {
		out += m.styleLog(m.logs[i]) + "\n"
	}
	for i := len(m.logs) - start; i < logH; i++ {
		out += "\n"
	}

	// Error box
	if m.done && m.err != nil {
		out += "\n" + danger.Render(m.err.Error()) + "\n"
	}

	// Footer
	out += muted.Render(strings.Repeat("─", w)) + "\n"
	var footer string
	if m.done {
		if m.err != nil {
			footer = m.help("↵", "back to menu")
		} else {
			footer = m.help("↵", "continue")
		}
	} else {
		footer = m.spinner.View() + "  " + muted.Render(m.currentStep())
	}
	footerPad := (w - lipgloss.Width(footer)) / 2
	out += strings.Repeat(" ", footerPad) + footer

	return out
}

func (m Model) viewSuccess() string {
	var b strings.Builder
	b.WriteString(success.Render("✓  Ready") + "  " + highlight.Render(m.opProfile.Name) + "\n\n")

	opts := []struct{ key, label, desc string }{
		{"↵", "Switch", "Activate this environment"},
		{"d", "Delete", "Remove profile and home"},
		{"q", "Exit", "Return without switching"},
	}
	for _, o := range opts {
		if o.key == "d" && m.deleting {
			b.WriteString("  " + m.spinner.View() + "  " + warn.Render("Deleting...") + "\n")
		} else {
			b.WriteString("  " + highlight.Render(o.key) + "  " + o.label + "  " + muted.Render(o.desc) + "\n")
		}
	}
	return b.String()
}

func (m Model) styleLog(line string) string {
	switch {
	case strings.Contains(line, "✓"):
		return success.Render(line)
	case strings.Contains(line, "✗"), strings.Contains(line, "Error"), strings.Contains(line, "failed"):
		return danger.Render(line)
	case strings.Contains(line, "⚠"):
		return warn.Render(line)
	case strings.HasPrefix(line, "["):
		return lipgloss.NewStyle().Foreground(purple).Render(line)
	default:
		return muted.Render(line)
	}
}

func (m Model) currentStep() string {
	for i := len(m.logs) - 1; i >= 0; i-- {
		line := strings.TrimSpace(m.logs[i])
		if line == "" || strings.HasPrefix(line, "  ") {
			continue
		}
		if strings.Contains(line, "Installing") {
			return line
		}
		if strings.Contains(line, "Upgrading") {
			return "Upgrading packages..."
		}
		if strings.HasPrefix(line, "[") {
			return line
		}
	}
	return "Working..."
}

func (m Model) help(items ...string) string {
	var parts []string
	for i := 0; i < len(items); i += 2 {
		parts = append(parts, highlight.Render(items[i])+" "+muted.Render(items[i+1]))
	}
	return strings.Join(parts, "  ")
}
