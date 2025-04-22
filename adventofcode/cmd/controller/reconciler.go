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

const replicaDivisor = 10

type reconciler struct {
	client.Client
	scheme     *runtime.Scheme
	kubeClient *kubernetes.Clientset
}

func (r *reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx).WithValues("adventpuzzle", req.NamespacedName)
	log.Info("reconciling AdventPuzzle")

	// Create the Deployment if it does not exist.
	deploymentsClient := r.kubeClient.AppsV1().Deployments(req.Namespace)
	configMapsClient := r.kubeClient.CoreV1().ConfigMaps(req.Namespace)

	adventPuzzleName := "adventpuzzle-" + req.Name

	var adventPuzzle aokv1alpha1.AdventPuzzle

	log.Info("getting AdventPuzzle named '" + req.String() + "'")

	err := r.Get(ctx, req.NamespacedName, &adventPuzzle)
	if err != nil {
		if !k8serrors.IsNotFound(err) {
			return ctrl.Result{}, fmt.Errorf("getting AdventPuzzle: %w", err)
		}

		// AdventPuzzle was not found, so we can delete the associated resources.

		if err := deploymentsClient.Delete(ctx, adventPuzzleName, metav1.DeleteOptions{}); err != nil {
			return ctrl.Result{}, fmt.Errorf("deleting Deployment: %w", err)
		}

		if err := configMapsClient.Delete(ctx, adventPuzzleName, metav1.DeleteOptions{}); err != nil {
			return ctrl.Result{}, fmt.Errorf("deleting ConfigMap: %w", err)
		}

		log.Info("deleted resources associated with AdventPuzzle named '" + adventPuzzleName + "'")

		return ctrl.Result{}, nil
	}

	log.Info("getting Deployment associated with AdventPuzzle named '" + adventPuzzleName + "'")

	deployment, err := deploymentsClient.Get(ctx, adventPuzzleName, metav1.GetOptions{})
	if err != nil {
		if !k8serrors.IsNotFound(err) {
			return ctrl.Result{}, fmt.Errorf("getting Deployment: %w", err)
		}

		configMapObj := getConfigMapObject(adventPuzzleName, adventPuzzle.Spec.Input)

		if _, err := configMapsClient.Create(ctx, configMapObj, metav1.CreateOptions{}); err != nil && !k8serrors.IsAlreadyExists(err) {
			return ctrl.Result{}, fmt.Errorf("creating ConfigMap: %w", err)
		}

		// 🚧🚧🚧 special fuzzy temporary math going on here
		deploymentObj := getDeploymentObject(adventPuzzleName, "bash:5", int32(adventPuzzle.Spec.Day/replicaDivisor))
		if *deploymentObj.Spec.Replicas <= 0 {
			*deploymentObj.Spec.Replicas = 1
		}
		// 🚧🚧🚧 special fuzzy temporary math going on here

		if _, err := deploymentsClient.Create(ctx, deploymentObj, metav1.CreateOptions{}); err != nil && !k8serrors.IsAlreadyExists(err) {
			return ctrl.Result{}, fmt.Errorf("creating Deployment: %w", err)
		}

		log.Info("new AdventPuzzle with name '" + adventPuzzleName + "' created")

		return ctrl.Result{}, nil
	}

	log.Info("updating Deployment associated with AdventPuzzle named '" + adventPuzzleName + "'")

	// The Deployment has been found, so let's see if we need to update it.
	if int(*deployment.Spec.Replicas) != int(adventPuzzle.Spec.Day) {
		// 🚧🚧🚧 special fuzzy temporary math going on here
		deployment.Spec.Replicas = int32Ptr(int32(adventPuzzle.Spec.Day / replicaDivisor))

		if *deployment.Spec.Replicas <= 0 {
			*deployment.Spec.Replicas = 1
		}
		// 🚧🚧🚧 special fuzzy temporary math going on here

		_, err := deploymentsClient.Update(ctx, deployment, metav1.UpdateOptions{})
		if err != nil {
			return ctrl.Result{}, fmt.Errorf("updating Deployment: %w", err)
		}

		log.Info("AdventPuzzle with name '" + adventPuzzleName + "' updated")

		return ctrl.Result{}, nil
	}

	log.Info("AdventPuzzle '" + adventPuzzleName + "' is up-to-date")

	return ctrl.Result{}, nil
}
