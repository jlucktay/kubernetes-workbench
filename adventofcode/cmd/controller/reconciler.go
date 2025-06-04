package main

import (
	"context"
	"fmt"

	k8serrors "k8s.io/apimachinery/pkg/api/errors"
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
		if !k8serrors.IsNotFound(err) {
			return ctrl.Result{}, fmt.Errorf("getting Puzzle: %w", err)
		}

		// Puzzle was not found, so we can delete the associated Answer resource.

		if err := r.Delete(ctx, &aokv1alpha1.Answer{ObjectMeta: metav1.ObjectMeta{Namespace: req.Namespace, Name: req.Name}}); err != nil {
			return ctrl.Result{}, fmt.Errorf("deleting Answer: %w", err)
		}

		log.Info("deleted Answer associated with Puzzle named '" + req.String() + "'")

		return ctrl.Result{}, nil
	}

	log.Info("getting Answer associated with Puzzle named '" + req.String() + "'")

	var answer aokv1alpha1.Answer

	if err := r.Get(ctx, req.NamespacedName, &answer); err != nil {
		if !k8serrors.IsNotFound(err) {
			return ctrl.Result{}, fmt.Errorf("getting Answer: %w", err)
		}

		answer = getAnswerObject(req.NamespacedName, puzzle.Spec.Year, puzzle.Spec.Day,
			"part1 string", "part2 string") // TODO: calculate some solutions

		if err := r.Create(ctx, &answer); err != nil && !k8serrors.IsAlreadyExists(err) {
			return ctrl.Result{}, fmt.Errorf("creating Answer: %w", err)
		}

		log.Info("new Answer for Puzzle '" + req.String() + "' created")

		return ctrl.Result{}, nil
	}

	log.Info("updating Answer associated with Puzzle named '" + req.String() + "'")

	// The Answer has been found, so let's see if we need to update it.
	if answer.Spec.Answers.PartOne == "" || answer.Spec.Answers.PartTwo == "" {
		log.Error(nil, "TODO: Answer associated with Puzzle '"+req.String()+"' probably needs to be updated")

		// TODO: (re)calculate some solutions

		log.Info("Answer associated with Puzzle '" + req.String() + "' updated")
		return ctrl.Result{}, nil
	}

	log.Info("Answer associated with Puzzle '" + req.String() + "' is up-to-date")

	return ctrl.Result{}, nil
}
