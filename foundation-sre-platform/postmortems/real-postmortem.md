Postmortem 1 — GKE Authentication Failure
Incident Type: Access / Authentication
Severity: Medium (blocked progress)
Impact
Kubernetes API was unreachable via kubectl.
Root Cause
Missing GKE auth plugin combined with stale kubeconfig entries on Windows.
Detection
kubectl repeatedly prompted for username/password.
Resolution
•	Installed gke-gcloud-auth-plugin
•	Cleaned kubeconfig
•	Restarted VS Code to inherit environment variables
Preventive Actions
•	Standardize Windows GKE setup checklist
•	Avoid mixing admin and non-admin shells
________________________________________
Postmortem 2 — Pods Unschedulable
Incident Type: Capacity / Scheduling
Severity: High (cluster unusable)
Impact
All system pods remained in Pending state.
Root Cause
Cluster created without a worker node pool.
Detection
kubectl get pods -A showed all pods Pending.
Resolution
Created a dedicated node pool with appropriate machine type.
Preventive Actions
•	Always validate node pools post-cluster creation
•	Add Terraform validation for minimum node count
________________________________________
Postmortem 3 — Infrastructure Blocked by Quota
Incident Type: Resource Management
Severity: Medium
Impact
Node pool creation failed during Terraform apply.
Root Cause
Regional SSD quota exceeded.
Detection
Terraform error indicating insufficient SSD quota.
Resolution
Reduced disk size and switched to pd-standard.
Preventive Actions
•	Pre-check quotas before provisioning
•	Right-size resources by default
________________________________________
Postmortem 4 — Observability Access Failure
Incident Type: Visibility
Severity: Low (no impact, delayed insight)
Impact
Metrics existed but could not be viewed.
Root Cause
Grafana not yet exposed via port-forward.
Detection
Prometheus pods running, no dashboards accessible.
Resolution
Used secure port-forwarding to access Grafana.
Preventive Actions
•	Add observability access checklist
•	Validate dashboards as part of rollout
________________________________________
Postmortem 5 — Namespace Oversight
Incident Type: Operational Hygiene
Severity: Low
Impact
Logs appeared missing.
Root Cause
Logs queried in default namespace while app ran in custom namespace.
Detection
kubectl logs returned “No resources found”.
Resolution
Explicitly specified namespace.
Preventive Actions
•	Enforce namespace-explicit commands
•	Avoid reliance on default namespace
________________________________________
Final Blameless Statement
All incidents in Phase 1 were caused by systemic gaps, not individual mistakes. Each failure surfaced an assumption that needed correction. The system improved because the failures were investigated, not ignored.


