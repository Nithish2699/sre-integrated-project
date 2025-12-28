# Foundation SRE Platform — Phase 1

**Production-Grade Observability & Reliability on Google Kubernetes Engine**

> Reliability is not achieved by avoiding failure, but by engineering visibility, recovery, and learning.

## 📌 Project Overview

This repository documents Phase 1 of a real-world Site Reliability Engineering (SRE) platform implemented on Google Kubernetes Engine (GKE).

Unlike tutorial-style projects, this phase captures:
*   Real infrastructure and tooling issues
*   Operational debugging across cloud, Kubernetes, and local environments
*   Verified observability through failure simulation
*   Blameless learning documented for future prevention

Phase 1 focuses on foundational reliability and observability before introducing controlled delivery mechanisms.

## 🎯 Phase 1 Objectives

*   Provision Kubernetes infrastructure using Terraform
*   Securely access and validate the cluster
*   Deploy a microservice workload
*   Implement metrics using Prometheus
*   Visualize health using Grafana dashboards
*   Validate logs using GCP Cloud Logging and Splunk
*   Simulate incidents and observe system behavior

## 🏗️ Phase 1 Architecture (Metrics & Logs)

**Metrics Flow:**
`Pods / Nodes` → `Prometheus (GKE)` → `Grafana (GKE)` → `kubectl port-forward` → `Browser`

**Logs Flow:**
`Pods` → `GKE Logging Agent` → `Cloud Logging` → `Splunk`

> 🔐 **Security Note:** Grafana is not publicly exposed. Access is restricted via `kubectl port-forward` only.

## 🧰 Technology Stack

*   **Cloud:** Google Cloud Platform (GKE)
*   **IaC:** Terraform
*   **Orchestration:** Kubernetes
*   **Metrics:** Prometheus
*   **Dashboards:** Grafana
*   **Logs:** Cloud Logging, Splunk
*   **Access Control:** `kubectl port-forward`

## 🛠️ Phase 1 — Step-by-Step Implementation

### Step 1 — Tool Validation
*Purpose: Ensures all required tooling is installed and compatible before provisioning.*
```sh
gcloud version
kubectl version --client
terraform version
helm version
```

### Step 2 — GCP Authentication
*Purpose: Establishes authenticated access to GCP APIs and GKE.*
```sh
gcloud auth login
gcloud config set project <PROJECT_ID>
```

### Step 3 — Infrastructure Provisioning (Terraform)
*Purpose: Creates the GKE cluster and worker node pool required to schedule workloads.*
```sh
terraform init
terraform plan
terraform apply
```

### Step 4 — Cluster Access Configuration
*Purpose: Configures `kubectl` to securely communicate with the GKE API server.*
```sh
gcloud container clusters get-credentials sre-cluster --region us-central1
```

### Step 5 — Cluster Validation
*Expected Outcome: Nodes are in `Ready` state and core system pods are `Running`.*
```sh
kubectl get nodes
kubectl get pods -A
```

### Step 6 — Application Deployment
*Purpose: Deploys a sample microservice into a dedicated namespace.*
```sh
kubectl apply -f manifests/
```

### Step 7 — Application Validation
*Purpose: Confirms that the workload is running and emitting logs.*
```sh
kubectl get pods -n sre-demo
kubectl get svc -n sre-demo
kubectl logs -n sre-demo -l app=sre-demo
```

### Step 8 — Observability Stack Installation
*Purpose: Installs Prometheus and Grafana inside the cluster with Kubernetes-native discovery.*
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
```

### Step 9 — Grafana Secure Access
*Purpose: Provides secure, temporary access to dashboards without public exposure.*

1.  **Forward the port:**
    ```sh
kubectl port-forward -n default svc/monitoring-grafana 3000:80
    ```
2.  **Open in browser:** `http://localhost:3000`
3.  **Retrieve admin password:**
    ```sh
kubectl get secret monitoring-grafana -n default \
-o jsonpath="{.data.admin-password}" | base64 --decode
    ```

### Step 10 — Dashboard Creation (Golden Signals)
*Purpose: Enables real-time visibility into service health.*
Dashboards created for:
*   CPU usage (saturation)
*   Memory usage
*   Pod availability
*   Pod restarts

