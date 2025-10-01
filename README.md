

### Custom Installation



# Application configuration
app:
  name: secure-app-platform
  image:
    repository: nginx
    tag: "1.25.3"
  replicaCount: 1
  
  
# Service configuration
service:
  type: ClusterIP
  port: 80
  targetPort: 8080


# Ingress configuration for custom domains
ingress:
  enabled: true
  className: "ingress-nginx"
  hosts:
    - host: secure-app-platform.example.com
  
  tls:
    - secretName: secure-app-platform-tls
      hosts:
        - secure-app-platform.example.com
      certificate: |-
        -----BEGIN CERTIFICATE-----
        YOUR_BASE64_OR_PEM_CERT_CONTENT_HERE
        -----END CERTIFICATE-----
      privateKey: |-
        -----BEGIN PRIVATE KEY-----
        YOUR_BASE64_OR_PEM_KEY_CONTENT_HERE
        -----END PRIVATE KEY-----        

#Authentication for custom user
auth:
  enabled: true
  users:
    list:
      - name: "app-admin"
        email: "admin@mycompany.com"
        groups: ["admin", "developers"]
        passwordHash: ""
      - name: "app-developer"
        email: "dev@mycompany.com"
        groups: ["developers"]
        passwordHash: ""

# Redis configuration for metadata caching
redis:
  enabled: true
  
  # Redis authentication
  auth:
    enabled: true
    password: "my-redis-password"
  
  

# Garbage Collection configuration
garbageCollection:
  enabled: true
  
  # CronJob schedule (default: every day at 2 AM)
  schedule: "0 2 * * *"
  
  # Image for garbage collection job
  image:
    repository: busybox
    tag: "1.36.1"
    pullPolicy: IfNotPresent
  
  # Garbage collection settings
  settings:
    # Age threshold for cleanup (in days)
    ageThreshold: 7
    # Cleanup targets
    targets:
      - "logs"
      - "temp-files"
      - "cache-files"
    
    # Log retention
    logRetention:
      days: 30
```
  


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
  enabled: true
  users:
    list:
      - name: "app-admin"
        email: "admin@mycompany.com"
        groups: ["admin", "developers"]
        passwordHash: ""
      - name: "app-developer"
        email: "dev@mycompany.com"
        groups: ["developers"]
        passwordHash: ""

redis:
  auth:
    password: "your-secure-redis-password"

garbageCollection:
  schedule: "0 3 * * *"  # Run at 3 AM daily
  settings:
    ageThreshold: 14  # Clean files older than 14 days
```



## Configuration

### Core Application Settings

### General Settings

| Parameter                   | Description                   |
|-----------------------------|-------------------------------|
| `app.name`                  | Application name              |
| `app.image.repository`      | Container image repository    |
| `app.image.tag`             | Container image tag           |
| `app.replicaCount`          | Number of replicas            |

### Authentication for custom user

| Parameter                       | Description                 |
|---------------------------------|-----------------------------|
| `auth.enabled`                  | Enable authentication features |
| `auth.users.list[]`    | Array of authenticated users      |
| `auth.users.list[].name`    | User name      |
| `auth.users.list[].email`    | User email      |
| `auth.users.list[].groups`    | Array of groups user belongs to      |
| `auth.users.list[].passwordHash`    | Password in hash form (in case application supports authentication by hashed password)      |


### Ingress and TLS

| Parameter                 | Description       |
|---------------------------|-------------------|
| `ingress.enabled`         | Enable ingress    |
| `ingress.className`       | Ingress class name (e.g., nginx, traefik, ingress-nginx)|
| `ingress.host`   | List of host configurations for the Ingress          |
| `ingress.hosts[].host`   | Hostname/domain for the application          |
| `ingress.tls[0].secretName`   | Name of the TLS secret to be created	          |
| `ingress.tls[0].hosts`   | List of hostnames covered by this TLS certificate |   
| `service.type`            | Service type      |
| `ingress.tls[].certificate` | PEM-encoded SSL certificate content	|
| `ingress.tls[].privateKey`	| PEM-encoded private key content |
| `service.port`            | Service port      |
| `service.targetPort`      | Service target port |

### Redis Configuration

| Parameter                    | Description                  |
|------------------------------|------------------------------|
| `redis.enabled`              | Enable Redis                 |
| `redis.auth.enabled`         | Enable Redis authentication  |
| `redis.auth.password`        | Redis password               |
| `redis.cache.defaultTTL`     | Default cache TTL (seconds)  |
| `redis.cache.maxMemory`      | Maximum memory usage         |

### Garbage Collection

| Parameter                              | Description                 |  
|----------------------------------------|-----------------------------|
| `garbageCollection.enabled`            | Enable garbage collection   |
| `garbageCollection.schedule`           | CronJob schedule in format * * * * *  |
| `garbageCollection.settings.ageThreshold` | Age threshold (days)     | 
| `garbageCollection.settings.targets`     | Cleanup targets. Choose "logs", "temp-files" or "cache-files"          | 


