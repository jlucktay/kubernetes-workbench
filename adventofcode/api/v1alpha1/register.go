// Package v1alpha1 defines this version of custom resources.
package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

const (
	// GroupName is the name of the API group of custom resources defined here.
	GroupName = "adventofcode.jlucktay.dev"

	// GroupVersion is the version of the custom resources defined here.
	GroupVersion = "v1alpha1"
)

// SchemaGroupVersion holds the Group and Version to uniquely identify the API.
var SchemaGroupVersion = schema.GroupVersion{Group: GroupName, Version: GroupVersion}

var (
	// SchemeBuilder helps register new types.
	SchemeBuilder = runtime.NewSchemeBuilder(addKnownTypes)

	// AddToScheme is a registration shortcut for our types.
	AddToScheme = SchemeBuilder.AddToScheme
)

func addKnownTypes(scheme *runtime.Scheme) error {
	scheme.AddKnownTypes(SchemaGroupVersion,
		&Puzzle{}, &PuzzleList{},
		&Answer{}, &AnswerList{},
	)

	metav1.AddToGroupVersion(scheme, SchemaGroupVersion)

	return nil
}
