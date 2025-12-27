package app

type State int

const (
	StateBlocked State = iota
	StateMenu
	StateNewName
	StateNewFlakes
	StateNewConfirm
	StateEditFlakes
	StateEditConfirm
	StateDeleteConfirm
	StateProgress
	StateSuccess
)
