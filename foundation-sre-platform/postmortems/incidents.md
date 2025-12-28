# 📕 Phase 1 — Production Incidents (Blameless)

This document captures **all production incidents encountered in Phase 1** after the application was live.  
Each incident is documented using **SRE best practices**, with a focus on **impact, detection, root cause, resolution, and prevention**.

> **Blameless principle:** Incidents are treated as system learning opportunities, not human failures.

---

## 🟡 Incident 1 — Pod Restarts During High Traffic

**Incident ID:** SRE-P1-001  
**Severity:** SEV-2 (Service Degradation)  
**Service:** sre-demo-service  
**Status:** Resolved  
**Duration:** ~12 minutes  

---

### Summary

Shortly after the application went live, the service experienced **multiple pod restarts** during a sudden increase in traffic.  
The service remained available, but pod instability required investigation.

---

### Impact

- No downtime
- Temporary increase in latency
- Reduced redundancy while pods restarted

---

### Detection

- Grafana dashboards showed:
  - Increase in pod restart count
  - CPU and memory spikes
- No alerts fired (Phase 1 relied on dashboards)

---

### Root Cause

Pods exceeded configured **memory limits** under load, resulting in **OOMKills** and automatic restarts by Kubernetes.

---

### Resolution

- Kubernetes automatically restarted affected pods
- Replica count ensured service continuity
- Traffic normalized without manual intervention

---

### Prevention

- Increased memory limits based on observed usage
- Added memory utilization panels to Grafana
- Documented resource tuning guidelines

---

### Key Learning

> Resource limits must be validated under real traffic conditions, not assumed safe at deploy time.

---

---

## 🟡 Incident 2 — High Memory Pressure Requiring Scale-Up (Zero Downtime)

**Incident ID:** SRE-P1-002  
**Severity:** SEV-2 (Performance Degradation)  
**Service:** sre-demo-service  
**Status:** Resolved  
**Duration:** ~15 minutes  

---

### Summary

During sustained high traffic, memory usage steadily increased and approached critical thresholds.  
The service required **horizontal scaling under pressure**, while maintaining **zero downtime**.

---

### Impact

- Slight increase in response latency
- No request failures
- No downtime

---

### Detection

- Grafana memory usage crossed 75%
- Pod availability remained healthy
- No restarts observed

---

### Root Cause

The application was deployed with a **static replica count**, which was insufficient for peak traffic patterns.

---

### Resolution

Manual scale-up was performed:

```bash
kubectl scale deployment sre-demo -n sre-demo --replicas=4
```

Traffic redistributed across additional pods.
Memory usage stabilized.
Existing pods were not restarted.

### Prevention

- Introduce Horizontal Pod Autoscaler (HPA) in Phase 2
- Define memory-based scaling thresholds
- Track saturation trends over time

### Key Learning

> Scaling early prevents failures; scaling late only recovers from them.

# 🔴 Incident 3 — Full GKE Cluster Outage (SEV-1)

**Incident ID:** SRE-SEV1-003  
**Severity:** SEV-1 (Complete Service Outage)  
**Service:** sre-demo-platform  
**Status:** Resolved  
**Impact Duration:** ~28 minutes  

---

## 📌 Executive Summary

A **full Google Kubernetes Engine (GKE) cluster outage** resulted in **100% service unavailability** for all users.  
The outage was triggered by **node pool exhaustion without autoscaling safeguards**, which prevented Kubernetes from scheduling or rescheduling workloads during a traffic spike.

The incident was detected quickly, mitigated within SLA, and followed by permanent corrective actions to prevent recurrence.

---

## 👥 User Impact

- All user requests failed
- Application endpoints were unreachable
- Business operations were temporarily blocked
- No data loss occurred

---

## ⏱ Timeline (UTC)

| Time | Event |
|---|---|
| T0 | Sudden traffic spike begins |
| T+2m | Health checks start failing |
| T+4m | Grafana shows zero pod availability |
| T+6m | Kubernetes API becomes unstable |
| T+10m | Root cause identified |
| T+18m | Node pool capacity increased |
| T+28m | All services fully restored |

---

## 🚨 Detection

The incident was detected through multiple signals:

- Synthetic health checks failed
- Grafana dashboards showed:
  - Node CPU and memory saturation
  - Pods stuck in `Pending` / `Unschedulable` state
- Cloud Logging indicated node-level resource exhaustion

---

## 🔍 Root Cause

The GKE cluster was operating with the following constraints:

- Fixed-size node pool
- Cluster Autoscaler disabled
- No minimum node safety buffer

When traffic increased sharply, node resources were exhausted.  
Kubernetes was unable to schedule new pods or recover existing ones, resulting in a **cluster-wide service outage**.

---

## 🛠 Resolution

Immediate remediation steps were executed to restore service availability.

### 1. Restore cluster access
```bash
gcloud container clusters get-credentials sre-cluster --region us-central1
```

### 2. Resize the Node Pool

```bash
gcloud container node-pools resize sre-node-pool \
  --cluster sre-cluster \
  --region us-central1 \
  --num-nodes=3
```

### 3. Verify Cluster State

```bash
kubectl get nodes
kubectl get pods -A
```

Service health was confirmed using Grafana dashboards and application health checks.

---

### 🛡 Corrective and Preventive Actions

**Infrastructure Improvements**

- Enabled GKE Cluster Autoscaler
- Defined a minimum node pool size to handle traffic spikes

**Observability Enhancements**

- Added node saturation dashboards
- Added pod unschedulable indicators

**Process Improvements**

- Created SEV-1 incident runbooks.
- Documented cluster capacity planning standards

### ✅ What Went Well

- Rapid detection using observability dashboards
- Clear ownership and response during the incident
- Recovery completed within acceptable SLA

### ❌ What Didn’t Go Well

- Lack of automated node scaling
- Limited early warning for node exhaustion

### 🧾 Blameless Conclusion

This incident was caused by system design gaps, not individual mistakes.
The remediation focused on making the platform resilient by default, ensuring that similar failures are automatically absorbed in the future.

Systems should be designed to survive unexpected load, not react to it.

### 📌 Key Learning

> Cluster-level reliability is as critical as application-level reliability. Autoscaling is not an optimization—it is a requirement.
