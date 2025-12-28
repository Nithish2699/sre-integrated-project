# Blameless Postmortem: Canary Deployment Rollback due to SLO Violation

**Date:** 2025-12-28

**Authors:** SRE Team

## 1. Summary

A new version of the `sre-demo` service (`nginx:1.25.3`) was deployed via the automated CI/CD pipeline. The Argo Rollouts controller initiated a canary release, shifting 20% of user traffic to the new version. The integrated analysis step detected a sharp increase in HTTP 500 errors, which began to burn the monthly error budget at an unsustainable rate. The system automatically aborted the rollout, shifted all traffic back to the stable version, and triggered an alert.

**No human intervention was required for the rollback.**

## 2. Impact

*   **Customer Impact:** Approximately 20% of users experienced intermittent HTTP 500 errors for a duration of 5 minutes.
*   **SLO Impact:** The monthly availability SLO of 99.9% was impacted. `2.5 minutes` of the `43.2 minute` monthly error budget was consumed during the incident.
*   **System Impact:** The `sre-demo` service remained available for 80% of users throughout the incident. The stable version was unaffected.

## 3. Root Causes

*   **Direct Cause:** The new container image (`nginx:1.25.3`) contained a misconfigured reverse proxy setting that caused a segmentation fault under load, leading to HTTP 500 responses.
*   **Detection:** The failure was automatically detected by the Argo Rollouts `AnalysisTemplate`, which queried the following Prometheus metric:
    ```promql
    sum(rate(nginx_http_requests_total{status=~"5..", service="sre-demo-canary"}[1m]))
    ```
*   **Why it was not caught earlier:** The bug only manifested under production traffic patterns, which were not fully replicated in the staging environment.

## 4. Timeline of Events (UTC)

*   `14:30` - CI pipeline successfully builds and pushes `nginx:1.25.3`.
*   `14:31` - Argo Rollouts controller detects the new image and starts the canary deployment.
*   `14:32` - Canary `ReplicaSet` is healthy. Traffic shifting begins, with 20% of traffic routed to the canary.
*   `14:33` - The first `AnalysisRun` begins. Prometheus metrics show a spike in 5xx errors from the canary pods.
*   `14:36` - The `AnalysisRun` fails because the error rate exceeds the threshold defined in the `AnalysisTemplate`.
*   `14:37` - **AUTOMATIC ACTION:** Argo Rollouts aborts the deployment and immediately scales down the canary `ReplicaSet`. All traffic is restored to the stable version.
*   `14:38` - PagerDuty alert fires, notifying the on-call engineer that a deployment has been automatically rolled back.
*   `14:45` - On-call engineer confirms the system is stable and begins investigation.

## 5. Lessons Learned

*   **What went well:** The automated safety mechanism worked exactly as designed. The "blast radius" was contained to a small subset of users, and the system self-healed without human intervention, protecting the SLO.
*   **What could be improved:** Our pre-production testing environment needs to better simulate production traffic patterns to catch these types of load-dependent bugs earlier.

## 6. Action Items

| # | Action Item | Owner | Due Date |
|---|---|---|---|
| 1 | Fix the reverse proxy configuration in the application code. | `dev-team` | 2025-12-29 |
| 2 | Investigate and implement a traffic mirroring tool in staging to better replicate production load. | `sre-team` | 2026-01-15 |
| 3 | Review and lower the analysis step duration from 5 minutes to 2 minutes to reduce error budget burn during a faulty deployment. | `sre-team` | 2025-12-30 |

---