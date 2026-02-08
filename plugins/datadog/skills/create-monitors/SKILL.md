# Skill: Create Datadog Monitors

Create and configure Datadog monitors to detect and alert on application performance issues, errors, and infrastructure problems. This skill covers metric monitors, APM monitors, log monitors, and composite monitors.

## Prerequisites

- A Datadog account with the Datadog Agent running and collecting data
- Admin or Standard role in the Datadog organization (required to create monitors)
- Notification integrations configured (Slack, PagerDuty, email, etc.) under **Integrations → Integrations**
- An API key and Application key for programmatic monitor creation (found in **Organization Settings → API Keys** and **Application Keys**)

## Environment Variables

```bash
DD_API_KEY=your-datadog-api-key
DD_APP_KEY=your-datadog-app-key
DD_SITE=datadoghq.com  # or datadoghq.eu, us3.datadoghq.com, etc.
```

---

## Metric Monitors

Metric monitors alert when a metric crosses a threshold. They are the most common and versatile monitor type.

### Creating a Metric Monitor (UI)

1. Go to **Monitors → New Monitor → Metric**.
2. Choose the detection method:
   - **Threshold** — Alert when a metric is above/below a static value.
   - **Change** — Alert when a metric changes by a percentage or absolute value.
   - **Anomaly** — Alert when a metric deviates from its expected behavior.
   - **Forecast** — Alert when a metric is predicted to cross a threshold.
   - **Outlier** — Alert when a member of a group behaves differently from its peers.
3. Define the metric query, thresholds, and notification settings.

### Creating a Metric Monitor (API)

```bash
curl -X POST "https://api.${DD_SITE}/api/v1/monitor" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "High CPU Usage — {{host.name}}",
    "type": "metric alert",
    "query": "avg(last_5m):avg:system.cpu.user{service:my-api} by {host} > 90",
    "message": "CPU usage on {{host.name}} is above {{threshold}}%.\n\nCurrent value: {{value}}%\n\n@slack-sre-alerts @pagerduty-on-call",
    "tags": ["service:my-api", "team:backend", "env:production"],
    "options": {
      "thresholds": {
        "critical": 90,
        "warning": 70,
        "critical_recovery": 80,
        "warning_recovery": 60
      },
      "notify_no_data": true,
      "no_data_timeframe": 10,
      "renotify_interval": 60,
      "escalation_message": "CPU is still critically high on {{host.name}} — escalating.\n\n@pagerduty-sre-escalation",
      "include_tags": true,
      "evaluation_delay": 60
    }
  }'
```

### Recommended Metric Monitors

#### 1. High CPU Usage

```
avg(last_5m):avg:system.cpu.user{service:my-api} by {host} > 90
```
- **Warning:** 70% | **Critical:** 90%
- **Notification:** Slack (warning), PagerDuty (critical)

#### 2. Memory Usage

```
avg(last_5m):avg:system.mem.pct_usable{service:my-api} by {host} < 10
```
- **Warning:** < 20% available | **Critical:** < 10% available
- **Notification:** Slack + email

#### 3. Disk Space

```
avg(last_15m):avg:system.disk.in_use{service:my-api} by {host,device} > 90
```
- **Warning:** 80% | **Critical:** 90%
- **Notification:** Slack (warning), PagerDuty (critical)

#### 4. Custom Business Metric

```
sum(last_5m):sum:orders.created{env:production}.as_count() < 1
```
- **Critical:** No orders in 5 minutes during business hours
- **Notification:** Slack #revenue-alerts + PagerDuty

---

## APM Monitors

APM monitors alert on trace-based metrics — latency, error rate, and request volume for specific services and endpoints.

### Creating an APM Monitor (UI)

1. Go to **Monitors → New Monitor → APM**.
2. Select the service and optional resource (endpoint).
3. Choose the metric: Requests, Errors, Latency (p50/p75/p95/p99), or Error Rate.
4. Set thresholds, evaluation window, and notifications.

### Creating an APM Monitor (API)

```bash
curl -X POST "https://api.${DD_SITE}/api/v1/monitor" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "High P95 Latency — my-api",
    "type": "query alert",
    "query": "percentile(last_5m):p95:trace.express.request{service:my-api,env:production} > 5000000000",
    "message": "P95 latency for my-api is above {{threshold_s}}s (currently {{value_s}}s).\n\nCheck APM: https://app.datadoghq.com/apm/services/my-api\n\n@slack-backend-alerts",
    "tags": ["service:my-api", "team:backend"],
    "options": {
      "thresholds": {
        "critical": 5000000000,
        "warning": 2000000000
      },
      "notify_no_data": false,
      "renotify_interval": 30,
      "include_tags": true
    }
  }'
```

> **Note:** APM latency values are in nanoseconds (1 second = 1,000,000,000 ns).

### Recommended APM Monitors

#### 1. P95 Latency Spike

```
percentile(last_5m):p95:trace.express.request{service:my-api,env:production} > 5000000000
```
- **Warning:** > 2s | **Critical:** > 5s
- **Use case:** Detect endpoint performance regressions.