### Step 11 — Incident Simulation
*Observed: Automatic pod recovery, metric spikes in Grafana, and no service outage.*
*   **Pod failure:**
    ```sh
    kubectl delete pod -n sre-demo -l app=sre-demo
    ``` 
*   **CPU saturation:**
    ```sh
    kubectl exec -n sre-demo <pod> -- sh -c "yes > /dev/null"
    ```

### Step 12 — Logs Validation
*Principle: Metrics detect incidents. Logs explain them.*

Logs were viewed using:
*   `kubectl logs`
*   GCP Cloud Logging (Logs Explorer)
*   Splunk dashboards

## 📊 Phase 1 Outcome
✅ Infrastructure stable
✅ Metrics visible and validated
✅ Logs accessible across tools
✅ Failures detected and recovered
✅ Observability verified through real incidents

**Phase 1 is complete and locked.**

## 🚧 Appendix — Errors Encountered & Resolutions

This section documents all issues encountered, their root causes, resolutions, and preventive actions.

### Issue 1 — GCP Authentication Failure
*   **Error**: `Error saving Application Default Credentials (permission denied)`
*   **Root Cause**: Locked `legacy_credentials` directory on Windows.
*   **Resolution**: Removed stale credentials and re-authenticated in a non-admin shell.
*   **Prevention**: Avoid mixing admin/non-admin terminals; periodically clean stale credentials.

### Issue 2 — Pods Stuck in Pending
*   **Error**: All pods in `Pending` state.
*   **Root Cause**: No worker node pool was created.
*   **Resolution**: Added an explicit GKE node pool and adjusted disk size to avoid SSD quota limits.
*   **Prevention**: Always validate node pools after cluster creation; pre-check GCP quotas.

### Issue 3 — kubectl Authentication Errors
*   **Errors**: Username/password prompts; `the server doesn't have a resource type "pods"`.
*   **Root Causes**: Missing GKE auth plugin; corrupted `kubeconfig` file; VS Code terminal environment mismatch.
*   **Resolution**: Installed `gke-gcloud-auth-plugin`, cleaned `kubeconfig`, and restarted VS Code.
*   **Prevention**: Standardize CLI setup; restart terminals after auth changes.

### Issue 4 — Namespace Confusion
*   **Error**: `No resources found in default namespace`.
*   **Root Cause**: Application deployed in `sre-demo` namespace.
*   **Resolution**: Explicitly specified the namespace in all commands.
*   **Prevention**: Never rely on the `default` namespace in production.

### Issue 5 — Grafana & Prometheus Connectivity
*   **Errors**: `localhost:3000 connection refused`; Prometheus datasource DNS lookup failure.
*   **Root Causes**: `port-forward` not running; incorrect service DNS; namespace mismatch.
*   **Resolution**: Used `kubectl port-forward` and corrected the datasource to a fully qualified Kubernetes DNS.
*   **Prevention**: Always use namespace-qualified service names; remember `port-forward` must stay active.

## 🧠 Key Learnings
*   Reliability is validated through failure.
*   Node pools are mandatory for scheduling.
*   Kubernetes DNS is namespace-scoped.
*   Tooling issues are real production incidents.
*   Observability must be tested, not assumed.

## 🚀 Next Phase

Phase 1 answered: “Can the system run reliably?”

Phase 2 will answer: “Can the system change safely?”

**Upcoming:**
*   SLOs and SLIs
*   Error budgets
*   Canary deployments
*   Release safety gates

## 📌 Closing Note
This Phase 1 implementation represents real Site Reliability Engineering work, not a theoretical or tutorial-based exercise. Every component was validated through hands-on execution, every failure was investigated with a blameless mindset, and every fix was documented to prevent recurrence. The outcome is a secure, observable, and operationally reliable Kubernetes foundation that mirrors real production environments.

With Phase 1 complete and locked, the platform is now ready to evolve into SLO-driven delivery and safe change management in Phase 2. The lessons, patterns, and operational discipline established here form a durable baseline for scaling reliability, introducing controlled rollouts, and aligning engineering outcomes with business expectations.

**Reliability is not a feature — it is a continuous practice.**
