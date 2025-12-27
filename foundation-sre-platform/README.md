
# Foundation SRE Platform

This platform demonstrates core Site Reliability Engineering responsibilities:
infrastructure ownership, Kubernetes operations, observability, and incident handling.

## Step 1 — Provision Infrastructure (Terraform)
Creates a reproducible GKE cluster using Infrastructure as Code to avoid manual changes.
```bash
cd terraform
terraform init
terraform apply
```

## Step 2 — Configure Cluster Access
Grants kubectl access so workloads can be deployed securely to the cluster.
```bash
gcloud container clusters get-credentials sre-cluster --region us-central1
```

## Step 3 — Deploy Application (Kubernetes)
Deploys a containerized service with health checks for self-healing.
```bash
kubectl apply -f kubernetes/
```

## Step 4 — Install Monitoring (Prometheus & Grafana)
Sets up metrics collection and dashboards for system visibility.
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
```

## Step 5 — Observe Metrics and Logs
Allows engineers to correlate performance issues using metrics and logs.
```bash
kubectl port-forward svc/monitoring-grafana 3000:80
kubectl logs <pod-name>
```

## Step 6 — Simulate Incident
Introduces controlled failure to validate autoscaling and alerting.
```bash
kubectl exec -it <pod-name> -- stress-ng --cpu 2 --timeout 60s
```

## Step 7 — Postmortem
Documents the incident in a blameless way to prevent recurrence.
