// Package main is the logic for the main control loop.
package main

import (
	"errors"
	"os"
	"path/filepath"

	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/log/zap"

	aokv1alpha1 "go.jlucktay.dev/kubernetes-workbench/adventofcode/api/v1alpha1"
)

func main() {
	var (
		setupLog = ctrl.Log.WithName("setup")

		scheme = runtime.NewScheme()
		err    error
	)

	setupLog.Info("adding to scheme")

	err = aokv1alpha1.AddToScheme(scheme)
	if err != nil {
		setupLog.Error(err, "adding to scheme")
		os.Exit(1)
	}

	setupLog.Info("looking up home directory")

	userHome, err := os.UserHomeDir()
	if err != nil {
		setupLog.Error(err, "looking up home directory")
		os.Exit(1)
	}

	var config *rest.Config

	setupLog.Info("looking for config")

	kubeconfigFilePath := filepath.Join(userHome, ".kube", "config")
	if _, err = os.Stat(kubeconfigFilePath); errors.Is(err, os.ErrNotExist) {
		// The kubeconfig file does not exist, so we are (probably) inside a cluster.
		setupLog.Info("looking for in-cluster config")

		config, err = rest.InClusterConfig()
	} else {
		// We found a kubeconfig file, so we will build our config on top of that.
		setupLog.Info("looking for kubeconfig file")

		config, err = clientcmd.BuildConfigFromFlags("", kubeconfigFilePath)
	}

	if err != nil {
		setupLog.Error(err, "looking for config")
		os.Exit(1)
	}

	// Set of Kubernetes clients for groups.
	setupLog.Info("creating clientset for config")

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		setupLog.Error(err, "creating clientset for config")
		os.Exit(1)
	}

	ctrl.SetLogger(zap.New())

	setupLog.Info("creating manager")

	mgr, err := ctrl.NewManager(config, ctrl.Options{
		Scheme: scheme,
	})
	if err != nil {
		setupLog.Error(err, "creating manager")
		os.Exit(1)
	}

	setupLog.Info("creating controller")

	err = ctrl.NewControllerManagedBy(mgr).
		For(&aokv1alpha1.Puzzle{}).
		Complete(&reconciler{
			Client:     mgr.GetClient(),
			scheme:     mgr.GetScheme(),
			kubeClient: clientset,
		})
	if err != nil {
		setupLog.Error(err, "creating controller")
		os.Exit(1)
	}

	setupLog.Info("starting manager")

	if err := mgr.Start(ctrl.SetupSignalHandler()); err != nil {
		setupLog.Error(err, "starting manager")
		os.Exit(1)
	}
}
