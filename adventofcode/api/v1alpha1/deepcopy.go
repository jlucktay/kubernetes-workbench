package v1alpha1

import "k8s.io/apimachinery/pkg/runtime"

// DeepCopyInto one AdventPuzzle to another.
func (in *AdventPuzzle) DeepCopyInto(out *AdventPuzzle) {
	out.TypeMeta = in.TypeMeta
	out.ObjectMeta = in.ObjectMeta
	out.Spec = AdventPuzzleSpec{
		Input: in.Spec.Input,
	}
}

// DeepCopyObject one AdventPuzzle to another.
func (in *AdventPuzzle) DeepCopyObject() runtime.Object {
	out := AdventPuzzle{}
	in.DeepCopyInto(&out)

	return &out
}

// DeepCopyObject an AdventPuzzleList to a generalised object interface.
func (in *AdventPuzzleList) DeepCopyObject() runtime.Object {
	out := AdventPuzzleList{}
	out.TypeMeta = in.TypeMeta
	out.ListMeta = in.ListMeta

	if in.Items != nil {
		out.Items = make([]AdventPuzzle, len(in.Items))

		for i := range in.Items {
			in.Items[i].DeepCopyInto(&out.Items[i])
		}
	}

	return &out
}
