# Error Budget Policy

**Version 1.0**

This document defines the policy for how the service's error budget is consumed to make data-driven decisions about software deployments.

---

## 1. Service Level Objective (SLO)

The primary SLO that governs this policy is **Availability**.

*   **SLO:** `99.9%` availability, measured over a rolling 30-day window.
*   **Measurement:** Availability is measured by the ratio of successful requests to total requests, as monitored by Prometheus.

## 2. What is an Error Budget?

An error budget is the maximum amount of time a service can be unavailable or degraded without violating its SLO. It is the mathematical inverse of the SLO.

*   **SLO:** `99.9%`
*   **Error Budget:** `1 - 99.9% = 0.1%`

### How is the Budget Calculated?

For a 30-day window (approximately 43,200 minutes):

*   **Total Allowed Downtime:** `43,200 minutes * 0.1% = 43.2 minutes`

This budget of **43.2 minutes** is the total time our users can experience failures over a 30-day period. This includes everything from minor bugs to full outages. We "spend" this budget whenever we cause user-facing errors.

## 3. Policy Rules

The rate at which we burn our error budget dictates the risk we are allowed to take with new deployments.

---

### ✅ **State: Green**
*   **Condition:** Less than `50%` of the monthly error budget has been consumed.
*   **Allowed Actions:** Normal deployments (canary, blue-green, or rolling updates) are permitted. The release velocity is not restricted by reliability concerns.

### ⚠️ **State: Yellow**
*   **Condition:** Between `50%` and `75%` of the monthly error budget has been consumed.
*   **Allowed Actions:** All deployments **must** be `canary-only`. Standard rolling updates are forbidden. This policy enforces a "go slow" approach, as we have less room for error. The blast radius of any change must be minimized.

### 🛑 **State: Red**
*   **Condition:** More than `75%` of the monthly error budget has been consumed.
*   **Allowed Actions:** A **deployment freeze** is in effect for all new features. The only changes permitted are emergency bug fixes or reliability improvements aimed at protecting the remaining budget. All engineering focus shifts from feature development to reliability.

## 4. Enforcement

This policy is not a manual process. It is automatically enforced by the Argo Rollouts `AnalysisTemplate`, which queries Prometheus during canary deployments. If a new release burns the error budget at an unacceptable rate, the rollout is automatically aborted and rolled back without human intervention.
