package v1alpha1

import "k8s.io/apimachinery/pkg/runtime"

// DeepCopyInto one Answer to another.
func (in *Answer) DeepCopyInto(out *Answer) {
	out.TypeMeta = in.TypeMeta
	out.ObjectMeta = in.ObjectMeta
	out.Spec = in.Spec
	out.Spec.Answers = in.Spec.Answers
}

// DeepCopyObject one Answer to another.
func (in *Answer) DeepCopyObject() runtime.Object {
	out := Answer{}
	in.DeepCopyInto(&out)

	return &out
}

// DeepCopyObject an AnswerList to a generalised object interface.
func (in *AnswerList) DeepCopyObject() runtime.Object {
	out := AnswerList{}
	out.TypeMeta = in.TypeMeta
	out.ListMeta = in.ListMeta

	if in.Items != nil {
		out.Items = make([]Answer, len(in.Items))

		for i := range in.Items {
			in.Items[i].DeepCopyInto(&out.Items[i])
		}
	}

	return &out
}
