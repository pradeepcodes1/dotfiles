package profile

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/pradeep/nix-tui/internal/logging"
)

// Store manages profile persistence
type Store struct {
	filePath    string
	nixHomesDir string
}

// NewStore creates a new profile store
func NewStore(profilesFile, nixHomesDir string) *Store {
	return &Store{
		filePath:    profilesFile,
		nixHomesDir: nixHomesDir,
	}
}

// ensureFile ensures the profiles file exists
func (s *Store) ensureFile() error {
	if _, err := os.Stat(s.filePath); os.IsNotExist(err) {
		dir := filepath.Dir(s.filePath)
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("failed to create directory: %w", err)
		}
		if err := os.WriteFile(s.filePath, []byte("[]"), 0644); err != nil {
			return fmt.Errorf("failed to create profiles file: %w", err)
		}
	}
	return nil
}

// Load reads all profiles from the file
func (s *Store) Load() ([]Profile, error) {
	if err := s.ensureFile(); err != nil {
		return nil, err
	}

	data, err := os.ReadFile(s.filePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read profiles: %w", err)
	}

	var profiles []Profile
	if err := json.Unmarshal(data, &profiles); err != nil {
		return nil, fmt.Errorf("failed to parse profiles: %w", err)
	}

	// Normalize legacy format
	for i := range profiles {
		profiles[i].Normalize()
	}

	logging.Debug("profile", fmt.Sprintf("Loaded %d profiles", len(profiles)))
	return profiles, nil
}

// Save writes all profiles to the file
func (s *Store) Save(profiles []Profile) error {
	if err := s.ensureFile(); err != nil {
		return err
	}

	data, err := json.MarshalIndent(profiles, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to serialize profiles: %w", err)
	}

	if err := os.WriteFile(s.filePath, data, 0644); err != nil {
		return fmt.Errorf("failed to write profiles: %w", err)
	}

	logging.Info("profile", fmt.Sprintf("Saved %d profiles", len(profiles)))
	return nil
}

// Add adds a new profile
func (s *Store) Add(profile *Profile) error {
	profiles, err := s.Load()
	if err != nil {
		return err
	}

	// Check for duplicate name
	for _, p := range profiles {
		if p.Name == profile.Name {
			return fmt.Errorf("profile '%s' already exists", profile.Name)
		}
	}

	profiles = append(profiles, *profile)
	return s.Save(profiles)
}

// Update updates an existing profile
func (s *Store) Update(profile *Profile) error {
	profiles, err := s.Load()
	if err != nil {
		return err
	}

	found := false
	for i, p := range profiles {
		if p.Name == profile.Name {
			profiles[i] = *profile
			found = true
			break
		}
	}

	if !found {
		return fmt.Errorf("profile '%s' not found", profile.Name)
	}

	return s.Save(profiles)
}

// Delete removes a profile by name
func (s *Store) Delete(name string) error {
	profiles, err := s.Load()
	if err != nil {
		return err
	}

	newProfiles := make([]Profile, 0, len(profiles))
	found := false
	for _, p := range profiles {
		if p.Name == name {
			found = true
			continue
		}
		newProfiles = append(newProfiles, p)
	}

	if !found {
		return fmt.Errorf("profile '%s' not found", name)
	}

	logging.Info("profile", fmt.Sprintf("Deleted profile '%s'", name))
	return s.Save(newProfiles)
}

// Get retrieves a profile by name
func (s *Store) Get(name string) (*Profile, error) {
	profiles, err := s.Load()
	if err != nil {
		return nil, err
	}

	for _, p := range profiles {
		if p.Name == name {
			return &p, nil
		}
	}

	return nil, fmt.Errorf("profile '%s' not found", name)
}

// NixHomesDir returns the nix homes directory
func (s *Store) NixHomesDir() string {
	return s.nixHomesDir
}
