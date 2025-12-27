package profile

import (
	"path/filepath"
	"strings"
)

// Profile represents a nix flake environment profile
type Profile struct {
	Name   string   `json:"name"`
	Home   string   `json:"home"`
	Flakes []string `json:"flakes,omitempty"`
	Flake  string   `json:"flake,omitempty"` // Legacy single flake
}

// GetFlakes returns flakes, handling legacy single-flake format
func (p *Profile) GetFlakes() []string {
	if len(p.Flakes) > 0 {
		return p.Flakes
	}
	if p.Flake != "" {
		return []string{p.Flake}
	}
	return nil
}

// FlakesDisplay returns a display string for the flakes
func (p *Profile) FlakesDisplay() string {
	if flakes := p.GetFlakes(); len(flakes) > 0 {
		return strings.Join(flakes, ", ")
	}
	return "(no flakes)"
}

// HomeDisplay returns a shortened home path
func (p *Profile) HomeDisplay() string {
	if strings.HasPrefix(p.Home, "/Users/") {
		parts := strings.SplitN(p.Home, "/", 4)
		if len(parts) >= 4 {
			return "~/" + parts[3]
		}
	}
	return p.Home
}

// New creates a new profile
func New(name string, flakes []string, nixHomesDir string) *Profile {
	return &Profile{
		Name:   name,
		Home:   filepath.Join(nixHomesDir, name),
		Flakes: flakes,
	}
}

// Normalize converts legacy single flake to flakes array
func (p *Profile) Normalize() {
	if p.Flake != "" && len(p.Flakes) == 0 {
		p.Flakes = []string{p.Flake}
		p.Flake = ""
	}
}
