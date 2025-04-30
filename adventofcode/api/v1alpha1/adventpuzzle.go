package v1alpha1

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

// AdventPuzzleList is a list of AdventPuzzles.
type AdventPuzzleList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitzero"`

	Items []AdventPuzzle `json:"items"`
}

// AdventPuzzle represents an Advent of Code puzzle, that this operator will attempt to solve.
type AdventPuzzle struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitzero"`

	Spec AdventPuzzleSpec `json:"spec"`
}

// AdventPuzzleSpec is the structure of the AdventPuzzle specification.
type AdventPuzzleSpec struct {
	// Year will be between 2015 and that of the most recent/current December (inclusive).
	Year uint16 `json:"year"`

	// Day ranges from 1 to 31; the length of December.
	Day uint8 `json:"day"`

	// Input of the day's puzzle.
	Input string `json:"input"`
}
