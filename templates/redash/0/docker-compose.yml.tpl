version: '2'
services:
  server:
    image: redash/redash:3.0.0.b3134
    labels:
    {{- if eq .Values.INIT_REDASH_DB "true" }}
      io.rancher.sidekicks: server-init
    {{- end }}
      io.rancher.container.hostname_override: container_name
    command: server
    depends_on:
    {{- if eq .Values.ADD_PG_CONTAINER "true" }}
      - redashdb
    {{- end }}
      - redis
    ports:
      - "5000:5000"
    environment:
    {{- if eq .Values.USE_HTTP_PROXY "true" }}
      HTTP_PROXY: ${HTTP_PROXY}
      HTTPS_PROXY: ${HTTPS_PROXY}
      NO_PROXY: ${NO_PROXY}
    {{- end }}
      PYTHONUNBUFFERED: 0
      REDASH_LOG_LEVEL: "INFO"
      REDASH_REDIS_URL: "redis://redis:6379/0"
      REDASH_STATSD_HOST: ${REDASH_STATSD_HOST}
      REDASH_HOST: "http://${REDASH_STATSD_HOST}:${REDAH_HTTP_PORT}"
      REDASH_DATE_FORMAT: YYYY/MM/DD
      REDASH_DATABASE_URL: "postgresql://${REDASH_DB_USER}:${REDASH_DB_PW}@${REDASH_DB_HOST}/${REDASH_DB_NAME}"
      REDASH_COOKIE_SECRET: ${REDASH_COOKIE_SECRET}
      REDASH_WEB_WORKERS: 4
{{- if eq .Values.INIT_REDASH_DB "true" }}
  server-init:
    image: redash/redash:3.0.0.b3134
    labels:
      io.rancher.container.start_once: true
    command: create_db
    depends_on:
    {{- if eq .Values.ADD_PG_CONTAINER "true" }}
      - redashdb
    {{- end }}
      - redis
    ports:
      - "5100:5000"
    environment:
    {{- if eq .Values.USE_HTTP_PROXY "true" }}
      HTTP_PROXY: ${HTTP_PROXY}
      HTTPS_PROXY: ${HTTPS_PROXY}
      NO_PROXY: ${NO_PROXY}
    {{- end }}
      PYTHONUNBUFFERED: 0
      REDASH_LOG_LEVEL: "INFO"
      REDASH_REDIS_URL: "redis://redis:6379/0"
      REDASH_STATSD_HOST: ${REDASH_STATSD_HOST}
      REDASH_HOST: "http://${REDASH_STATSD_HOST}:${REDAH_HTTP_PORT}"
      REDASH_DATE_FORMAT: YYYY/MM/DD
      REDASH_DATABASE_URL: "postgresql://${REDASH_DB_USER}:${REDASH_DB_PW}@${REDASH_DB_HOST}/${REDASH_DB_NAME}"
      REDASH_COOKIE_SECRET: ${REDASH_COOKIE_SECRET}
      REDASH_WEB_WORKERS: 4
{{- end }}
  worker:
    image: redash/redash:3.0.0.b3134
    labels:
      io.rancher.container.hostname_override: container_name
    command: scheduler
    environment:
    {{- if eq .Values.USE_HTTP_PROXY "true" }}
      HTTP_PROXY: ${HTTP_PROXY}
      HTTPS_PROXY: ${HTTPS_PROXY}
      NO_PROXY: ${NO_PROXY}
    {{- end }}
      PYTHONUNBUFFERED: 0
      REDASH_LOG_LEVEL: "INFO"
      REDASH_REDIS_URL: "redis://redis:6379/0"
      REDASH_DATABASE_URL: "postgresql://${REDASH_DB_USER}:${REDASH_DB_PW}@redashdb/${REDASH_DB_NAME}"
      QUEUES: "queries,scheduled_queries,celery"
      WORKERS_COUNT: 2
  redis:
    image: redis:3.0-alpine
  nginx:
    image: redash/nginx:latest
    ports:
      - "${REDAH_HTTP_PORT}:80"
    depends_on:
      - server
    links:
      - server:redash
{{- if eq .Values.ADD_PG_CONTAINER "true" }}
  redashdb:
    restart: always
    image: postgres:9.6.6-alpine
    labels:
      io.rancher.container.hostname_override: container_name
    environment:
      POSTGRES_USER: ${REDASH_DB_USER}
      POSTGRES_PASSWORD: ${REDASH_DB_PW}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --no-locale --data-checksums"
    volumes:
      - redash-pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
  pgadmin:
    links:
      - redashdb:redashdb
    image: dpage/pgadmin4
    labels:
      io.rancher.container.hostname_override: container_name
    environment:
        PGADMIN_DEFAULT_EMAIL: "${PGADMIN_DEF_EMAIL}"
        PGADMIN_DEFAULT_PASSWORD: "${PGADMIN_DEF_PW}"
    volumes:
       - pgadmin-data:/root/.pgadmin
    ports:
      - "${PGADMIN_HTTP_PORT}:80"
    restart: unless-stopped
    depends_on:
      - redashdb
{{- end }}
{{- if eq .Values.ADD_SAMPLE_DATASET "true" }}
  mysql:
    image: kakakakakku/mysql-57-world-database
    labels:
      io.rancher.container.hostname_override: container_name
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
{{- end }}
{{- if eq .Values.ADD_PG_CONTAINER "true" }}
volumes:
  redash-pgdata:
    driver: ${VOLUME_DRIVER}
    external: true
  pgadmin-data:
    driver: ${VOLUME_DRIVER}
    external: true
{{- end }}
