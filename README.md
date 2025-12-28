# Integrated SRE Platform Repository

This repository demonstrates a staged, production-focused Site Reliability Engineering (SRE) implementation: from foundational operations to advanced progressive delivery and policy-driven deployments.

Repository structure
- Phase 1 — foundation-sre-platform/  
  → Core SRE foundations (infrastructure, Kubernetes, observability, incidents)
- Phase 2 — advanced-sre-platform-argo/  
  → Advanced SRE practices (canary deployments, Argo Rollouts, CI/CD, error budgets)
<img width="1536" height="1024" alt="ChatGPT Image Dec 28, 2025, 10_59_19 PM" src="https://github.com/user-attachments/assets/9d76e4b5-49c4-4fe3-b62a-a388f1654165" />

Quick links
- Phase 1 — Foundation SRE Platform  
  👉 `foundation-sre-platform/`
- Phase 2 — Advanced SRE Platform (Argo Rollouts)  
  👉 `advanced-sre-platform-argo/`
- Example postmortem  
  👉 `foundation-sre-platform/postmortems/real-postmortem.md`
- Error budget policy  
  👉 `advanced-sre-platform-argo/policy/error-budget-policy.md`

Overview
Goal:
Build a production-grade SRE platform that demonstrates:
- Infrastructure ownership and reproducible provisioning
- Kubernetes reliability operations and safe application deployment
- Observability and incident response processes
- Safe, automated deployments governed by SLOs and error budgets

Why two phases?
SRE maturity is progressive: first establish stable, observable systems (Phase 1), then enable safe and automated change with policy and progressive delivery (Phase 2).

—-

PHASE 1 — FOUNDATION SRE PLATFORM
Folder: `foundation-sre-platform/`

Objective
Establish core SRE fundamentals required to operate production systems reliably:
- Provision infrastructure (Infrastructure as Code)
- Deploy and manage services on Kubernetes
- Collect metrics and logs, create dashboards and alerts
- Handle incidents and run blameless postmortems

Highlights / Recommended workflow

1. Provision infrastructure (Terraform)
- What: Create a reproducible Kubernetes cluster and required cloud resources.
- Commands:
  ```bash
  cd foundation-sre-platform
  # or to the terraform folder
  cd foundation-sre-platform/terraform
  terraform init
  terraform apply
  ```

2. Configure cluster access
- Example (GKE):
  ```bash
  gcloud container clusters get-credentials sre-cluster --region us-central1
  # or set up kubeconfig manually:
  kubectl config set-cluster sre-cluster --server=<API_SERVER_URL>
  ```

3. Deploy the application
- Deploy application manifests with health/readiness probes so Kubernetes can self-heal:
  ```bash
  kubectl apply -f foundation-sre-platform/kubernetes/
  ```

4. Install observability (Prometheus & Grafana)
- Install monitoring stack via Helm:
  ```bash
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
  helm install monitoring prometheus-community/kube-prometheus-stack
  ```

5. Inspect metrics & logs
- Port-forward Grafana and view dashboards:
  ```bash
  kubectl port-forward svc/monitoring-grafana 3000:80
  kubectl logs <pod-name>
  ```

6. Simulate incidents (safely)
- Example: inject CPU stress to verify autoscaling and alerting:
  ```bash
  kubectl exec -it <pod-name> -- stress-ng --cpu 2 --timeout 60s
  ```

7. Blameless postmortem
- Document incidents and remediation; see example:
  `foundation-sre-platform/postmortems/real-postmortem.md`

—-

PHASE 2 — ADVANCED SRE PLATFORM (ARGO)
Folder: `advanced-sre-platform-argo/`

Objective
Introduce safe progressive delivery and policy-driven deployment decisions:
- Canary releases and progressive traffic shifting
- SLO-based automation and error-budget gating
- CI/CD-driven deployments with automated promotion/rollback

Highlights / Recommended workflow

1. Install Argo Rollouts
```bash
# Create the namespace for Argo Rollouts
kubectl create namespace argo-rollouts

# Install the core Argo Rollouts controller
kubectl apply -n argo-rollouts \
  -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

### Step 1a — Install Dashboard & CLI Plugin

What:
Install the UI dashboard and the `kubectl` plugin for easier management.

Why:
The dashboard provides essential real-time visualization of canary releases.

Commands:
```bash
# Install the dashboard components
kubectl apply -n argo-rollouts \
  -f https://github.com/argoproj/argo-rollouts/releases/latest/download/dashboard-install.yaml

# Install the kubectl plugin (for commands like `kubectl argo rollouts dashboard`)
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
```

### Step 2 — Deploy Rollout (Canary Strategy)

What:  
Define a rollout that shifts traffic gradually.

Why:  
Small exposure reduces blast radius during failures.

Command:
```bash
kubectl apply -f advanced-sre-platform-argo/argo-rollouts/
```

### Step 3 — Traffic Shifting

What:  
Send 20% → 50% → 100% traffic to the new version.

Why:  
Gradual rollout detects issues early.

(Note: traffic progression is controlled by Argo Rollouts and configured strategies.)

### Step 4 — SLO Burn-Rate Analysis

What:
Evaluate Prometheus metrics during rollout.

Why:  
Deployments should stop when error budgets are at risk.

(Defined in analysis-template.yaml)

### Step 5 — CI/CD Trigger

What:  
CI pipeline updates rollout image automatically.

Why:  
CI triggers deployments, not reliability decisions.

Example command:
```bash
kubectl argo rollouts set image sre-demo-rollout app=nginx:1.25.3
```

6. Automatic rollback or promotion
- Argo Rollouts + SLO analysis can automatically promote a candidate version or rollback based on configured policies and metrics.

7. Error budget policy
- Policy that ties deployment behavior to business risk tolerance:
  `advanced-sre-platform-argo/policy/error-budget-policy.md`

—-

Repository conventions and notes
- Everything is organized to be reproducible and auditable — manifests, Terraform, analysis templates, and policy documents are tracked.
- Whenever possible, favor automation that enforces reliability decisions (e.g., automated SLO checks) rather than manual gates.
- Keep postmortems blameless and action-oriented: identify root causes and remediation tasks.

Suggested next steps (if you want me to apply changes)
- I can update this README in a new branch and open a pull request. Tell me:
  1. Commit directly to `main` (not recommended), or
  2. Create a branch (e.g., `docs/readme-update`) and open a PR (recommended).
- If you have specific additions from your "latest changes" (new folders, new scripts, CI workflows, or updated paths), paste them here and I will incorporate them into the README before committing.

Thanks — tell me if you'd like me to (A) commit the proposed README to a branch and open a PR, (B) apply directly to main, or (C) make further edits first.
```
