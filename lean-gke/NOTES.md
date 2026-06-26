# Lean GKE

## References

- [GKE on a Budget: Disabling Expensive Defaults for Leaner Clusters](https://hodovi.cc/blog/gke-on-a-budget-disabling-expensive-defaults-for-leaner-clusters/)
- [Using GKE with Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform)
- [Simple Regional Autopilot Cluster](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/main/examples/simple_autopilot_private_non_default_sa)

## Why did I set things up like this?

- Enabled the service networking API because it's (probably?) necessary for GKE to provision a load balancer based on a `Ingress` resource.
  - Saw it [in this repo here](https://github.com/Neutrollized/free-tier-gke#enable-required-apis).

- Pared the node pool down to one node overall, instead of one node per zone.
  - Manipulated the `node_locations` fields on the node pool.

- Allow listed the CIDR block with a `display_name` of `Home` in Cloud Armor rules, piggybacking on the control plane input variable.

## TODO

- Run an Ingress or a `type = LoadBalancer` Service to expose a `podinfo` Deployment
  - <https://share.google/aimode/b59UVXU8dfvms4h7C>
- Set up some `jlucktay.dev` subdomain DNS against the pilot Deployment.

- Set up GKE Connect Gateway so that the Google Cloud web console can maintain visibility into the cluster.
  - Connect Gateway requires (1) Fleet, and (2) Workload Identity.
