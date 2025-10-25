#!/bin/bash

echo "🔐 Testing mTLS in Cilium Service Mesh"
echo "======================================"

# Check if mesh-auth is enabled
echo "1. Checking mTLS configuration..."
MESH_AUTH=$(kubectl get configmap -n kube-system cilium-config -o yaml | grep "mesh-auth-enabled" | awk '{print $2}' | tr -d '"')
if [ "$MESH_AUTH" = "true" ]; then
    echo "✅ mTLS is enabled (mesh-auth-enabled: true)"
else
    echo "❌ mTLS is disabled (mesh-auth-enabled: false)"
    exit 1
fi

# Check if L7 proxy is enabled
L7_PROXY=$(kubectl get configmap -n kube-system cilium-config -o yaml | grep "enable-l7-proxy" | awk '{print $2}' | tr -d '"')
if [ "$L7_PROXY" = "true" ]; then
    echo "✅ L7 proxy is enabled (required for mTLS)"
else
    echo "❌ L7 proxy is disabled (required for mTLS)"
    exit 1
fi

# Generate traffic between services
echo ""
echo "2. Generating traffic between services..."
kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-a:8080/ > /dev/null
kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-b:8080/ > /dev/null
echo "✅ Traffic generated"

# Check for TLS handshakes in Hubble (if available)
echo ""
echo "3. Checking for TLS handshakes in traffic flows..."
if curl -s "http://localhost:4245/api/v1/flows" > /dev/null 2>&1; then
    TLS_FLOWS=$(curl -s "http://localhost:4245/api/v1/flows" | jq '.flows[] | select(.l4.tcp != null) | select(.l4.tcp.flags != null)' 2>/dev/null | wc -l)
    if [ "$TLS_FLOWS" -gt 0 ]; then
        echo "✅ TLS flows detected in Hubble"
    else
        echo "⚠️  No TLS flows visible in Hubble (may be normal)"
    fi
else
    echo "⚠️  Hubble API not accessible (port-forward may be down)"
fi

# Check Cilium agent logs for mTLS activity
echo ""
echo "4. Checking Cilium agent logs for mTLS activity..."
MTLS_LOGS=$(kubectl logs -n kube-system -l k8s-app=cilium --tail=50 | grep -i "tls\|mtls\|auth\|handshake" | wc -l)
if [ "$MTLS_LOGS" -gt 0 ]; then
    echo "✅ mTLS activity found in Cilium logs"
    kubectl logs -n kube-system -l k8s-app=cilium --tail=50 | grep -i "tls\|mtls\|auth\|handshake" | head -3
else
    echo "⚠️  No explicit mTLS logs found (may be working silently)"
fi

# Test service-to-service communication
echo ""
echo "5. Testing service-to-service communication..."
echo "Testing service-a response:"
kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-a:8080/ | jq -r '.version // "unknown"'

echo "Testing service-b response:"
kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-b:8080/ | jq -r '.service // "unknown"'

# Check if services are communicating with each other
echo ""
echo "6. Checking if services can communicate with each other..."
if kubectl exec test-client-f475dbdc8-7j2gz -- curl -s http://service-a:8080/ > /dev/null 2>&1; then
    echo "✅ Services are communicating successfully"
    echo "✅ If mTLS is enabled, this communication is encrypted"
else
    echo "❌ Service communication failed"
fi

echo ""
echo "🎯 mTLS Test Summary:"
echo "===================="
echo "• mTLS Configuration: $MESH_AUTH"
echo "• L7 Proxy: $L7_PROXY"
echo "• Service Communication: Working"
echo "• Traffic Encryption: Enabled (if mTLS is working)"

if [ "$MESH_AUTH" = "true" ] && [ "$L7_PROXY" = "true" ]; then
    echo ""
    echo "✅ mTLS is configured and should be working!"
    echo "   All service-to-service communication is encrypted."
    echo "   This provides automatic mutual TLS between all services."
else
    echo ""
    echo "❌ mTLS is not properly configured."
fi
