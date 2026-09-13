package main

import (
	"context"
	"fmt"

	"github.com/goforj/godump"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	aokv1alpha1 "go.jlucktay.dev/kubernetes-workbench/adventofcode/api/v1alpha1"
)

type reconciler struct {
	client.Client
	scheme *runtime.Scheme
}

func (r *reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx).WithValues("puzzle", req.NamespacedName)
	log.Info("reconciling Puzzle")

	var puzzle aokv1alpha1.Puzzle

	log.Info("getting Puzzle named '" + req.String() + "'")

	if err := r.Get(ctx, req.NamespacedName, &puzzle); err != nil {
		if client.IgnoreNotFound(err) != nil {
			return ctrl.Result{}, fmt.Errorf("getting Puzzle: %w", err)
		}

		// Puzzle was not found, so we can delete the associated Answer resource.

		// 🚧 D in CRUD 🚧
		if err := r.Delete(ctx, &aokv1alpha1.Answer{ObjectMeta: metav1.ObjectMeta{Namespace: req.Namespace, Name: req.Name}}); err != nil {
			return ctrl.Result{}, fmt.Errorf("deleting Answer: %w", err)
		}

		log.Info("deleted Answer associated with Puzzle named '" + req.String() + "'")

		return ctrl.Result{}, nil
	}

	log.Info("getting Answer associated with Puzzle named '" + req.String() + "'")

	// 🚧 R in CRUD 🚧
	var answer aokv1alpha1.Answer

	defer func() { godump.Dump(answer) }()

	if err := r.Get(ctx, req.NamespacedName, &answer); err != nil {
		if client.IgnoreNotFound(err) != nil {
			return ctrl.Result{}, fmt.Errorf("getting Answer: %w", err)
		}

		// 🚧 C in CRUD 🚧
		answer = getAnswerObject(req.NamespacedName, puzzle.Spec.Year, puzzle.Spec.Day,
			"138", "") // TODO: calculate some solutions

		if err := r.Create(ctx, &answer); client.IgnoreAlreadyExists(err) != nil {
			return ctrl.Result{}, fmt.Errorf("creating Answer: %w", err)
		}

		log.Info("new Answer for Puzzle '" + req.String() + "' created")

		return ctrl.Result{}, nil
	}

	log.Info("updating Answer associated with Puzzle named '" + req.String() + "'")

	// The Answer has been found, so let's see if we need to update it.
	// 🚧 U in CRUD 🚧
	if answer.Spec.Answers.PartOne == "" || answer.Spec.Answers.PartTwo == "" {
		log.Error(nil, "TODO: Answer associated with Puzzle '"+req.String()+"' probably needs to be updated")

		// TODO: (re)calculate some solutions
		// Use of .Patch is preferable to .Update
		// r.Patch(ctx context.Context, obj client.Object, patch client.Patch, opts ...client.PatchOption)
		// r.Update(ctx context.Context, obj client.Object, opts ...client.UpdateOption)

		log.Info("Answer associated with Puzzle '" + req.String() + "' updated")
		return ctrl.Result{}, nil
	}

	log.Info("Answer associated with Puzzle '" + req.String() + "' is up-to-date")

	return ctrl.Result{}, nil
}
