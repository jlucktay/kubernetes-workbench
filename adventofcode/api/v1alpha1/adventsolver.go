package v1alpha1

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

type AdventSolverList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitempty"`

	Items []AdventSolver `json:"items"`
}

type AdventSolver struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec AdventSolverSpec `json:"spec"`
}

type AdventSolverSpec struct {
	Input string `json:"input"`
}