#### 2. Error Rate Surge

```
sum(last_5m):sum:trace.express.request.errors{service:my-api,env:production}.as_count() / sum:trace.express.request.hits{service:my-api,env:production}.as_count() * 100 > 15
```
- **Warning:** > 5% | **Critical:** > 15%
- **Use case:** Detect error spikes after deployments.

#### 3. Apdex Drop

```
avg(last_10m):avg:trace.express.request.apdex{service:my-api,env:production} < 0.7
```
- **Warning:** < 0.9 | **Critical:** < 0.7
- **Use case:** Detect overall user experience degradation.

#### 4. Low Request Volume (Service Down)

```
sum(last_5m):sum:trace.express.request.hits{service:my-api,env:production}.as_count() < 10
```
- **Critical:** Fewer than 10 requests in 5 minutes (during business hours)
- **Use case:** Detect service outages.

#### 5. Per-Endpoint Latency

```
percentile(last_5m):p95:trace.express.request{service:my-api,env:production,resource_name:post_/api/checkout} > 3000000000
```
- **Warning:** > 2s | **Critical:** > 3s
- **Use case:** Monitor critical business endpoints individually.

---

## Log Monitors

Log monitors alert based on log volume, patterns, or the absence of expected logs.

### Creating a Log Monitor (UI)

1. Go to **Monitors → New Monitor → Logs**.
2. Define the log query (same syntax as Log Explorer).
3. Choose the measure: Count, or a numeric attribute (for log-based metrics).
4. Set thresholds and notifications.

### Creating a Log Monitor (API)

```bash
curl -X POST "https://api.${DD_SITE}/api/v1/monitor" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "High Error Log Volume — my-api",
    "type": "log alert",
    "query": "logs(\"service:my-api status:error env:production\").index(\"*\").rollup(\"count\").last(\"5m\") > 200",
    "message": "Error log volume for my-api exceeded {{threshold}} in the last 5 minutes (currently {{value}}).\n\nCheck logs: https://app.datadoghq.com/logs?query=service%3Amy-api%20status%3Aerror\n\n@slack-backend-alerts",
    "tags": ["service:my-api", "team:backend"],
    "options": {
      "thresholds": {
        "critical": 200,
        "warning": 50
      },
      "notify_no_data": false,
      "renotify_interval": 60,
      "enable_logs_sample": true
    }
  }'
```

### Recommended Log Monitors

#### 1. Error Volume Spike

```
logs("service:my-api status:error env:production").index("*").rollup("count").last("5m") > 200
```
- **Warning:** > 50 | **Critical:** > 200
- **Use case:** Detect sudden increases in application errors.

#### 2. Specific Error Pattern

```
logs("service:my-api \"database connection refused\" env:production").index("*").rollup("count").last("5m") > 5
```
- **Critical:** > 5 occurrences in 5 minutes
- **Use case:** Detect database connectivity issues.

#### 3. Authentication Failures

```
logs("service:my-api @http.status_code:401 env:production").index("*").rollup("count").last("15m") > 100
```
- **Warning:** > 50 | **Critical:** > 100
- **Use case:** Detect brute-force attacks or auth service issues.

#### 4. Missing Expected Logs (Dead Letter)

```
logs("service:batch-processor \"job completed\" env:production").index("*").rollup("count").last("1h") < 1
```
- **Critical:** No "job completed" log in 1 hour
- **Use case:** Detect when scheduled jobs stop running.

#### 5. Slow Query Detection

```
logs("service:my-api @db.duration:>5000 env:production").index("*").rollup("count").last("5m") > 10
```
- **Warning:** > 5 | **Critical:** > 10
- **Use case:** Detect accumulation of slow database queries.

---

## Composite Monitors

Composite monitors combine multiple monitors using boolean logic to reduce alert noise and detect complex failure scenarios.

### Creating a Composite Monitor (UI)

1. Go to **Monitors → New Monitor → Composite**.
2. Select existing monitors (A, B, C, etc.).
3. Define the trigger condition using boolean operators: `A && B`, `A || B`, `A && !B`.
4. Set notifications.

### Creating a Composite Monitor (API)

```bash
curl -X POST "https://api.${DD_SITE}/api/v1/monitor" \
  -H "DD-API-KEY: ${DD_API_KEY}" \
  -H "DD-APPLICATION-KEY: ${DD_APP_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Service Degradation — High Latency AND High Error Rate",
    "type": "composite",
    "query": "<monitor_a_id> && <monitor_b_id>",
    "message": "my-api is experiencing BOTH high latency and elevated error rate — likely a significant service degradation.\n\nLatency monitor: {{#is_alert}}P95 latency is critically high.{{/is_alert}}\nError rate monitor: {{#is_alert}}Error rate exceeds threshold.{{/is_alert}}\n\n@pagerduty-on-call @slack-sre-alerts",
    "tags": ["service:my-api", "team:sre", "severity:critical"],
    "options": {
      "renotify_interval": 30
    }
  }'
```

### Recommended Composite Monitor Patterns

