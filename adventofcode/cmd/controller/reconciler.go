package main

import (
	"context"
	"fmt"

	k8serrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/client-go/kubernetes"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	aokv1alpha1 "go.jlucktay.dev/kubernetes-workbench/adventofcode/api/v1alpha1"
)

type reconciler struct {
	client.Client
	scheme     *runtime.Scheme
	kubeClient *kubernetes.Clientset
}

func (r *reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx).WithValues("adventsolver", req.NamespacedName)
	log.Info("reconciling AdventSolver")

	// Create the Deployment if it does not exist.
	deploymentsClient := r.kubeClient.AppsV1().Deployments(req.Namespace)
	configMapsClient := r.kubeClient.CoreV1().ConfigMaps(req.Namespace)

	adventSolverName := "adventsolver-" + req.Name

	var adventSolver aokv1alpha1.AdventSolver
	err := r.Get(ctx, req.NamespacedName, &adventSolver)
	if err != nil {
		if k8serrors.IsNotFound(err) { // AdventSolver not found; we can delete the resources.
			err = deploymentsClient.Delete(ctx, adventSolverName, metav1.DeleteOptions{})
			if err != nil {
				return ctrl.Result{}, fmt.Errorf("deleting Deployment: %w", err)
			}

			err = configMapsClient.Delete(ctx, adventSolverName, metav1.DeleteOptions{})
			if err != nil {
				return ctrl.Result{}, fmt.Errorf("deleting ConfigMap: %w", err)
			}

			return ctrl.Result{}, nil
		}

		return ctrl.Result{}, err
	}

	deployment, err := deploymentsClient.Get(ctx, adventSolverName, metav1.GetOptions{})
	if err != nil {
		if k8serrors.IsNotFound(err) {
			configMapObj := getConfigMapObject(adventSolverName, adventSolver.Spec.Input)
			_, err = configMapsClient.Create(ctx, configMapObj, metav1.CreateOptions{})
			if err != nil && !k8serrors.IsAlreadyExists(err) {
				return ctrl.Result{}, fmt.Errorf("creating ConfigMap: %w", err)
			}

			deploymentObj := getDeploymentObject(adventSolverName, "image", 2)
			_, err = deploymentsClient.Create(ctx, deploymentObj, metav1.CreateOptions{})
			if err != nil {
				return ctrl.Result{}, fmt.Errorf("creating Deployment: %w", err)
			}

			log.Info("new AdventSolver with name '" + adventSolverName + "' created")

			return ctrl.Result{}, nil
		} else {
			return ctrl.Result{}, fmt.Errorf("getting Deployment: %w", err)
		}
	}

	// The Deployment has been found, so let's see if we need to update it.
	if int(*deployment.Spec.Replicas) != 2 {
		deployment.Spec.Replicas = int32Ptr(2)
		_, err := deploymentsClient.Update(ctx, deployment, metav1.UpdateOptions{})
		if err != nil {
			return ctrl.Result{}, fmt.Errorf("updating Deployment: %w", err)
		}

		log.Info("AdventSolver with name '" + adventSolverName + "' updated")

		return ctrl.Result{}, nil
	}

	log.Info("AdventSolver '" + adventSolverName + "' is up-to-date")

	return ctrl.Result{}, nil
}
