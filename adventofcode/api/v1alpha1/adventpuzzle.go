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
	Year  uint16 `json:"year"`
	Day   uint8  `json:"day"`
	Input string `json:"input"`
}
