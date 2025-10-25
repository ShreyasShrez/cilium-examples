# Use Case 2: Hubble Observability & Network Visibility

This example demonstrates Cilium's Hubble observability platform for deep network visibility, security monitoring, and service dependency mapping.

## What is Hubble?

Hubble is Cilium's observability platform that provides:

- **🔍 Network Flow Visibility**: See all network connections in real-time
- **🛡️ Security Monitoring**: Track policy violations and security events  
- **📊 Service Dependencies**: Visualize how services communicate
- **📈 Performance Metrics**: Monitor latency, throughput, and errors
- **🚨 Real-time Alerts**: Get notified of network issues

## Hubble Components

1. **Hubble Relay**: Central component that aggregates data from all Cilium agents
2. **Hubble UI**: Web interface for visualizing network flows
3. **Hubble CLI**: Command-line tool for querying network data
4. **Hubble Metrics**: Prometheus-compatible metrics

## Demo Applications

This example includes:
- **Web Application**: Simple nginx frontend
- **API Service**: Node.js backend with multiple endpoints
- **Database**: PostgreSQL database
- **Load Generator**: Tool to generate traffic for observation

## Quick Start

Deploy the applications in order:

```bash
# 1. Create database secret first
kubectl apply -f 03-database-secret.yaml

# 2. Deploy applications
kubectl apply -f 01-web-app.yaml
kubectl apply -f 02-api-service.yaml
kubectl apply -f 03-database.yaml
kubectl apply -f 04-load-generator.yaml
```

**🔐 Security Note**: The database deployment now uses Kubernetes Secrets instead of hardcoded passwords. See [SECRETS-MANAGEMENT.md](../../SECRETS-MANAGEMENT.md) for details.

## Key Features Demonstrated

### 1. Real-time Flow Monitoring
```bash
# Watch live network flows
./cilium hubble observe

# Filter flows by specific pods
./cilium hubble observe --pod frontend
```

### 2. Security Event Monitoring
```bash
# Monitor policy violations
./cilium hubble observe --verdict DROPPED

# Track security events
./cilium hubble observe --verdict DENIED
```

### 3. Service Dependency Mapping
```bash
# See service communication patterns
./cilium hubble observe --follow --json | jq '.destination_service'
```

### 4. Performance Analysis
```bash
# Monitor latency and throughput
./cilium hubble observe --follow --json | jq '.l4.tcp'
```

## Hubble UI Access

The Hubble UI provides a visual interface for:
- **Service Map**: Interactive network topology
- **Flow Logs**: Detailed connection information
- **Metrics Dashboard**: Performance and security metrics
- **Policy Analysis**: Network policy effectiveness

### 📸 **Live Demo Screenshot**

See the Hubble UI in action with our live traffic:

![Hubble UI Network Flows](../hubble-ui-network-flows.png)

**What you can see in this screenshot:**
- **Real-time traffic flows**: 12.7 flows/s across 2 nodes
- **Service communication patterns**: Visual network topology
- **Security enforcement**: Red lines show blocked connections
- **Detailed event logs**: Flow-by-flow analysis with timestamps
- **Policy violations**: Dropped connections clearly highlighted

### Access the UI:
```bash
# Port forward Hubble UI
kubectl port-forward -n kube-system svc/hubble-ui 8080:80

# Open in browser
open http://localhost:8080
```

### 📖 **Detailed Analysis**
For a comprehensive analysis of the screenshot and Hubble UI features, see:
- [Hubble UI Guide](../../HUBBLE-UI-GUIDE.md) - Complete screenshot analysis
- [Hubble Demo Commands](05-hubble-demo-commands.md) - Interactive commands

## Use Cases for Hubble

1. **Troubleshooting**: Quickly identify network connectivity issues
2. **Security Analysis**: Detect unauthorized access attempts
3. **Performance Optimization**: Identify bottlenecks and slow connections
4. **Compliance**: Audit network traffic for regulatory requirements
5. **Capacity Planning**: Understand traffic patterns for scaling decisions
