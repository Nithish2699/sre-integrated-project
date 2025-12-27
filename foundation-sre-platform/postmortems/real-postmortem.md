
Summary:
Latency spike caused by CPU saturation during traffic surge.

Impact:
p95 latency breached SLO for 7 minutes.

Root Cause:
Autoscaling thresholds not tuned for sudden load.

Action Items:
Tune HPA and add burn-rate alerting.
