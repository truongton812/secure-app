# Secure App Platform Helm Chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A comprehensive Helm chart for deploying a secure application platform with Redis caching, custom authentication, automated garbage collection, and custom domain support.

## Features

- ✅ **Customizable Configuration**: Extensive configuration options through Helm values
- 🔐 **Custom Authentication**: Support for JWT, Basic Auth, and RBAC with custom user accounts
- 🌐 **Secure Networking**: Ingress with TLS termination and custom domain support
- 🗑️ **Automated Garbage Collection**: Configurable CronJob for periodic cleanup
- ⚡ **Redis Caching**: Integrated Redis for metadata caching with persistence
- 🔄 **CI/CD Integration**: GitHub Actions workflow for automated linting and testing
- 📊 **Monitoring**: Built-in health checks and Prometheus metrics
- 🛡️ **Security**: Pod security policies, network policies, and secret management

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8+
- cert-manager (for TLS certificates)
- ingress-nginx or similar ingress controller
- Persistent Volume provisioner (if persistence is enabled)

## Installation

### Quick Start

```bash
# Add the Helm repository (if using a Helm repository)
helm repo add your-repo https://your-charts-repo.com
helm repo update

# Install the chart with default values
helm install my-secure-app your-repo/secure-app-platform

# Or install from local directory
helm install my-secure-app ./secure-app-platform
```

### Custom Installation

Create a custom values file:

```yaml
# custom-values.yaml
ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com

auth:
  jwt:
    secret: "your-secure-jwt-secret-key"
  users:
    - name: "admin"
      email: "admin@yourcompany.com"
      groups: ["admin", "developers"]

redis:
  auth:
    password: "your-secure-redis-password"

garbageCollection:
  schedule: "0 3 * * *"  # Run at 3 AM daily
  settings:
    ageThreshold: 14  # Clean files older than 14 days
```

Install with custom values:

```bash
helm install my-secure-app ./secure-app-platform -f custom-values.yaml
```

## Configuration

### Core Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.name` | Application name | `secure-app-platform` |
| `app.image.repository` | Container image repository | `nginx` |
| `app.image.tag` | Container image tag | `1.25.3` |
| `app.replicaCount` | Number of application replicas | `3` |
| `app.resources.limits.cpu` | CPU limit | `500m` |
| `app.resources.limits.memory` | Memory limit | `512Mi` |

### Authentication & Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `auth.enabled` | Enable authentication features | `true` |
| `auth.serviceAccount.create` | Create service account | `true` |
| `auth.rbac.create` | Create RBAC resources | `true` |
| `auth.jwt.secret` | JWT secret key | `your-jwt-secret-key` |
| `auth.jwt.expirationHours` | JWT token expiration | `24` |
| `auth.users` | List of custom users | `[]` |

### Networking & Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.hosts[0].host` | Hostname | `your-app.example.com` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |

### Redis Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Enable Redis | `true` |
| `redis.auth.enabled` | Enable Redis authentication | `true` |
| `redis.auth.password` | Redis password | `redis-secure-password` |
| `redis.cache.defaultTTL` | Default cache TTL (seconds) | `3600` |
| `redis.cache.maxMemory` | Maximum memory usage | `200mb` |

### Garbage Collection

| Parameter | Description | Default |
|-----------|-------------|---------|
| `garbageCollection.enabled` | Enable garbage collection | `true` |
| `garbageCollection.schedule` | CronJob schedule | `0 2 * * *` |
| `garbageCollection.settings.ageThreshold` | Age threshold (days) | `7` |
| `garbageCollection.settings.targets` | Cleanup targets | `["logs", "temp-files", "cache-files"]` |

### Monitoring

| Parameter | Description | Default |
|-----------|-------------|---------|
| `monitoring.enabled` | Enable monitoring | `true` |
| `monitoring.prometheus.enabled` | Enable Prometheus metrics | `true` |
| `monitoring.healthChecks.liveness.enabled` | Enable liveness probe | `true` |
| `monitoring.healthChecks.readiness.enabled` | Enable readiness probe | `true` |

## Usage Examples

### Development Environment

```yaml
# dev-values.yaml
app:
  replicaCount: 1
  resources:
    limits:
      cpu: 200m
      memory: 256Mi

redis:
  master:
    persistence:
      enabled: false

garbageCollection:
  schedule: "0 */6 * * *"  # Every 6 hours
```

### Production Environment

