# Advanced SRE Platform (Argo Rollouts)

This directory contains the implementation for **Phase 2** of the SRE platform, focusing on safe, automated deployments using Argo Rollouts.

The primary goal is to govern change without compromising the reliability established in Phase 1. This is achieved through canary releases, progressive traffic shifting, and SLO-based analysis.

---

## 📜 Key Documents

*   **[Error Budget Policy](./policy/error-budget-policy.md):** Defines the rules that govern deployment velocity based on remaining reliability.
*   **[Canary Failure Postmortem](./postmortems/canary-deployment-postmortem.md):** An example of how to document and learn from an automatically rolled-back deployment.

---

## �️ Phase 2 — Step-by-Step Implementation

### Step 1 — Install Argo Rollouts Controller

**What:** Installs the core controller that manages progressive delivery strategies.

**Why:** The controller replaces standard Kubernetes rolling updates with advanced deployment patterns like canary, enabling controlled and safe releases.

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

## Step 2 — Deploy Rollout (Canary Strategy)
Releases a new version gradually instead of all at once.
```bash
kubectl apply -f argo-rollouts/
```

## Step 3 — Traffic Shifting
Routes a small percentage of traffic to the canary while protecting stable users.

## Step 4 — SLO Burn-Rate Analysis
Evaluates Prometheus metrics to decide whether to promote or rollback.

## Step 5 — CI/CD Trigger
Automatically updates the rollout image on every main-branch push.
```bash
kubectl set image rollout/sre-demo-rollout app=nginx:latest
```

## Step 6 — Automatic Rollback or Promotion
Stops the rollout if the error budget is threatened, otherwise promotes safely.
