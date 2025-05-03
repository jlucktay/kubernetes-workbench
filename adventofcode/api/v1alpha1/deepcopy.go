package v1alpha1

import "k8s.io/apimachinery/pkg/runtime"

// DeepCopyInto one Puzzle to another.
func (in *Puzzle) DeepCopyInto(out *Puzzle) {
	out.TypeMeta = in.TypeMeta
	out.ObjectMeta = in.ObjectMeta
	out.Spec = PuzzleSpec{
		Input: in.Spec.Input,
	}
}

// DeepCopyObject one Puzzle to another.
func (in *Puzzle) DeepCopyObject() runtime.Object {
	out := Puzzle{}
	in.DeepCopyInto(&out)

	return &out
}

// DeepCopyObject an PuzzleList to a generalised object interface.
func (in *PuzzleList) DeepCopyObject() runtime.Object {
	out := PuzzleList{}
	out.TypeMeta = in.TypeMeta
	out.ListMeta = in.ListMeta

	if in.Items != nil {
		out.Items = make([]Puzzle, len(in.Items))

		for i := range in.Items {
			in.Items[i].DeepCopyInto(&out.Items[i])
		}
	}

	return &out
}
