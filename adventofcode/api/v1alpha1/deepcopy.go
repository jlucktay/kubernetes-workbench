package v1alpha1

import "k8s.io/apimachinery/pkg/runtime"

func (in *AdventSolver) DeepCopyInto(out *AdventSolver) {
	out.TypeMeta = in.TypeMeta
	out.ObjectMeta = in.ObjectMeta
	out.Spec = AdventSolverSpec{
		Input: in.Spec.Input,
	}
}

func (in *AdventSolver) DeepCopyObject() runtime.Object {
	out := AdventSolver{}
	in.DeepCopyInto(&out)

	return &out
}

func (in *AdventSolverList) DeepCopyObject() runtime.Object {
	out := AdventSolverList{}
	out.TypeMeta = in.TypeMeta
	out.ListMeta = in.ListMeta

	if in.Items != nil {
		out.Items = make([]AdventSolver, len(in.Items))

		for i := range in.Items {
			in.Items[i].DeepCopyInto(&out.Items[i])
		}
	}

	return &out
}
