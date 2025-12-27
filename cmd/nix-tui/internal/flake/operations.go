package flake

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// colorEnv returns environment variables that force color output
func colorEnv() []string {
	return append(os.Environ(),
		"FORCE_COLOR=1",
		"CLICOLOR_FORCE=1",
		"TERM=xterm-256color",
		"NIX_PAGER=",
	)
}

// InstallFlakesWithLogs installs flakes and sends log messages
func InstallFlakesWithLogs(homePath, flakesDir string, flakeNames []string, logChan chan<- string) error {
	profilePath := filepath.Join(homePath, ".nix-profile")

	logChan <- fmt.Sprintf("Profile: %s", profilePath)
	logChan <- fmt.Sprintf("Flakes: %v", flakeNames)
	logChan <- ""

	var errors []string

	// Build set of wanted flake paths
	wantedPaths := make(map[string]bool)
	for _, name := range flakeNames {
		wantedPaths[filepath.Join(flakesDir, name)] = true
	}

	// Get currently installed flakes and remove unwanted ones
	listCmd := exec.Command("nix", "profile", "list", "--profile", profilePath)
	listCmd.Env = colorEnv()
	listOutput, err := listCmd.Output()
	if err == nil && len(listOutput) > 0 {
		logChan <- "Checking for flakes to remove..."
		lines := strings.Split(string(listOutput), "\n")
		for _, line := range lines {
			if strings.HasPrefix(line, "Name:") {
				name := strings.TrimSpace(strings.TrimPrefix(line, "Name:"))
				flakePath := filepath.Join(flakesDir, name)
				if !wantedPaths[flakePath] && name != "" {
					logChan <- fmt.Sprintf("  Removing: %s", name)
					removeCmd := exec.Command("nix", "profile", "remove", name, "--profile", profilePath)
					removeCmd.Env = colorEnv()
					if err := removeCmd.Run(); err != nil {
						logChan <- fmt.Sprintf("    ⚠ Failed to remove: %v", err)
					} else {
						logChan <- "    ✓ Removed"
					}
				}
			}
		}
		logChan <- ""
	}

	// Install new flakes
	for i, name := range flakeNames {
		flakePath := filepath.Join(flakesDir, name)
		logChan <- fmt.Sprintf("[%d/%d] Checking: %s", i+1, len(flakeNames), name)

		// Check if already installed
		cmd := exec.Command("nix", "profile", "list", "--profile", profilePath)
		cmd.Env = colorEnv()
		output, err := cmd.Output()
		if err != nil {
			logChan <- "  Profile not yet created, will install..."
		} else if strings.Contains(string(output), flakePath) {
			logChan <- "  ✓ Already installed"
			continue
		}

		logChan <- fmt.Sprintf("  Installing %s...", name)

		installCmd := exec.Command("nix", "profile", "add", flakePath,
			"--profile", profilePath, "--priority", "1")
		installCmd.Env = colorEnv()

		stdout, err := installCmd.StdoutPipe()
		if err != nil {
			logChan <- fmt.Sprintf("  ✗ Error: %v", err)
			errors = append(errors, fmt.Sprintf("%s: %v", name, err))
			continue
		}
		installCmd.Stderr = installCmd.Stdout

		if err := installCmd.Start(); err != nil {
			logChan <- fmt.Sprintf("  ✗ Failed to start: %v", err)
			errors = append(errors, fmt.Sprintf("%s: %v", name, err))
			continue
		}

		scanner := bufio.NewScanner(stdout)
		for scanner.Scan() {
			if line := scanner.Text(); line != "" {
				logChan <- fmt.Sprintf("    %s", line)
			}
		}

		if err := installCmd.Wait(); err != nil {
			logChan <- fmt.Sprintf("  ✗ Failed: %v", err)
			errors = append(errors, fmt.Sprintf("%s: %v", name, err))
		} else {
			logChan <- "  ✓ Installed successfully"
		}
	}

	// Upgrade all
	logChan <- ""
	logChan <- "Upgrading all packages..."
	upgradeCmd := exec.Command("nix", "profile", "upgrade", ".*", "--profile", profilePath)
	upgradeCmd.Env = colorEnv()
	if output, err := upgradeCmd.CombinedOutput(); err != nil {
		if len(output) > 0 {
			logChan <- fmt.Sprintf("  %s", strings.TrimSpace(string(output)))
		}
	} else {
		logChan <- "  ✓ Upgrade complete"
	}

	logChan <- ""

	if len(errors) > 0 {
		logChan <- fmt.Sprintf("✗ %d flake(s) failed", len(errors))
		return fmt.Errorf("%d flake(s) failed: %s", len(errors), strings.Join(errors, "; "))
	}

	logChan <- "✓ Flakes installed"
	return nil
}

// RunFirstTimeSetup runs mise install and nvim plugin sync
func RunFirstTimeSetup(homePath string, logChan chan<- string) {
	logChan <- ""
	logChan <- "Running first-time setup..."

	// mise tools
	logChan <- ""
	logChan <- "[mise] Installing tools..."
	runWithHome("mise", homePath, logChan, "trust", "--all")
	if err := runWithHome("mise", homePath, logChan, "install", "--yes"); err != nil {
		logChan <- fmt.Sprintf("  ⚠ mise: %v", err)
	} else {
		logChan <- "  ✓ mise tools ready"
	}

	// nvim plugins
	logChan <- ""
	logChan <- "[nvim] Syncing plugins..."
	if err := runWithHome("nvim", homePath, logChan, "--headless", "+Lazy! sync", "+qa"); err != nil {
		logChan <- fmt.Sprintf("  ⚠ nvim: %v", err)
	} else {
		logChan <- "  ✓ nvim plugins ready"
	}

	logChan <- ""
	logChan <- "✓ All setup complete!"
}

func runWithHome(name, homePath string, logChan chan<- string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Env = append(colorEnv(),
		fmt.Sprintf("HOME=%s", homePath),
		"MISE_YES=1",
	)

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return err
	}
	cmd.Stderr = cmd.Stdout

	if err := cmd.Start(); err != nil {
		return err
	}

	scanner := bufio.NewScanner(stdout)
	for scanner.Scan() {
		if line := scanner.Text(); line != "" {
			logChan <- fmt.Sprintf("  %s", line)
		}
	}

	return cmd.Wait()
}
