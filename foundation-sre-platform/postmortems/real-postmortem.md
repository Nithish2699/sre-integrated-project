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
*   **Root Cause**: Multiple potential causes:
    1.  Grafana was not exposed locally via `kubectl port-forward`.
    2.  The Prometheus data source in Grafana used an incorrect, non-qualified service DNS name.
    3.  Prometheus scrape targets were `DOWN` due to network or configuration issues.
*   **Detection**: Grafana dashboards were empty or showed "No data".

### Resolution
1.  A secure port-forward was established using `kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80`.
2.  The Grafana data source URL was corrected to the fully qualified DNS name (e.g., `http://prometheus.monitoring.svc.cluster.local:9090`).
3.  Prometheus targets were inspected directly via its UI to confirm they were in an `UP` state.

### Preventive Actions
*   **Documentation**: Add an "Observability Access" section to the setup checklist.
*   **Process**: Validate that dashboards are populated with data as a final step of the observability stack rollout.

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

## Postmortem 6: Node Exporter Pods Pending

*   **Incident Type**: Scheduling / Configuration
*   **Severity**: Medium (core metrics collection impaired)
*   **Impact**: Node-level metrics (CPU, memory, disk) were not being collected because the `prometheus-node-exporter` pods could not be scheduled.
*   **Root Cause**: The GKE nodes had taints that the `node-exporter` DaemonSet pods did not tolerate by default.
*   **Detection**: `kubectl get pods -n monitoring` showed `node-exporter` pods in a `Pending` state. `kubectl describe pod` revealed a `FailedScheduling` event due to taints.

### Resolution
The `kube-prometheus-stack` Helm release was upgraded with `--set` flags to make it compatible with GKE Autopilot. This involved two changes:
1.  Adding a toleration for the `cloud.google.com/gke-provisioning=autopilot:NoSchedule` taint.
2.  Disabling `hostPort` usage (`prometheus-node-exporter.hostPort=null`), which is disallowed in Autopilot and was causing a port conflict on one node.

### Preventive Actions
*   **Automation**: Enhance deployment scripts to check for common GKE taints and apply necessary tolerations by default.
*   **Documentation**: Add a note in the `README.md` about checking node taints and configuring tolerations as a potential part of the Helm installation step.
*   **Best Practice**: Always run `kubectl describe` on a pending pod as the first diagnostic step for any scheduling issue.
*   **Platform Awareness**: When deploying to managed platforms like GKE Autopilot, always check the documentation for restricted features like `hostPort`.

---

> ### Final Blameless Statement
> All incidents in Phase 1 were caused by systemic gaps, not individual mistakes. Each failure surfaced an assumption that needed correction. The system improved because the failures were investigated, not ignored.
