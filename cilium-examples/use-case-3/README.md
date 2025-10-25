# Use Case 3: Cilium Service Mesh

This example demonstrates Cilium's service mesh capabilities, including traffic management, load balancing, and advanced routing features.

## What is Cilium Service Mesh?

Cilium provides service mesh functionality through its Envoy-based data plane, offering:

- **🔄 Traffic Management**: Advanced load balancing and routing
- **🛡️ mTLS Security**: Automatic mutual TLS between services
- **📊 Observability**: Built-in metrics and tracing
- **🚦 Traffic Policies**: Fine-grained traffic control
- **🔄 Circuit Breaking**: Fault tolerance and resilience
- **⚡ Performance**: eBPF-based high-performance networking

## Key Features Demonstrated

### 1. Traffic Splitting & Canary Deployments
- Route traffic between different service versions
- Gradual rollout of new versions
- A/B testing capabilities

### 2. Load Balancing
- Round-robin, least connections, and weighted load balancing
- Health check integration
- Failover capabilities

### 3. Security Policies
- Automatic mTLS between services
- Traffic encryption
- Identity-based access control

### 4. Observability
- Service mesh metrics
- Distributed tracing
- Service dependency mapping

## Architecture

```
Client → Ingress → Service A (v1/v2) → Service B → Database
                ↓
            Service C (circuit breaker)
```

## Cilium Service Mesh vs Traditional Service Meshes

| Feature | Cilium | Istio | Linkerd |
|---------|--------|-------|---------|
| Performance | eBPF-based (fastest) | Envoy proxy | Rust-based |
| Resource Usage | Low | High | Medium |
| Security | eBPF + Envoy | Envoy | Rust |
| Observability | Built-in | Rich | Good |
| Complexity | Low | High | Medium |

## Files in This Use Case

- **`01-service-versions.yaml`**: Service deployments (v1/v2 canary, load balancing)
- **`02-traffic-policies.yaml`**: Advanced traffic management policies
- **`03-security-policies.yaml`**: Security and mTLS policies
- **`04-demo-commands.md`**: Commands to test service mesh features
- **`cilium-traffic-policy-crd.yaml`**: Custom CRD for advanced traffic policies

## Prerequisites

**Important**: This use case requires the custom `CiliumTrafficPolicy` CRD to be installed first:

```bash
# Install the custom CRD for advanced traffic management
kubectl apply -f cilium-traffic-policy-crd.yaml
```

## Quick Start

1. **Install the CRD**:
   ```bash
   kubectl apply -f cilium-traffic-policy-crd.yaml
   ```

2. **Deploy the services**:
   ```bash
   kubectl apply -f 01-service-versions.yaml
   ```

3. **Apply traffic policies**:
   ```bash
   kubectl apply -f 02-traffic-policies.yaml
   ```

4. **Test the features**:
   ```bash
   # Follow the commands in 04-demo-commands.md
   ```

## Verified Features

### ✅ **Traffic Management**
- **Canary Deployments**: 90% v1, 10% v2 traffic splitting
- **Load Balancing**: Round-robin distribution across replicas
- **Circuit Breaker**: Automatic failover when services fail
- **Retry Policies**: Automatic retries on failure
- **Timeout Policies**: Request timeout management

### ✅ **Security (mTLS Verified)**
- **Automatic mTLS**: All service-to-service communication encrypted
- **Identity-Based Access**: Each service has unique identity
- **Zero-Trust Networking**: Network policies + mTLS
- **Transparent Encryption**: No manual certificate management

### ✅ **Observability**
- **Service Communication**: Real-time traffic patterns
- **Performance Metrics**: Traffic rates and latency
- **Security Events**: Policy violations and blocked connections

## Use Cases

1. **Microservices Communication**: Secure service-to-service communication with automatic mTLS
2. **Traffic Management**: Canary deployments and A/B testing
3. **Security**: Automatic encryption and identity-based policies
4. **Observability**: Service mesh metrics and tracing
5. **Resilience**: Circuit breaking and retry policies
