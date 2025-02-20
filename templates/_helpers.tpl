{{- define "postgresql.waitForDatabase" -}}
initContainers:
  - name: wait-for-postgresql
    image: bitnami/postgresql:latest
    command:
      - /bin/bash
      - -ec
      - |
        until PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${POSTGRES_HOST}" -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT 1"; do
          echo "Waiting for PostgreSQL to be ready..."
          sleep 2
        done
        echo "PostgreSQL is ready!"
    env:
      - name: POSTGRES_HOST
        value: {{ .Release.Name }}-postgresql
      - name: POSTGRES_DB
        value: {{ .Values.postgresql.global.postgresql.auth.database | quote }}
      - name: POSTGRES_USER
        value: {{ .Values.postgresql.global.postgresql.auth.username | quote }}
      - name: POSTGRES_PASSWORD
        valueFrom:
            secretKeyRef:
                name: {{ .Release.Name }}-postgresql
                key: password
{{- end -}}

{{- define "user-service.labels" -}}
app: user-service
release: {{ .Release.Name }}
{{- end -}}


{{/* User service environment variables */}}
{{- define "user-service.env" -}}
- name: POSTGRES_USER
  value: {{ .Values.postgresql.global.postgresql.auth.username | quote }}
- name: USER_SERVICE_PORT
  value: {{ .Values.service.port | quote}}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-postgresql
      key: password
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-user-service-secrets
      key: jwt-secret
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-user-service-secrets
      key: rabbitmq-password
- name: POSTGRES_DB
  value: {{ .Values.postgresql.global.postgresql.auth.database }}
- name: POSTGRES_HOST
  value: {{ .Release.Name }}-postgresql
- name: POSTGRES_PORT
  value: {{ .Values.postgresql.port | quote }}
- name: RABBITMQ_HOST
  value: "{{ .Values.rabbitmq.serviceName }}.{{ .Values.rabbitmq.namespace }}.svc.cluster.local"
- name: RABBITMQ_PORT
  value: {{ .Values.rabbitmq.port | quote }}
- name: RABBITMQ_USERNAME
  value: {{ .Values.rabbitmq.username }}
{{- end -}}