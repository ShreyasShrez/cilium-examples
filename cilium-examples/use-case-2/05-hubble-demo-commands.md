# Hubble Demo Commands

Use these commands to demonstrate Hubble's observability capabilities:

**Note**: The `hubble observe` command syntax has changed. Use the corrected commands below via Hubble Relay API.

## 1. Basic Flow Observation

```bash
# Watch all network flows in real-time
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[]'

# Follow flows with timestamps (real-time monitoring loop)
while true; do
  echo "=== $(date) ==="
  curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | {time: .time, source: .source.labels, destination: .destination.labels, verdict: .verdict}'
  sleep 2
done

# Show only flows from specific pods
curl -s "http://localhost:4245/api/v1/flows?source=web-app" | jq '.flows[]'
curl -s "http://localhost:4245/api/v1/flows?source=api-service" | jq '.flows[]'
```

## 2. Security Monitoring

```bash
# Monitor dropped/denied packets (policy violations)
curl -s "http://localhost:4245/api/v1/flows?verdict=DROPPED" | jq '.flows[]'

# Show flows that were allowed by policies
curl -s "http://localhost:4245/api/v1/flows?verdict=FORWARDED" | jq '.flows[]'

# Monitor specific security events (real-time)
while true; do
  echo "=== Dropped Traffic $(date) ==="
  curl -s "http://localhost:4245/api/v1/flows?verdict=DROPPED" | jq '.flows[]'
  sleep 2
done
```

## 3. Service Communication Analysis

```bash
# Show flows between specific services
curl -s "http://localhost:4245/api/v1/flows?source=web-app&destination=api-service" | jq '.flows[]'

# Monitor database connections
curl -s "http://localhost:4245/api/v1/flows?destination=database" | jq '.flows[]'

# Show all HTTP traffic
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l4.tcp != null)'

# Show L7 HTTP information (if available)
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l7 != null) | {source: .source.labels, destination: .destination.labels, l7: .l7}'

# Show HTTP method and path information
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l7.http != null) | {method: .l7.http.method, path: .l7.http.path, status: .l7.http.status}'
```

## 4. Performance Analysis

```bash
# Show flows with latency information
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | {source: .source.labels, destination: .destination.labels, l4: .l4.tcp}'

# Monitor TCP connections
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l4.tcp != null)'

# Show flows with specific ports
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.destination.port == 80)'
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.destination.port == 3000)'
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.destination.port == 5432)'
```

## 5. Advanced Filtering

```bash
# Show flows from specific namespaces
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.source.namespace == "default")'

# Filter by labels
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.source.labels.app == "web-app")'
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.source.labels.tier == "backend")'

# Show flows with specific verdicts
curl -s "http://localhost:4245/api/v1/flows?verdict=FORWARDED,DROPPED" | jq '.flows[]'
```

## 6. JSON Output for Analysis

```bash
# Get structured data for analysis
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | {destination_service: .destination.labels, source: .source.labels, verdict: .verdict}'

# Service communication patterns
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | {source: .source.labels, destination: .destination.labels, verdict: .verdict}'

# Count flows by verdict
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows | group_by(.verdict) | map({verdict: .[0].verdict, count: length})'
```

## 7. Hubble UI Access

```bash
# Start Hubble UI (opens in browser)
./cilium hubble ui

# Port forward to access UI remotely
kubectl port-forward -n kube-system svc/hubble-ui 12000:80
```

## 8. Metrics and Monitoring

```bash
# Get Hubble metrics
kubectl get --raw /api/v1/namespaces/kube-system/services/hubble-relay:http-metrics/proxy/metrics

# Check Hubble status
./cilium hubble status
```

## Demo Scenarios

### Scenario 1: Normal Traffic Flow
1. Deploy all applications
2. Run: `curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[]'`
3. Watch normal web app → API → database traffic

### Scenario 2: Policy Violations
1. Apply network policies
2. Run: `curl -s "http://localhost:4245/api/v1/flows?verdict=DROPPED" | jq '.flows[]'`
3. Watch blocked traffic attempts

### Scenario 3: Service Dependencies
1. Run: `curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | {source: .source.labels, destination: .destination.labels}'`
2. Analyze service communication patterns

### Scenario 4: Performance Issues
1. Generate load with load-generator
2. Run: `curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | {source: .source.labels, destination: .destination.labels, l4: .l4.tcp}'`
3. Monitor connection performance

## Quick Setup Commands

```bash
# Ensure port-forwards are running
kubectl port-forward -n kube-system svc/hubble-relay 4245:80 &
kubectl port-forward -n kube-system svc/hubble-ui 8080:80 &
kubectl port-forward svc/web-app-service 8081:80 &

# Generate traffic for testing
kubectl exec load-generator-9548c5f5d-zl7zn -- curl -s http://web-app-service/ > /dev/null
kubectl exec load-generator-9548c5f5d-zl7zn -- curl -s http://api-service:3000/ > /dev/null

# Test the corrected commands
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows | length'
```
