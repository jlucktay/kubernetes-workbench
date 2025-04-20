package main

import (
	"context"
	"errors"
	"os"
	"path/filepath"

	gjdv1alpha1 "go.jlucktay.dev/kubernetes-workbench/adventofcode/api/v1alpha1"
	"k8s.io/apimachinery/pkg/runtime"
	utilruntime "k8s.io/apimachinery/pkg/util/runtime"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"
	"sigs.k8s.io/controller-runtime/pkg/log/zap"
)

var (
	scheme   = runtime.NewScheme()
	setupLog = ctrl.Log.WithName("setup")
)

func init() {
	utilruntime.Must(gjdv1alpha1.AddToScheme(scheme))
}

type reconciler struct {
	client.Client
	scheme     *runtime.Scheme
	kubeClient *kubernetes.Clientset
}

func (r *reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := log.FromContext(ctx).WithValues("adventsolver", req.NamespacedName)
	log.Info("reconciling adventsolver")

	//
	return ctrl.Result{}, nil
}

func main() {
	var (
		config *rest.Config
		err    error
	)

	setupLog.Info("looking up home directory")
	userHome, err := os.UserHomeDir()
	if err != nil {
		setupLog.Error(err, "looking up home directory")
		os.Exit(1)
	}

	setupLog.Info("looking for kubeconfig")
	kubeconfigFilePath := filepath.Join(userHome, ".kube", "config")
	if _, err = os.Stat(kubeconfigFilePath); errors.Is(err, os.ErrNotExist) {
		// The kubeconfig file does not exist, so we are (probably) inside a cluster.
		config, err = rest.InClusterConfig()
	} else {
		// We found a kubeconfig file, so we will build our config on top of that.
		config, err = clientcmd.BuildConfigFromFlags("", kubeconfigFilePath)
	}
	if err != nil {
		setupLog.Error(err, "looking for kubeconfig")
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
		For(&gjdv1alpha1.AdventSolver{}).
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
	if err = mgr.Start(ctrl.SetupSignalHandler()); err != nil {
		setupLog.Error(err, "starting manager")
		os.Exit(1)
	}
}
