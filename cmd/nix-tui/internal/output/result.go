package output

// Result is the JSON output consumed by the shell wrapper
type Result struct {
	Action   string   `json:"action"`
	Profile  string   `json:"profile,omitempty"`
	Home     string   `json:"home,omitempty"`
	Flakes   []string `json:"flakes,omitempty"`
	FirstRun bool     `json:"first_run,omitempty"`
	Error    string   `json:"error,omitempty"`
}

// NewSwitch creates a switch action result
func NewSwitch(profile, home string, flakes []string, firstRun bool) *Result {
	return &Result{
		Action:   "switch",
		Profile:  profile,
		Home:     home,
		Flakes:   flakes,
		FirstRun: firstRun,
	}
}

// NewCancel creates a cancel action result
func NewCancel() *Result {
	return &Result{Action: "cancel"}
}
