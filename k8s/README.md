# Kubernetes Setup & App Deployment Guide

This guide explains how to spin up a Kubernetes cluster locally and deploy the app using the single manifest **`combined.yaml`** (provided). It also covers how to reach the app in your browser and common troubleshooting steps.

> Default namespace used by the manifests: **`myapp`**  
> Key resources: `Namespace/myapp`, `Secret/myapp-secrets`, `ConfigMap/myapp-config`, `Deployment/myapp-deployment`, `Service/myapp-service`, `HorizontalPodAutoscaler/myapp-hpa`, and a health-check `CronJob` that curls the service.

---

## 1) Prerequisites

- **kubectl** v1.27+ (any recent is fine)
- A local Kubernetes runtime (pick one):
  - **Docker Desktop** (enable Kubernetes)
  - **minikube**
- (Optional) **metrics-server** - recommended if you want HPA to work) 

Verify access:
```bash
kubectl version --client
kubectl cluster-info
kubectl get nodes
```

---

## 2) Create/Start a Local Cluster (pick one)

### A. Docker Desktop (Windows/macOS/Linux)
1. Open Docker Desktop → **Settings → Kubernetes → Enable Kubernetes** → Apply & restart.
2. Confirm:
   ```bash
   kubectl config current-context   # should be something like: docker-desktop
   ```

### B. minikube
```bash
minikube start
kubectl config current-context   # should be minikube
```

## 3) Prepare Secrets and Configs

- The manifest contains placeholder values for secrets and configs.
- Change them as needed.

---

## 4) Deploy the App

Apply everything at once:
```bash
kubectl apply -f combined.yaml
```

Watch resources come up:
```bash
kubectl get all -n myapp
kubectl logs -n myapp deploy/myapp-deployment --tail=50
```

---

## 5) Access the App

### Port-forward (works everywhere and everytime)
```bash
# Forward local 8080 -> service port 80
kubectl -n myapp port-forward svc/myapp-service 8080:80
# Open http://localhost:8080
```

---

## 6) Verify the Deployment

- Pods:
  ```bash
  kubectl -n myapp get pods -o wide
  kubectl -n myapp describe pod <pod-name>
  ```
- Service:
  ```bash
  kubectl -n myapp get svc myapp-service -o wide
  ```

- A `CronJob` in the manifest periodically curls the service and prints “Service is up/down” in its job logs:
  ```bash
  kubectl -n myapp get cronjob
  kubectl -n myapp logs job/<job-name>
  ```

---

## 7) Enable Autoscaling (HPA)

The manifest defines `HorizontalPodAutoscaler/myapp-hpa`. Install metrics-server to allow HPA to see CPU/memory metrics:

**Docker Desktop:**
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

**minikube:**
```bash
minikube addons enable metrics-server
```

Check HPA:
```bash
kubectl -n myapp get hpa myapp-hpa
kubectl -n myapp describe hpa myapp-hpa
```

---

## 8) Common Commands & Troubleshooting

- **See events in real time:**
  ```bash
  kubectl -n myapp get events --watch
  ```
- **Describe resources for error messages:**
  ```bash
  kubectl -n myapp describe deploy/myapp-deployment
  kubectl -n myapp describe svc/myapp-service
  ```
- **Image pull issues (`ImagePullBackOff`):** ensure your image is accessible (public or imagePullSecrets configured).
- **CrashLoopBackOff:** check pod logs (`kubectl -n myapp logs <pod>`) and liveness/readiness probes in the manifest.
- **Service not reachable:**
  - Confirm correct service **type** and **port**:
    ```bash
    kubectl -n myapp get svc myapp-service -o yaml | grep -E 'type:|port:|targetPort:|nodePort:' -n
    ```
- **HPA shows `unknown` metrics:** install metrics-server (see 7).

---

## 9) Cleanup

```bash
kubectl delete -f combined.yaml
```