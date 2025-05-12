package v1alpha1

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

// AnswerList is a list of Answers.
type AnswerList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata,omitzero"`

	Items []Answer `json:"items"`
}

// Answer represents the answer to an Advent of Code (https://adventofcode.com) puzzle, which the AOK operator has (attempted to) solve.
type Answer struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitzero"`

	Spec AnswerSpec `json:"spec"`
}

// AnswerSpec is the structure of the Answer specification.
type AnswerSpec struct {
	// Year will be between 2015 and that of the most recent/current December (inclusive).
	Year uint16 `json:"year"`

	// Day ranges from 1 to 31; the length of December.
	Day uint8 `json:"day"`

	Answers Answers `json:"answers"`
}

// Answers to both parts of the day's puzzle.
type Answers struct {
	// PartOne answer to the day's puzzle.
	PartOne string `json:"partOne"`

	// PartTwo answer to the day's puzzle.
	PartTwo string `json:"partTwo"`
}
