# L7 (Layer 7) Testing Commands

This document provides commands to test and verify L7 (HTTP) network policies and observability in Cilium.

## What is L7 Testing?

L7 testing allows you to:
- **Test HTTP-specific policies**: Path-based and method-based access control
- **Verify L7 observability**: See HTTP details in Hubble UI
- **Debug HTTP traffic**: Understand request/response patterns
- **Test security policies**: Verify path-based restrictions

## L7 Network Policies in Use Case 1

Our network policies include L7 HTTP rules:

```yaml
# Frontend can only access specific HTTP paths
toPorts:
- ports:
  - port: "8080"
    protocol: TCP
  rules:
    http:
    - method: "GET"
      path: "/api/.*"
    - method: "GET"
      path: "/health"
```

## L7 Testing Commands

### 1. Test Allowed HTTP Paths

```bash
# Test /health endpoint (should work)
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/health

# Test /api/ endpoints (should work)
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/api/users
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/api/status

# Test with different HTTP methods
kubectl exec -it deployment/frontend -- curl -X GET -v http://backend-service:8080/health
kubectl exec -it deployment/frontend -- curl -X POST -v http://backend-service:8080/api/data
```

### 2. Test Blocked HTTP Paths

```bash
# Test blocked paths (should be denied)
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/admin
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/secret
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/

# Test blocked HTTP methods
kubectl exec -it deployment/frontend -- curl -X DELETE -v http://backend-service:8080/health
kubectl exec -it deployment/frontend -- curl -X PUT -v http://backend-service:8080/api/users
```

### 3. Generate L7 Traffic for Hubble

```bash
# Generate HTTP traffic with proper headers
kubectl exec -it deployment/frontend -- curl -v \
  -H "User-Agent: frontend-client" \
  -H "Accept: application/json" \
  -H "X-Request-ID: test-001" \
  http://backend-service:8080/health

# Generate multiple requests with different paths
kubectl exec -it deployment/frontend -- curl -s http://backend-service:8080/health
kubectl exec -it deployment/frontend -- curl -s http://backend-service:8080/api/users
kubectl exec -it deployment/frontend -- curl -s http://backend-service:8080/api/status

# Test with different HTTP methods
kubectl exec -it deployment/frontend -- curl -X GET -s http://backend-service:8080/health
kubectl exec -it deployment/frontend -- curl -X POST -s http://backend-service:8080/api/data
```

### 4. Check L7 Information in Hubble

```bash
# Check for L7 flows in Hubble API
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l7 != null)'

# Check for HTTP-specific information
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l7.http != null)'

# Check for L7 data with source/destination
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l7 != null) | {source: .source.labels, destination: .destination.labels, l7: .l7}'

# Check for HTTP method and path information
curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l7.http != null) | {method: .l7.http.method, path: .l7.http.path, status: .l7.http.status}'
```

### 5. Test L7 Policy Enforcement

```bash
# Test that only allowed paths work
echo "Testing allowed paths:"
kubectl exec -it deployment/frontend -- curl -s -w "Status: %{http_code}\n" http://backend-service:8080/health
kubectl exec -it deployment/frontend -- curl -s -w "Status: %{http_code}\n" http://backend-service:8080/api/users

echo "Testing blocked paths:"
kubectl exec -it deployment/frontend -- curl -s -w "Status: %{http_code}\n" http://backend-service:8080/admin
kubectl exec -it deployment/frontend -- curl -s -w "Status: %{http_code}\n" http://backend-service:8080/secret
```

## Expected Results

### ✅ Allowed Paths (Should Work):
- `/health` - Returns 200 OK
- `/api/*` - Returns 200 OK or appropriate API response
- GET method on allowed paths

### ❌ Blocked Paths (Should Fail):
- `/admin` - Connection refused or timeout
- `/secret` - Connection refused or timeout
- `/` (root) - Connection refused or timeout
- DELETE, PUT methods on allowed paths

### 📊 L7 Information in Hubble:
When L7 proxy is working properly, you should see:
- **HTTP Method**: GET, POST, PUT, DELETE
- **HTTP Path**: /health, /api/users, /admin
- **HTTP Status**: 200, 404, 403
- **Request/Response Size**: Bytes transferred

## Troubleshooting L7 Issues

### If L7 Info Column is Empty in Hubble:

1. **Check L7 Proxy Configuration**:
   ```bash
   kubectl get configmap -n kube-system cilium-config -o yaml | grep "l7-proxy"
   ```

2. **Enable Hubble Metrics**:
   ```bash
   cilium config set hubble-metrics "dns,drop,tcp,flow,port-distribution,icmp,http"
   ```

3. **Restart Hubble**:
   ```bash
   kubectl rollout restart deployment/hubble-relay -n kube-system
   ```

4. **Check Cilium Agent Logs**:
   ```bash
   kubectl logs -n kube-system -l k8s-app=cilium | grep -i "l7\|http"
   ```

## L7 vs L4 Testing

| Layer | What It Tests | Example |
|-------|---------------|---------|
| **L4 (TCP)** | Port connectivity | `nc -zv backend-service 8080` |
| **L7 (HTTP)** | HTTP paths/methods | `curl http://backend-service:8080/health` |

**L7 testing is more granular and allows path-based security policies!**

## Use Cases for L7 Testing

1. **API Security**: Restrict access to specific API endpoints
2. **Path-based Access**: Allow `/public` but block `/admin`
3. **Method-based Security**: Allow GET but block DELETE
4. **Microservices Security**: Fine-grained service-to-service communication
5. **Compliance**: Audit HTTP-level access patterns

---

**L7 testing provides the most granular control over network traffic and is essential for modern microservices security!**