#### 1. Service Degradation (Latency + Errors)

**Trigger:** High latency AND high error rate
**Logic:** `latency_monitor && error_rate_monitor`
**Use case:** Only page on-call when both conditions are true — avoids false alarms from brief latency spikes or transient errors.

#### 2. Infra + App Correlation

**Trigger:** High CPU AND high request latency
**Logic:** `cpu_monitor && latency_monitor`
**Use case:** Confirms that infrastructure resource exhaustion is causing application-level impact.

#### 3. Multi-Service Failure

**Trigger:** Service A errors AND Service B errors
**Logic:** `service_a_errors && service_b_errors`
**Use case:** Detect cascading failures across dependent services.

#### 4. Deployment Canary

**Trigger:** New version error rate high AND old version error rate normal
**Logic:** `new_version_errors && !old_version_errors`
**Use case:** Detect issues isolated to a canary deployment.

---

## Alert Conditions and Thresholds

### Threshold Configuration

| Option | Description | Best Practice |
|---|---|---|
| `critical` | Triggers an alert notification | Set based on SLO violation threshold |
| `warning` | Triggers a warning notification | Set at 60–70% of the critical threshold |
| `critical_recovery` | Resolves the critical alert | Set slightly below critical to avoid flapping |
| `warning_recovery` | Resolves the warning alert | Set slightly below warning to avoid flapping |

### Evaluation Window

- **Last 5 minutes** — Good for latency and error rate monitors.
- **Last 15 minutes** — Good for resource utilization monitors.
- **Last 1 hour** — Good for business metric and batch job monitors.

### Evaluation Delay

- Set `evaluation_delay` (in seconds) to account for metric collection latency:
  - **Cloud metrics (AWS, GCP):** 600–900 seconds
  - **Agent metrics:** 60 seconds
  - **APM metrics:** 60 seconds
  - **Log metrics:** 120 seconds

---

## Notifications and Escalation

### Message Syntax

Datadog monitor messages support Markdown, template variables, and conditional blocks:

```markdown
## {{#is_alert}}🔴 CRITICAL{{/is_alert}}{{#is_warning}}🟡 WARNING{{/is_warning}}{{#is_recovery}}🟢 RECOVERED{{/is_recovery}}

**Monitor:** {{name}}
**Service:** {{service.name}}
**Environment:** {{env.name}}
**Current Value:** {{value}}
**Threshold:** {{threshold}}

{{#is_alert}}
Immediate action required. Check the service dashboard:
https://app.datadoghq.com/apm/services/my-api

Runbook: https://wiki.mycompany.com/runbooks/high-latency
{{/is_alert}}

{{#is_recovery}}
The issue has resolved. No further action needed.
{{/is_recovery}}

@slack-backend-alerts
{{#is_alert}}@pagerduty-on-call{{/is_alert}}
```

### Notification Routing

| Severity | Channel | Handle |
|---|---|---|
| Info / Recovered | Slack channel | `@slack-backend-alerts` |
| Warning | Slack channel + email | `@slack-sre-alerts @team-backend@mycompany.com` |
| Critical | PagerDuty + Slack | `@pagerduty-on-call @slack-sre-critical` |
| Escalation | PagerDuty escalation | `@pagerduty-sre-escalation` |

### Escalation

- Set `renotify_interval` (in minutes) to re-alert if the monitor remains in alert state.
- Use `escalation_message` to send a different message on re-notification, targeting a higher-level responder.
- Typical escalation cadence: re-notify every 30 minutes, escalate after 2 re-notifications.

---

## Monitor Management Best Practices

1. **Use tags for organization** — Tag monitors with `service`, `team`, `env`, and `severity` for filtering and ownership.
2. **Name monitors descriptively** — Include the service name, metric, and threshold in the monitor name.
3. **Set `notify_no_data`** — Enable for monitors where data absence indicates a problem (e.g., heartbeat monitors).
4. **Use `evaluation_delay`** — Prevent false positives from metric collection lag.
5. **Review monitors monthly** — Disable or tune noisy monitors. Add monitors for new critical paths.
6. **Use monitor downtimes** — Schedule maintenance windows to suppress alerts during planned downtime.
7. **Export monitors as code** — Use Terraform (`datadog_monitor` resource) or the Datadog API to version-control monitor definitions.

### Monitor as Code (Terraform)

```hcl
resource "datadog_monitor" "high_latency" {
  name    = "High P95 Latency — my-api"
  type    = "query alert"
  query   = "percentile(last_5m):p95:trace.express.request{service:my-api,env:production} > 5000000000"
  message = <<-EOT
    P95 latency is above {{threshold_s}}s (currently {{value_s}}s).

    @slack-backend-alerts
    {{#is_alert}}@pagerduty-on-call{{/is_alert}}
  EOT

  monitor_thresholds {
    critical = 5000000000
    warning  = 2000000000
  }

  notify_no_data    = false
  renotify_interval = 30
  evaluation_delay  = 60

  tags = ["service:my-api", "team:backend", "env:production"]
}
```
