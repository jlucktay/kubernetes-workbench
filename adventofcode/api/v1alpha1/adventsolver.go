package v1alpha1

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

// AdventSolverList is a list of AdventSolvers.
type AdventSolverList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitzero"`

	Items []AdventSolver `json:"items"`
}

// AdventSolver will solve your Advent of Code puzzles for you.
type AdventSolver struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitzero"`

	Spec AdventSolverSpec `json:"spec"`
}

// AdventSolverSpec is the structure of the AdventSolver specification.
type AdventSolverSpec struct {
	Year  uint16 `json:"year"`
	Day   uint8  `json:"day"`
	Input string `json:"input"`
}
