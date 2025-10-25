# Hubble UI: Network Observability in Action

## Overview

The Hubble UI provides real-time network observability for Cilium, offering both visual and tabular views of network traffic flows, security events, and service communication patterns.

## Screenshot Analysis: `hubble-ui-network-flows.png`

The attached screenshot demonstrates Hubble UI's comprehensive observability capabilities, showing:

### 🔍 **Top Section: Controls and Metrics**
- **Namespace Filter**: "default" namespace selected
- **Filter Bar**: Advanced filtering options (labels, IPs, DNS, identities, pods)
- **Verdict Filter**: "Any verdict" dropdown for traffic filtering
- **Performance Metrics**: 
  - **12.7 flows/s**: Real-time traffic rate
  - **2/2 nodes**: All nodes are active and monitored

### 🕸️ **Network Flow Visualization (Top)**
The visual graph shows service-to-service communication patterns:

#### **Services and Components:**
- **`load-generator`** → **`traffic-generator`** → **`test-client`**
- **`test-client`** → **`web-app`** (port 80 TCP)
- **`web-app`** → Multiple services:
  - ✅ **`api-service`** (port 3000 TCP) - **Forwarded**
  - ❌ **`frontend`** (port 80 TCP) - **Blocked** (red line)
  - ❌ **`backend`** (port 8080 TCP) - **Blocked** (red line)
  - ✅ **`service-a`** (port 8080 TCP) - **Forwarded**
  - ✅ **`service-b`** (port 8080 TCP) - **Forwarded**
- **`service-b`** → **`api-service`** (port 3000 TCP) - **Forwarded**
- **`service-b`** → **`database`** (port 5432 TCP) - **Blocked** (red dashed line)

#### **Color Coding:**
- **Grey Lines**: Successfully forwarded traffic
- **Red Lines**: Blocked/dropped traffic (policy violations)
- **Red Dashed Lines**: Blocked database connections

### 📊 **Event Log Table (Bottom)**
Detailed flow-by-flow analysis showing:

#### **Columns:**
- **Source Identity**: Origin of network flow
- **Destination Identity**: Target service
- **Destination Port**: Target port number
- **L7 Info**: Layer 7 protocol details
- **Verdict**: `forwarded` (green) or `dropped` (red)
- **Timestamp**: Exact time of each flow

#### **Key Observations:**
1. **Successful Traffic**:
   - `load-generator` → `web-app` (port 80) - All forwarded
   - `load-generator` → `database` (port 5432) - All forwarded

2. **Blocked Traffic**:
   - `traffic-generator` → `frontend` (port 80) - Dropped
   - Multiple policy violations visible

## 🎯 **What This Demonstrates**

### **1. Zero-Trust Security**
- Network policies are actively blocking unauthorized connections
- Red lines show policy enforcement in action
- Only explicitly allowed traffic is forwarded

### **2. Service Communication Patterns**
- Clear visualization of microservices architecture
- Service dependencies are easily identifiable
- Traffic flow patterns are visible in real-time

### **3. Real-Time Monitoring**
- Live traffic rate: 12.7 flows/s
- Timestamped events for precise analysis
- Both successful and failed connections tracked

### **4. Security Event Detection**
- Policy violations clearly highlighted
- Dropped connections immediately visible
- Security teams can quickly identify issues

## 🚀 **How to Access Hubble UI**

### **1. Port Forward Hubble UI**
```bash
kubectl port-forward -n kube-system svc/hubble-ui 8080:80
```

### **2. Open in Browser**
```
http://localhost:8080
```

### **3. Navigate the Interface**
- **Visual Tab**: Network flow diagram
- **Events Tab**: Detailed flow logs
- **Filters**: Use the filter bar for specific queries

## 🔧 **Advanced Filtering Examples**

### **Filter by Service**
```
pod=web-app
```

### **Filter by Port**
```
port=80
```

### **Filter by Verdict**
```
verdict=dropped
```

### **Filter by Time Range**
Use the time picker to focus on specific periods

## 📈 **Use Cases for This View**

### **1. Security Analysis**
- Identify policy violations
- Monitor blocked connections
- Verify zero-trust enforcement

### **2. Performance Monitoring**
- Track traffic rates
- Identify bottlenecks
- Monitor service health

### **3. Troubleshooting**
- Debug connectivity issues
- Trace request flows
- Identify service dependencies

### **4. Compliance**
- Audit network policies
- Document traffic patterns
- Verify security controls

## 🎨 **Visual Elements Explained**

### **Node Types**
- **Rectangular Nodes**: Kubernetes services/pods
- **Kubernetes Icons**: Service type indicators
- **Port Labels**: Target ports for connections

### **Connection Types**
- **Solid Lines**: Direct connections
- **Dashed Lines**: Indirect or blocked connections
- **Arrow Direction**: Traffic flow direction

### **Color Meanings**
- **Grey**: Normal, forwarded traffic
- **Red**: Blocked, dropped traffic
- **Green**: Successfully processed traffic

## 🔍 **Reading the Event Log**

### **Sample Entry Analysis**
```
Source: load-generator default
Destination: web-app default
Port: 80
Verdict: forwarded
Timestamp: 2025/10/25 14:04:35
```

**Interpretation**: The load generator successfully sent traffic to the web app on port 80 at the specified time.

## 🎯 **Key Takeaways**

1. **Real-Time Visibility**: See network traffic as it happens
2. **Security Enforcement**: Policy violations are immediately visible
3. **Service Dependencies**: Understand how services communicate
4. **Performance Metrics**: Monitor traffic rates and patterns
5. **Troubleshooting**: Quickly identify and resolve issues

## 📚 **Related Documentation**

- [Use Case 2: Observability](cilium-examples/use-case-2/README.md)
- [Hubble Demo Commands](cilium-examples/use-case-2/05-hubble-demo-commands.md)
- [Cilium Setup Guide](CILIUM-SETUP.md)

---

**This screenshot demonstrates the power of Cilium's observability features, providing both high-level visual insights and detailed flow-by-flow analysis for comprehensive network monitoring and security analysis.**