```yaml
# prod-values.yaml
app:
  replicaCount: 5
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70

redis:
  master:
    persistence:
      enabled: true
      size: 20Gi
      storageClass: "fast-ssd"

security:
  networkPolicy:
    enabled: true

monitoring:
  prometheus:
    enabled: true
```

### High Availability Setup

```yaml
# ha-values.yaml
app:
  replicaCount: 3

affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app.kubernetes.io/name
          operator: In
          values:
          - secure-app-platform
      topologyKey: kubernetes.io/hostname

podDisruptionBudget:
  enabled: true
  minAvailable: 2

redis:
  replica:
    replicaCount: 2
  sentinel:
    enabled: true
```

## Deployment

### Using Helm

```bash
# Install
helm install my-app ./secure-app-platform -f custom-values.yaml

# Upgrade
helm upgrade my-app ./secure-app-platform -f custom-values.yaml

# Uninstall
helm uninstall my-app
```

### Using ArgoCD

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: secure-app-platform
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/secure-app-platform
    targetRevision: HEAD
    path: secure-app-platform
    helm:
      valueFiles:
      - values.yaml
      - environments/production/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: secure-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Development

### Prerequisites for Development

- Helm 3.8+
- kubectl
- Docker
- kind or minikube (for local testing)

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/your-org/secure-app-platform
cd secure-app-platform

# Create a local kind cluster
kind create cluster --name helm-testing

# Install dependencies
helm dependency update ./secure-app-platform

# Test the chart
helm template test ./secure-app-platform --debug --dry-run

# Install locally
helm install test ./secure-app-platform --create-namespace --namespace test
```

### Running Tests

```bash
# Lint the chart
helm lint ./secure-app-platform

# Run unit tests (requires helm-unittest plugin)
helm plugin install https://github.com/quintush/helm-unittest
helm unittest ./secure-app-platform

# Validate against Kubernetes API
helm template test ./secure-app-platform | kubectl apply --dry-run=client -f -
```

## CI/CD Integration

The chart includes a comprehensive GitHub Actions workflow that:

- **Lints** Helm charts using `helm lint` and `chart-testing`
- **Validates** templates and manifests
- **Tests** installation in a kind cluster
- **Scans** for security vulnerabilities
- **Packages** charts for release
- **Generates** documentation automatically

### GitHub Actions Workflow

The workflow is triggered on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch

Key features:
- Automated testing with multiple Kubernetes versions
- Security scanning with Trivy and Checkov
- Documentation generation with helm-docs
- Chart packaging and release automation

### Setting up CI/CD

1. Copy `.github/workflows/ci.yaml` to your repository
2. Ensure your chart follows the expected structure
3. Configure any required secrets in GitHub repository settings
4. The workflow will automatically run on push/PR

## Security Considerations

### Authentication

- JWT tokens are used for API authentication
- Custom user accounts can be configured with specific roles
- RBAC ensures proper authorization
- Service accounts follow least-privilege principle

### Network Security

- Network policies restrict pod-to-pod communication
- Ingress with TLS termination
- Support for custom domains with SSL certificates
- Redis authentication enabled by default

### Container Security

- Non-root containers by default
- Read-only root filesystem
- Security contexts applied
- Resource limits enforced

### Secret Management

- Sensitive data stored in Kubernetes secrets
- Support for external secret management systems
- Passwords and keys are base64 encoded
- No hardcoded secrets in templates

## Troubleshooting

### Common Issues

1. **Pod fails to start**
   ```bash
   kubectl describe pod -l app.kubernetes.io/name=secure-app-platform
   kubectl logs -l app.kubernetes.io/name=secure-app-platform
   ```

2. **Ingress not working**
   ```bash
   kubectl get ingress
   kubectl describe ingress secure-app-platform
   ```

3. **Redis connection issues**
   ```bash
   kubectl logs -l app.kubernetes.io/name=redis
   kubectl exec -it <redis-pod> -- redis-cli ping
   ```

4. **Garbage collection not running**
   ```bash
   kubectl get cronjobs
   kubectl describe cronjob secure-app-platform-garbage-collection
   ```

### Debug Mode

Enable debug logging:

```yaml
app:
  env:
    LOG_LEVEL: "debug"
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`helm lint` and `helm unittest`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the maintainers at devops@yourcompany.com
- Check the documentation and troubleshooting guide

## Changelog

### [0.1.0] - 2025-01-01
- Initial release
- Core application deployment
- Redis integration
- Authentication and RBAC
- Garbage collection
- CI/CD workflow
- Security hardening
- Monitoring integration