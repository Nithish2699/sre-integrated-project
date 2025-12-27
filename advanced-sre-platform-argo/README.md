
# Advanced SRE Platform (Argo Rollouts)

This platform demonstrates safe release engineering using canary deployments,
CI/CD automation, and SLO-based error-budget gating.

## Step 1 — Install Argo Rollouts
Installs the controller that manages progressive delivery.
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
