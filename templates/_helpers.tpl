{{/*
Expand the name of the chart.
*/}}
{{- define "secure-app-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "secure-app-platform.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "secure-app-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "secure-app-platform.labels" -}}
helm.sh/chart: {{ include "secure-app-platform.chart" . }}
{{ include "secure-app-platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "secure-app-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "secure-app-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Redis service name
*/}}
{{- define "secure-app-platform.redis.fullname" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis-master" (include "secure-app-platform.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Redis connection string
*/}}
{{- define "secure-app-platform.redis.connectionString" -}}
{{- if .Values.redis.enabled }}
{{- if .Values.redis.auth.enabled }}
{{- printf "redis://:%s@%s:6379" .Values.redis.auth.password (include "secure-app-platform.redis.fullname" .) }}
{{- else }}
{{- printf "redis://%s:6379" (include "secure-app-platform.redis.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate certificates for custom domains
*/}}
{{- define "secure-app-platform.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "secure-app-platform.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "secure-app-platform.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "secure-app-platform-ca" 365 -}}
{{- $cert := genSignedCert ( include "secure-app-platform.name" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end }}

{{/*
Generate environment variables
*/}}
{{- define "secure-app-platform.env" -}}
- name: APP_NAME
  value: {{ include "secure-app-platform.name" . }}
- name: NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
{{- if .Values.redis.enabled }}
- name: REDIS_URL
  value: {{ include "secure-app-platform.redis.connectionString" . }}
{{- end }}
{{- end }}

{{/*
Generate resource requirements
*/}}
{{- define "secure-app-platform.resources" -}}
{{- if .Values.app.resources }}
resources:
  {{- toYaml .Values.app.resources | nindent 2 }}
{{- end }}
{{- end }}


{{/*
Generate volume mounts
*/}}
{{- define "secure-app-platform.volumeMounts" -}}
- name: config
  mountPath: /etc/config
  readOnly: true
{{- if .Values.persistence.enabled }}
- name: data
  mountPath: /data
{{- end }}
{{- range .Values.persistence.volumes }}
- name: {{ .name }}
  mountPath: {{ .mountPath }}
{{- end }}
{{- end }}

{{/*
Generate volumes
*/}}
{{- define "secure-app-platform.volumes" -}}
- name: config
  configMap:
    name: {{ include "secure-app-platform.fullname" . }}-config
{{- if .Values.persistence.enabled }}
- name: data
  persistentVolumeClaim:
    claimName: {{ include "secure-app-platform.fullname" . }}-pvc
{{- end }}
{{- range .Values.persistence.volumes }}
- name: {{ .name }}
  emptyDir:
    sizeLimit: {{ .size }}
{{- end }}
{{- end }}

{{/*
Generate ingress annotations
*/}}
{{- define "secure-app-platform.ingress.annotations" -}}
{{- with .Values.ingress.annotations }}
{{- toYaml . }}
{{- end }}
{{- end }}
