
## Hướng dẫn khai báo file values.yaml

### Cấu hình chung

| Thông số                   | Mô tả                   |
|-----------------------------|-------------------------------|
| `app.name`                  | Tên ứng dụng              |
| `app.image.repository`      | Tên image    |
| `app.image.tag`             | Image tag           |
| `app.replicaCount`          | Số lượng replicas            |



### Cấu hình Service cho ứng dụng

| Thông số                       | Mô tả                 |
|---------------------------|-------------------|
| `service.type`            | Service type      |
| `service.port`            | Service port      |
| `service.targetPort`      | Service target port |

### Ingress và TLS

| Thông số                       | Mô tả                 |
|---------------------------|-------------------|
| `ingress.enabled`         | Enable ingress    |
| `ingress.className`       | Ingress class name (e.g., nginx, traefik, ingress-nginx)|
| `ingress.host`   | Danh sách các host được cấu hình ingress          |
| `ingress.tls[0].secretName`   | Tên của Secret resource chứa certificate	          |

### Cấu hình authentication cho custom user

| Thông số                       | Mô tả                 |
|---------------------------------|-----------------------------|
| `auth.enabled`                  | Enable tính năng authentication |
| `auth.users.list[]`    | Mảng các users được xác thực truy cập      |
| `auth.users.list[].name`    | User name      |
| `auth.users.list[].email`    | User email      |
| `auth.users.list[].groups`    | Mảng group user thuộc về      |
| `auth.users.list[].passwordHash`    | Password ở dạng hash  (sử dụng khi ứng dụng hỗ trợ authenticate bằng hash password)      |

### Cấu hình cho Redis

| Thông số                       | Mô tả                 |
|------------------------------|------------------------------|
| `redis.enabled`              | Enable Redis                 |
| `redis.auth.enabled`         | Enable Redis authentication  |
| `redis.auth.password`        | Redis password               |


### Cấu hình Cronjob dọn dẹp định kỳ

| Thông số                       | Mô tả                 |
|----------------------------------------|-----------------------------|
| `garbageCollection.enabled`            | Enable garbage collection   |
| `garbageCollection.schedule`           | CronJob chạy định kỳ theo format * * * * *  |
| `garbageCollection.settings.ageThreshold` | Xác định số ngày log được giữ lại (VD ageThreshold bằng 3 nghĩa là chỉ giữ lại log 3 ngày gần nhất)     | 
| `garbageCollection.settings.targets`     | Chọn loại log cần cleanup. Có thể chọn các giá trị "logs", "temp-files" or "cache-files"          | 

## File values.yaml mẫu
```
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
  className: "ingress"
  hosts:
    - host: secure-app-platform.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: secure-app-platform-tls
      hosts:
        - secure-app-platform.example.com


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

config:
  # Application configuration
  app:
    database:
      host: "localhost"
      port: 5432
      name: "app_db"

    cache:
      enabled: true
      type: "redis"



persistence:
  enabled: true
  storageClass: "nfs-storage-retain"
  accessMode: ReadWriteOnce
  size: 1Gi
```
