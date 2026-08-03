# Kubernetes Production Security & Resource Hardening Lab

This directory implements enterprise security policies, resource constraints, traffic filters, and namespace isolation architectures for a production-grade Kubernetes cluster.

## 🧬 Architectural Strategy

- **Logical Isolation**: Organizes deployments into distinct administrative layers: `production`, `staging`, and `monitoring`.
- **Compute Guarantees**: Enforces CPU and Memory resource limits on namespaces (`ResourceQuotas`) and maps default quotas per container (`LimitRanges`) to prevent rogue processes from causing node instability.
- **Network Segmentation**: Implements a zero-trust `NetworkPolicy` to restrict ingress database connections, allowing access solely from designated application instances.

---

## 📁 Manifest Files

- **`namespace.yaml`**: Provisions logically isolated namespaces.
- **`resource-quota.yaml`**: Allocates hard ceilings for requests and limits on memory and CPU.
- **`limit-range.yaml`**: Sets default container resources constraints.
- **`network-policy.yaml`**: Configures database pod ingress isolation filters.

---

## 🚀 Execution Steps

1. Apply namespaces configuration:
   ```bash
   kubectl apply -f namespace.yaml
   ```
2. Apply the default container resource limits and resource quota:
   ```bash
   kubectl apply -f limit-range.yaml
   kubectl apply -f resource-quota.yaml
   ```
3. Secure the database pods by applying the isolation network policy:
   ```bash
   kubectl apply -f network-policy.yaml
   ```
4. Verify execution:
   ```bash
   kubectl describe namespace production
   kubectl get quota -n production
   kubectl get networkpolicy -n production
   ```
