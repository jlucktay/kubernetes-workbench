package main

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/types"

	aokv1alpha1 "go.jlucktay.dev/kubernetes-workbench/adventofcode/api/v1alpha1"
)

func getAnswerObject(nsn types.NamespacedName, year uint16, day uint8, part1, part2 string) aokv1alpha1.Answer {
	return aokv1alpha1.Answer{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Answer",
			APIVersion: "v1alpha1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Namespace: nsn.Namespace,
			Name:      nsn.Name,
		},
		Spec: aokv1alpha1.AnswerSpec{
			Year: year,
			Day:  day,
			Answers: aokv1alpha1.Answers{
				PartOne: part1,
				PartTwo: part2,
			},
		},
	}
}
