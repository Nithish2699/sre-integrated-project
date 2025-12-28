## Postmortem 1: GKE Authentication Failure

*   **Incident Type**: Access / Authentication
*   **Severity**: Medium (blocked progress)
*   **Impact**: Kubernetes API was unreachable via `kubectl`.
*   **Root Cause**: Missing GKE auth plugin combined with stale `kubeconfig` entries on Windows.
*   **Detection**: `kubectl` repeatedly prompted for username/password.

### Resolution
1.  Installed the `gke-gcloud-auth-plugin`.
2.  Cleaned the `~/.kube/config` file.
3.  Restarted VS Code to inherit the correct environment variables.

### Preventive Actions
*   **Documentation**: Standardize the GKE setup checklist for Windows developers.
*   **Process**: Advise against mixing admin and non-admin shells to prevent credential conflicts.

---

## Postmortem 2: Pods Unschedulable

*   **Incident Type**: Capacity / Scheduling
*   **Severity**: High (cluster unusable)
*   **Impact**: All system pods remained in a `Pending` state.
*   **Root Cause**: The cluster was created without a worker node pool.
*   **Detection**: `kubectl get pods -A` showed all pods as `Pending`.

### Resolution
A dedicated node pool was created with an appropriate machine type.

### Preventive Actions
*   **Process**: Always validate node pools exist and are healthy immediately after cluster creation.
*   **Automation**: Add a Terraform validation rule to enforce a minimum node count.

---

## Postmortem 3: Infrastructure Blocked by Quota

*   **Incident Type**: Resource Management
*   **Severity**: Medium
*   **Impact**: Node pool creation failed during `terraform apply`.
*   **Root Cause**: The regional SSD persistent disk quota was exceeded.
*   **Detection**: Terraform apply failed with an error indicating "insufficient regional quota 'SSD_TOTAL_GB'".

### Resolution
The node pool's disk size was reduced, and the disk type was changed from `pd-ssd` to `pd-standard`.

### Preventive Actions
*   **Process**: Add a pre-provisioning step to check relevant GCP quotas.
*   **Configuration**: Default to right-sized, cost-effective resources (`pd-standard`) for non-production environments.

---

## Postmortem 4: Observability Access Failure

*   **Incident Type**: Visibility / Tooling
*   **Severity**: Low (delayed insight, no service impact)
*   **Impact**: Metrics were being collected by Prometheus but could not be viewed in Grafana.
*   **Root Cause**: Grafana was not yet exposed to the local machine via `kubectl port-forward`.
*   **Detection**: Prometheus pods were `Running`, but the Grafana URL was inaccessible.

### Resolution
A secure port-forward was established using `kubectl port-forward svc/monitoring-grafana 3000:80`.

### Preventive Actions
*   **Documentation**: Add an "Observability Access" section to the setup checklist.
*   **Process**: Validate that dashboards are accessible as a final step of the observability stack rollout.

---

## Postmortem 5: Namespace Oversight

*   **Incident Type**: Operational Hygiene
*   **Severity**: Low
*   **Impact**: Application logs appeared to be missing when queried.
*   **Root Cause**: Logs were queried in the `default` namespace, while the application was running in the `sre-demo` namespace.
*   **Detection**: `kubectl logs` returned "No resources found in default namespace".

### Resolution
The namespace was explicitly specified in the command: `kubectl logs -n sre-demo -l app=sre-demo`.

### Preventive Actions
*   **Best Practice**: Enforce a team-wide convention of always using explicit namespaces in `kubectl` commands.
*   **Training**: Reinforce that relying on the `default` namespace is an anti-pattern in production-like environments.

---

> ### Final Blameless Statement
> All incidents in Phase 1 were caused by systemic gaps, not individual mistakes. Each failure surfaced an assumption that needed correction. The system improved because the failures were investigated, not ignored.
