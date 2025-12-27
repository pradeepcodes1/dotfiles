package flake

import (
	"os"
	"path/filepath"
	"sort"
)

// Flake represents an available flake in the flakes directory
type Flake struct {
	Name string
	Path string
}

// Discover scans the flakes directory for directories containing flake.nix
func Discover(flakesDir string) ([]Flake, error) {
	entries, err := os.ReadDir(flakesDir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil
		}
		return nil, err
	}

	var flakes []Flake
	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		flakeNix := filepath.Join(flakesDir, entry.Name(), "flake.nix")
		if _, err := os.Stat(flakeNix); err == nil {
			flakes = append(flakes, Flake{Name: entry.Name(), Path: filepath.Join(flakesDir, entry.Name())})
		}
	}

	sort.Slice(flakes, func(i, j int) bool { return flakes[i].Name < flakes[j].Name })
	return flakes, nil
}

// Names returns just the flake names from a list of flakes
func Names(flakes []Flake) []string {
	names := make([]string, len(flakes))
	for i, f := range flakes {
		names[i] = f.Name
	}
	return names
}
