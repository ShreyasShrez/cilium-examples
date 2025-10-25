# Service Mesh Demo Commands

Use these commands to demonstrate Cilium's service mesh capabilities:

## Prerequisites

**Important**: Install the custom CRD first:
```bash
kubectl apply -f cilium-traffic-policy-crd.yaml
```

## 1. Enable Service Mesh Features

```bash
# Enable service mesh mode in Cilium
cilium config set cluster-name minikube
cilium config set cluster-id 1

# Verify service mesh is enabled
cilium status
```

## 2. Traffic Management Testing

### Canary Deployment Testing
```bash
# Generate traffic to see traffic splitting
kubectl run test-client --image=nicolaka/netshoot --rm -it --restart=Never -- \
  sh -c "for i in {1..20}; do curl -s http://service-a:8080/ | jq .version; done"

# Expected output: ~90% v1, ~10% v2 responses
```

### Load Balancing Testing
```bash
# Test load balancing between service-b replicas
kubectl run test-client --image=nicolaka/netshoot --rm -it --restart=Never -- \
  sh -c "for i in {1..10}; do curl -s http://service-b:8080/ | jq .service; done"

# Test L7 HTTP endpoints
kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-a:8080/health | jq .
kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-b:8080/health | jq .

# Test different HTTP methods and paths
kubectl exec test-client-f475dbdc8-7j2gz -- curl -X GET -s http://service-a:8080/
kubectl exec test-client-f475dbdc8-7j2gz -- curl -X POST -s http://service-a:8080/
```

## 3. Security Testing

### mTLS Verification
```bash
# Check if mTLS is enabled in Cilium configuration
kubectl get configmap -n kube-system cilium-config -o yaml | grep "mesh-auth-enabled"

# Check if L7 proxy is enabled (required for mTLS)
kubectl get configmap -n kube-system cilium-config -o yaml | grep "enable-l7-proxy"

# Verify mTLS is working by testing service communication
kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-a:8080/ | jq -r '.version'
kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-b:8080/ | jq -r '.service'

# If services communicate successfully, mTLS is working automatically
# All service-to-service communication is encrypted with mTLS
```

### mTLS Verification Results
```bash
# Expected output when mTLS is working:
# mesh-auth-enabled: "true"
# enable-l7-proxy: "true"
# 
# Service communication should work normally:
# service-a response: v1 or v2
# service-b response: service-b
# 
# This means all traffic is automatically encrypted with mTLS!
```

### Identity-based Access Control
```bash
# Test access from service-b to service-a (should work)
kubectl exec -it deployment/service-b -- curl -s http://service-a:8080/

# Test access from unauthorized pod (should be blocked)
kubectl run unauthorized-client --image=nicolaka/netshoot --rm -it --restart=Never -- \
  curl -s http://service-a:8080/
```

## 4. Circuit Breaker Testing

```bash
# Simulate service failures to test circuit breaker
kubectl scale deployment service-a-v1 --replicas=0

# Generate traffic to trigger circuit breaker
kubectl run test-client --image=nicolaka/netshoot --rm -it --restart=Never -- \
  sh -c "for i in {1..10}; do curl -s http://service-a:8080/ || echo 'Request failed'; done"

# Scale back up
kubectl scale deployment service-a-v1 --replicas=3
```

## 5. Rate Limiting Testing

```bash
# Generate high-volume traffic to test rate limiting
kubectl run rate-limit-test --image=nicolaka/netshoot --rm -it --restart=Never -- \
  sh -c "for i in {1..200}; do curl -s http://service-a:8080/ & done; wait"
```

## 6. Observability

### Service Mesh Metrics
```bash
# View service mesh metrics
kubectl get --raw /api/v1/namespaces/kube-system/services/hubble-relay:http-metrics/proxy/metrics | grep cilium

# View Envoy metrics
kubectl get --raw /api/v1/namespaces/kube-system/services/hubble-relay:http-metrics/proxy/metrics | grep envoy
```

### Traffic Analysis
```bash
# Monitor service-to-service communication
cilium hubble observe --follow --json | jq '.destination_service'

# View traffic patterns
cilium hubble observe --follow | grep -E "(service-a|service-b)"
```

## 7. Policy Management

### View Applied Policies
```bash
# List all traffic policies
kubectl get ciliumtrafficpolicies

# Describe a specific policy
kubectl describe ciliumtrafficpolicy service-a-traffic-split
```

### Policy Testing
```bash
# Test traffic splitting policy
kubectl run policy-test --image=nicolaka/netshoot --rm -it --restart=Never -- \
  sh -c "for i in {1..100}; do curl -s http://service-a:8080/ | jq .version; done | sort | uniq -c"
```

## 8. Performance Testing

### Latency Testing
```bash
# Measure request latency
kubectl run latency-test --image=nicolaka/netshoot --rm -it --restart=Never -- \
  sh -c "time curl -s http://service-a:8080/ > /dev/null"
```

### Throughput Testing
```bash
# Test throughput with multiple concurrent requests
kubectl run throughput-test --image=nicolaka/netshoot --rm -it --restart=Never -- \
  sh -c "for i in {1..50}; do curl -s http://service-a:8080/ & done; wait"
```

## Demo Scenarios

### Scenario 1: Canary Deployment
1. Deploy service versions with traffic splitting
2. Generate traffic and observe version distribution
3. Gradually increase canary traffic percentage

### Scenario 2: Circuit Breaker
1. Simulate service failures
2. Observe circuit breaker activation
3. Test service recovery

### Scenario 3: Security
1. Enable mTLS between services
2. Test identity-based access control
3. Verify traffic encryption

### Scenario 4: Performance
1. Test load balancing effectiveness
2. Measure latency and throughput
3. Compare with and without service mesh
