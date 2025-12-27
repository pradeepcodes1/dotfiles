package home

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/pradeep/nix-tui/internal/logging"
)

// ConfigSymlinks defines what to symlink from real home to nix home
var ConfigSymlinks = []string{
	".config",
	".zshrc",
	".zprofile",
	".env",
	".oh-my-zsh",
	".gnupg",
	"nix",
	"Library/Keychains",
}

// Setup creates symlinks in new home directory
// Returns true if this is a first run (empty directory)
func Setup(newHome, realHome string) (bool, error) {
	// Ensure directory exists
	if err := os.MkdirAll(newHome, 0755); err != nil {
		return false, fmt.Errorf("failed to create home directory: %w", err)
	}

	// Check if directory is empty (first run)
	entries, err := os.ReadDir(newHome)
	if err != nil {
		return false, fmt.Errorf("failed to read home directory: %w", err)
	}

	// Count actual files (excluding hidden nix-related files)
	fileCount := 0
	for _, entry := range entries {
		name := entry.Name()
		// Don't count .nix-profile as it's created by nix
		if name != ".nix-profile" && name != ".nix-defexpr" && name != ".nix-channels" {
			fileCount++
		}
	}

	isFirstRun := fileCount == 0

	if !isFirstRun {
		logging.Debug("home", fmt.Sprintf("Home directory not empty (%d items), skipping symlink setup", fileCount))
		return false, nil
	}

	logging.Info("home", fmt.Sprintf("Setting up symlinks in %s...", newHome))

	// Create symlinks
	for _, item := range ConfigSymlinks {
		src := filepath.Join(realHome, item)
		dst := filepath.Join(newHome, item)

		// Check if source exists
		if _, err := os.Stat(src); os.IsNotExist(err) {
			logging.Debug("home", fmt.Sprintf("Source does not exist, skipping: %s", item))
			continue
		}

		// Check if destination already exists
		if _, err := os.Lstat(dst); err == nil {
			logging.Debug("home", fmt.Sprintf("Destination already exists, skipping: %s", item))
			continue
		}

		// Ensure parent directory exists
		if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
			logging.Warn("home", fmt.Sprintf("Failed to create parent directory for %s: %v", item, err))
			continue
		}

		// Create symlink
		if err := os.Symlink(src, dst); err != nil {
			logging.Warn("home", fmt.Sprintf("Failed to create symlink for %s: %v", item, err))
			continue
		}

		logging.Debug("home", fmt.Sprintf("Linked: %s", item))
	}

	logging.Info("home", "Symlink setup complete")
	return true, nil
}

// IsEmpty checks if a home directory needs first-run setup
func IsEmpty(homePath string) bool {
	entries, err := os.ReadDir(homePath)
	if err != nil {
		// Directory doesn't exist - counts as empty
		return true
	}

	for _, entry := range entries {
		name := entry.Name()
		if name != ".nix-profile" && name != ".nix-defexpr" && name != ".nix-channels" {
			return false
		}
	}

	return true
}
