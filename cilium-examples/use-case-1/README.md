# Use Case 1: Network Policies & Micro-segmentation

This example demonstrates Cilium's powerful network policy capabilities for implementing micro-segmentation and zero-trust networking.

## What This Example Shows

1. **Micro-segmentation**: Each tier (frontend, backend, database) can only communicate with specific other tiers
2. **Zero-trust networking**: By default, all traffic is denied unless explicitly allowed
3. **Fine-grained control**: Policies specify exact ports and protocols allowed

## Architecture

```
Internet → Frontend (nginx) → Backend (netshoot) → Database (PostgreSQL)
```

## Network Policy Rules

- **Frontend → Backend**: Allowed on port 8080
- **Backend → Database**: Allowed on port 5432
- **All other traffic**: Denied by default

## Deployment Order

Deploy the files in this order:

```bash
kubectl apply -f 01-frontend-deployment.yaml
kubectl apply -f 02-backend-deployment.yaml
kubectl apply -f 03-database-deployment.yaml
kubectl apply -f 04-services.yaml
kubectl apply -f 05-network-policies.yaml
```

## Testing the Policies

### L4 (Layer 4) Testing

1. **Test allowed communication**:
   ```bash
   # Test frontend to backend
   kubectl exec -it deployment/frontend -- wget -qO- http://backend-service:8080
   
   # Test backend to database
   kubectl exec -it deployment/backend -- nc -zv database-service 5432
   ```

2. **Test denied communication**:
   ```bash
   # This should fail - frontend cannot reach database directly
   kubectl exec -it deployment/frontend -- nc -zv database-service 5432
   ```

### L7 (Layer 7) Testing

This example includes **L7 HTTP policies** that control access based on HTTP paths and methods:

```bash
# Test allowed HTTP paths
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/health
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/api/users

# Test blocked HTTP paths (should fail)
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/admin
kubectl exec -it deployment/frontend -- curl -v http://backend-service:8080/secret
```

**📖 For comprehensive L7 testing commands, see: [L7 Testing Commands](06-l7-testing-commands.md)**

## Key Cilium Features Demonstrated

- **CiliumNetworkPolicy**: More powerful than standard Kubernetes NetworkPolicy
- **Label-based selectors**: Fine-grained endpoint selection
- **Protocol and port specification**: Precise traffic control
- **Default deny**: Zero-trust security model
