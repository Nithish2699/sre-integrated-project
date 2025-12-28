# Integrated SRE Platform Repository

This repository contains two clearly separated SRE implementations:

1. `foundation-sre-platform`  
   → Core SRE foundations (infra, Kubernetes, observability, incidents)

2. `advanced-sre-platform-argo`  
   → Advanced SRE practices (canary deployments, Argo Rollouts, CI/CD, error budgets)

🚀 End-to-End SRE Platform: From Foundations to Advanced Reliability

This repository documents my complete SRE implementation journey, showing how I evolved from operating Kubernetes systems to enforcing reliability during deployments using canary releases and error budgets.

The project is intentionally split into two phases, each representing a clear maturity step in Site Reliability Engineering.

Repository Navigation (Click to Jump)
- Phase 1 — Foundation SRE Platform  
  👉 `foundation-sre-platform/`
- Phase 2 — Advanced SRE Platform (Argo Rollouts)  
  👉 `advanced-sre-platform-argo/`
- Incident Postmortem Example  
  👉 `foundation-sre-platform/postmortems/real-postmortem.md`
- Error Budget Policy  
  👉 `advanced-sre-platform-argo/policy/error-budget-policy.md`

---

## Project Overview

Goal:

Build a production-grade SRE platform that demonstrates:
- Infrastructure ownership
- Kubernetes reliability operations
- Observability and incident response
- Safe, automated deployments using SLOs and error budgets

Why two phases?

Because real SRE maturity is progressive. You must first run systems reliably before you can automate change safely.

---

## 🟢 PHASE 1 — FOUNDATION SRE PLATFORM

Folder:
👉 `foundation-sre-platform/`

### Phase 1 Objective

Establish core SRE fundamentals required to operate production systems reliably:
- Provision infrastructure
- Deploy services
- Monitor health
- Handle incidents
- Learn from failures

This phase focuses on stability before speed.

### Step 1 — Provision Infrastructure (Terraform)

What:  
Create a reproducible Kubernetes cluster using Infrastructure as Code.

Why:  
Manual infrastructure does not scale and is error-prone.

Commands:
```bash
cd foundation-sre-platform
# or
cd foundation-sre-platform/terraform
terraform init
terraform apply
```

### Step 2 — Configure Cluster Access

What:  
Configure `kubectl` access to manage workloads.

Why:  
Secure access is required to deploy and operate services.

Command example:
```bash
# Example (GKE):
gcloud container clusters get-credentials sre-cluster --region us-central1
# or set up kubeconfig manually:
kubectl config set-cluster sre-cluster --server=<API_SERVER_URL>
```

### Step 3 — Deploy Application (Kubernetes)

What:  
Deploy a containerized application with health checks.

Why:  
Health probes enable self-healing and safe restarts.

Command:
```bash
kubectl apply -f foundation-sre-platform/kubernetes/
```

### Step 4 — Install Observability (Prometheus & Grafana)

What:  
Install metrics collection and dashboards.

Why:  
You cannot operate what you cannot observe.

Commands:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
```

### Step 5 — Observe Metrics & Logs

What:  
View latency, errors, traffic, and resource usage.

Why:  
Metrics and logs are required for debugging and incident detection.

Commands:
```bash
kubectl port-forward svc/monitoring-grafana 3000:80
kubectl logs <pod-name>
```

### Step 6 — Simulate Incident

What:  
Inject CPU stress into a running pod.

Why:  
Controlled failure validates autoscaling and monitoring.

Command:
```bash
kubectl exec -it <pod-name> -- stress-ng --cpu 2 --timeout 60s
```

### Step 7 — Blameless Postmortem

What:  
Document what happened, why it happened, and how to prevent it.

Why:  
SRE improves systems, not people.

👉 Example postmortem: `foundation-sre-platform/postmortems/real-postmortem.md`

---

## WHY MOVE TO PHASE 2?

After Phase 1, the system was stable and observable.

However, a critical question remained:

How do we release changes without breaking reliability?

Manual deployments and blind rollouts increase risk as systems grow. This is where Phase 2 begins.

---

## PHASE 2 — ADVANCED SRE PLATFORM (ARGO)

Folder:
👉 `advanced-sre-platform-argo/`

### Phase 2 Objective

Enforce safe, automated deployments using:
- Canary releases
- Progressive traffic shifting
- SLO-based error-budget gating
- CI/CD automation

This phase focuses on governing change, not just deploying it.

### Step 1 — Install Argo Rollouts

What:  
Install the controller responsible for progressive delivery.

Why:  
Argo Rollouts replaces risky full rollouts with controlled canaries.

Commands:
```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts \
  -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
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

(Analysis templates are defined in `analysis-template.yaml`.)

### Step 5 — CI/CD Trigger

What:  
CI pipeline updates rollout image automatically.

Why:  
CI triggers deployments, not reliability decisions.

Example command:
```bash
kubectl set image rollout/sre-demo-rollout app=nginx:latest
```

### Step 6 — Automatic Rollback or Promotion

What:  
Rollout is promoted or aborted automatically.

Why:  
Reliability must not depend on human reaction time.

(Handled by Argo Rollouts + SLO analysis.)

### Step 7 — Error Budget Policy

What:  
Define rules that control deployment behavior.

Why:  
Error budgets align reliability with business priorities.

👉 Policy: `advanced-sre-platform-argo/policy/error-budget-policy.md`

---

If you want, I can commit this README.md to your repository or create a branch and open a PR. Tell me how you'd like to proceed.
