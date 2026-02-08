# Skill: Set Up Datadog APM

Set up Datadog APM (Application Performance Monitoring) with distributed tracing in a project, with framework-specific guidance for Express, Next.js, Django, and Flask.

## Prerequisites

- A Datadog account (https://www.datadoghq.com)
- The Datadog Agent installed and running (on the host, as a sidecar, or via the Datadog Operator in Kubernetes)
- Your Datadog API key (found in **Organization Settings → API Keys**)

## Environment Variables

Set these in your `.env` file, container environment, or CI/CD secrets:

```bash
# Required
DD_API_KEY=your-datadog-api-key
DD_AGENT_HOST=localhost                  # or the Agent's hostname/IP
DD_TRACE_AGENT_PORT=8126                 # default APM port

# Unified Service Tagging (required for proper correlation)
DD_ENV=production                        # or staging, development
DD_SERVICE=my-api                        # logical service name
DD_VERSION=1.0.0                         # application version

# Optional
DD_TRACE_SAMPLE_RATE=0.1                 # default sampling rate (0.0–1.0)
DD_LOGS_INJECTION=true                   # inject trace IDs into logs
DD_RUNTIME_METRICS_ENABLED=true          # collect runtime metrics (Node.js, Python)
DD_PROFILING_ENABLED=true                # enable Continuous Profiler
DD_TRACE_ENABLED=true                    # enable/disable tracing (default: true)
```

---

## Node.js (Express) Setup

### 1. Install Dependencies

```bash
npm install dd-trace
# Optional: profiling
npm install @datadog/native-metrics
```

### 2. Initialize the Tracer

Create a `tracer.ts` file and import it **before any other module** in your entry point:

```ts
// src/tracer.ts
import tracer from "dd-trace";

tracer.init({
  service: process.env.DD_SERVICE || "my-api",
  env: process.env.DD_ENV || "development",
  version: process.env.DD_VERSION || "1.0.0",
  logInjection: true,
  runtimeMetrics: true,
  profiling: true,
  // Sampling
  ingestion: {
    sampleRate: parseFloat(process.env.DD_TRACE_SAMPLE_RATE || "0.1"),
    rateLimit: 100,
  },
});

export default tracer;
```

```ts
// src/index.ts — import tracer FIRST
import "./tracer";
import express from "express";

const app = express();

app.get("/api/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.get("/api/users/:id", async (req, res) => {
  const user = await getUserById(req.params.id);
  res.json(user);
});

app.listen(3000, () => {
  console.log("Server listening on port 3000");
});
```

### 3. Custom Instrumentation

Add custom spans for business-critical operations:

```ts
import tracer from "./tracer";

export async function processOrder(order: Order): Promise<OrderResult> {
  return tracer.trace(
    "order.process",
    {
      resource: `order.${order.type}`,
      tags: {
        "order.id": order.id,
        "order.total": order.total,
        "customer.tier": order.customer.tier,
      },
    },
    async (span) => {
      // Validate
      await tracer.trace("order.validate", async () => {
        await validateOrder(order);
      });

      // Charge payment
      const payment = await tracer.trace("payment.charge", async (paymentSpan) => {
        paymentSpan.setTag("payment.method", order.paymentMethod);
        return chargePayment(order);
      });

      // Fulfill
      await tracer.trace("order.fulfill", async () => {
        await fulfillOrder(order, payment);
      });

      span.setTag("order.status", "completed");
      return { orderId: order.id, status: "completed" };
    }
  );
}
```

### 4. Error Handling

Ensure errors are properly captured in traces:

```ts
import tracer from "./tracer";

app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  const span = tracer.scope().active();
  if (span) {
    span.setTag("error", true);
    span.setTag("error.message", err.message);
    span.setTag("error.type", err.constructor.name);
    span.setTag("error.stack", err.stack || "");
  }
  res.status(500).json({ error: "Internal Server Error" });
});
```

### 5. Custom Metrics via DogStatsD

```ts
import tracer from "./tracer";

// The tracer includes a DogStatsD client
const { dogstatsd } = tracer;

// Increment a counter
dogstatsd.increment("orders.created", 1, { payment_method: "credit_card" });

// Record a gauge
dogstatsd.gauge("queue.depth", queueLength, { queue: "orders" });

// Record a histogram (distribution)
dogstatsd.histogram("order.processing_time", durationMs, { order_type: "standard" });
```

---

## Next.js Setup

### 1. Install Dependencies

```bash
npm install dd-trace
```

### 2. Create Instrumentation File

Next.js 13.4+ supports an `instrumentation.ts` hook that runs once when the server starts:

```ts
// instrumentation.ts (project root)
export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    const tracer = await import("dd-trace");
    tracer.default.init({
      service: process.env.DD_SERVICE || "my-nextjs-app",
      env: process.env.DD_ENV || "development",
      version: process.env.DD_VERSION || "1.0.0",
      logInjection: true,
      runtimeMetrics: true,
    });
  }
}
```

### 3. Enable Instrumentation in next.config.js

```js
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    instrumentationHook: true,
  },
};

module.exports = nextConfig;
```

### 4. Custom Spans in API Routes

```ts
// app/api/orders/route.ts
import tracer from "dd-trace";

export async function POST(request: Request) {
  return tracer.trace("api.create_order", async (span) => {
    const body = await request.json();
    span.setTag("order.items_count", body.items.length);

    const order = await createOrder(body);
    span.setTag("order.id", order.id);

    return Response.json(order, { status: 201 });
  });
}
```

### 5. Custom Spans in Server Components

```tsx
// app/dashboard/page.tsx
import tracer from "dd-trace";

export default async function DashboardPage() {
  const data = await tracer.trace("page.dashboard", async (span) => {
    const [metrics, alerts, services] = await Promise.all([
      tracer.trace("dashboard.fetch_metrics", () => fetchMetrics()),
      tracer.trace("dashboard.fetch_alerts", () => fetchAlerts()),
      tracer.trace("dashboard.fetch_services", () => fetchServices()),
    ]);

    span.setTag("dashboard.metrics_count", metrics.length);
    return { metrics, alerts, services };
  });

  return <DashboardView data={data} />;
}
```

---

## Python (Django) Setup

### 1. Install Dependencies

```bash
pip install ddtrace
```

### 2. Run with ddtrace-run

The easiest way to instrument Django is using `ddtrace-run`, which auto-patches all supported libraries:

```bash
DD_SERVICE=my-django-app \
DD_ENV=production \
DD_VERSION=1.0.0 \
DD_TRACE_SAMPLE_RATE=0.1 \
DD_LOGS_INJECTION=true \
ddtrace-run python manage.py runserver 0.0.0.0:8000
```

For Gunicorn:

```bash
ddtrace-run gunicorn myproject.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 4
```

### 3. Manual Initialization (Alternative)

```python
# myproject/settings.py
import os
from ddtrace import tracer, patch_all

patch_all()

tracer.configure(
    hostname=os.environ.get("DD_AGENT_HOST", "localhost"),
    port=int(os.environ.get("DD_TRACE_AGENT_PORT", "8126")),
)

# Django-specific settings
DATADOG_TRACE = {
    "DEFAULT_SERVICE": os.environ.get("DD_SERVICE", "my-django-app"),
    "TAGS": {
        "env": os.environ.get("DD_ENV", "development"),
        "version": os.environ.get("DD_VERSION", "1.0.0"),
    },
    "ENABLED": True,
    "ANALYTICS_ENABLED": True,
}
```

### 4. Custom Spans in Views

```python
from ddtrace import tracer

@tracer.wrap(service="order-service", resource="create_order")
def create_order(request):
    order_data = json.loads(request.body)

    with tracer.trace("order.validate") as span:
        span.set_tag("order.items_count", len(order_data["items"]))
        validate_order(order_data)

    with tracer.trace("payment.charge") as span:
        span.set_tag("payment.method", order_data["payment_method"])
        payment = charge_payment(order_data)

    with tracer.trace("order.save") as span:
        order = Order.objects.create(**order_data)
        span.set_tag("order.id", order.id)

    return JsonResponse({"order_id": order.id, "status": "created"})
```

### 5. Custom Metrics

```python
from datadog import DogStatsd

statsd = DogStatsd(host=os.environ.get("DD_AGENT_HOST", "localhost"), port=8125)

statsd.increment("orders.created", tags=["payment_method:credit_card"])
statsd.gauge("queue.depth", queue_length, tags=["queue:orders"])
statsd.histogram("order.processing_time", duration_ms, tags=["order_type:standard"])
```

---

## Python (Flask) Setup

### 1. Install Dependencies

```bash
pip install ddtrace
```

### 2. Run with ddtrace-run

```bash
DD_SERVICE=my-flask-app \
DD_ENV=production \
DD_VERSION=1.0.0 \
ddtrace-run python app.py
```

For Gunicorn:

```bash
ddtrace-run gunicorn app:app \
  --bind 0.0.0.0:5000 \
  --workers 4
```

### 3. Manual Initialization (Alternative)

```python
# app.py
import os
from ddtrace import tracer, patch_all

# Patch before importing Flask
patch_all()

from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/api/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/api/orders", methods=["POST"])
def create_order():
    with tracer.trace("order.create", service="order-service") as span:
        data = request.get_json()
        span.set_tag("order.items_count", len(data.get("items", [])))

        order = process_order(data)
        span.set_tag("order.id", order["id"])

        return jsonify(order), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## Datadog Agent Configuration

### Docker Compose

```yaml
# docker-compose.yml
services:
  datadog-agent:
    image: datadog/agent:latest
    environment:
      - DD_API_KEY=${DD_API_KEY}
      - DD_SITE=datadoghq.com
      - DD_APM_ENABLED=true
      - DD_APM_NON_LOCAL_TRAFFIC=true
      - DD_LOGS_ENABLED=true
      - DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true
      - DD_PROCESS_AGENT_ENABLED=true
      - DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true
    ports:
      - "8126:8126"   # APM
      - "8125:8125/udp" # DogStatsD
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /proc/:/host/proc/:ro
      - /sys/fs/cgroup:/host/sys/fs/cgroup:ro

  my-api:
    build: .
    environment:
      - DD_AGENT_HOST=datadog-agent
      - DD_ENV=development
      - DD_SERVICE=my-api
      - DD_VERSION=1.0.0
    depends_on:
      - datadog-agent
```

### Kubernetes (Helm)

```bash
helm repo add datadog https://helm.datadoghq.com
helm install datadog datadog/datadog \
  --set datadog.apiKey=${DD_API_KEY} \
  --set datadog.site=datadoghq.com \
  --set datadog.apm.portEnabled=true \
  --set datadog.logs.enabled=true \
  --set datadog.logs.containerCollectAll=true \
  --set datadog.processAgent.enabled=true
```

Then configure your application pods:

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-api
spec:
  template:
    metadata:
      labels:
        tags.datadoghq.com/env: production
        tags.datadoghq.com/service: my-api
        tags.datadoghq.com/version: "1.0.0"
      annotations:
        ad.datadoghq.com/my-api.logs: '[{"source":"nodejs","service":"my-api"}]'
    spec:
      containers:
        - name: my-api
          env:
            - name: DD_AGENT_HOST
              valueFrom:
                fieldRef:
                  fieldPath: status.hostIP
            - name: DD_ENV
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['tags.datadoghq.com/env']
            - name: DD_SERVICE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['tags.datadoghq.com/service']
            - name: DD_VERSION
              valueFrom:
                fieldRef:
                  fieldPath: metadata.labels['tags.datadoghq.com/version']
            - name: DD_LOGS_INJECTION
              value: "true"
```

---

## Verification Checklist

After setup, verify everything works:

1. **Check Agent status:**
   ```bash
   # Docker
   docker exec -it datadog-agent agent status

   # Kubernetes
   kubectl exec -it <agent-pod> -- agent status
   ```
   Verify the APM section shows "Status: Running" and traces are being received.

2. **Send a test trace:**
   ```ts
   import tracer from "./tracer";
   tracer.trace("test.verification", (span) => {
     span.setTag("test", true);
     console.log("Test trace sent — check Datadog APM in ~30 seconds");
   });
   ```

3. **Check Datadog APM:**
   - Navigate to **APM → Services** in the Datadog UI.
   - Your service should appear within 1–2 minutes.
   - Click into the service to see endpoints, latency, and error rates.

4. **Verify trace–log correlation:**
   - Navigate to **APM → Traces** and click on a trace.
   - Click the **Logs** tab — correlated log entries should appear.

5. **Verify unified service tagging:**
   - In the Service Map or Service Page, verify that `env`, `service`, and `version` tags are present and correct.

6. **Check runtime metrics:**
   - Navigate to **APM → Services → [Your Service] → Runtime Metrics**.
   - Verify Node.js metrics (event loop, GC, heap) or Python metrics (GIL, threads) are being reported.

7. **Remove test traces** after verification.
