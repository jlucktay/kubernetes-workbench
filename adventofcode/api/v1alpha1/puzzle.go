package v1alpha1

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

// PuzzleList is a list of Puzzles.
type PuzzleList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitzero"`

	Items []Puzzle `json:"items"`
}

// Puzzle represents an Advent of Code (https://adventofcode.com) puzzle, that this operator will attempt to solve.
type Puzzle struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitzero"`

	Spec PuzzleSpec `json:"spec"`
}

// PuzzleSpec is the structure of the Puzzle specification.
type PuzzleSpec struct {
	// Year will be between 2015 and that of the most recent/current December (inclusive).
	Year uint16 `json:"year"`

	// Day ranges from 1 to 31; the length of December.
	Day uint8 `json:"day"`

	// Input of the day's puzzle.
	Input string `json:"input"`
}
