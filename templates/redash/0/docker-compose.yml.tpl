version: '2'
services:
  server:
    image: redash/redash:${REDASH_IMAGE_VERSION}
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
      - "${REDASH_HOST_PORT}:5000"
    environment:
      TZ: ${MY_TIMEZONE}
    {{- if eq .Values.USE_HTTP_PROXY "true" }}
      HTTP_PROXY: ${HTTP_PROXY}
      HTTPS_PROXY: ${HTTPS_PROXY}
      NO_PROXY: ${NO_PROXY}
    {{- end }}
      PYTHONUNBUFFERED: 0
      REDASH_LOG_LEVEL: "INFO"
      REDASH_REDIS_URL: "redis://redis:6379/0"
      REDASH_STATSD_HOST: ${REDASH_STATSD_HOST}
      REDASH_STATSD_PORT: ${REDASH_STATSD_PORT}
      REDASH_STATSD_PREFIX: ${REDASH_STATSD_PREFIX}
      REDASH_HOST: ${REDASH_HOST}
      REDASH_DATABASE_URL: "postgresql://${REDASH_DB_USER}:${REDASH_DB_PW}@${REDASH_DB_HOST}/${REDASH_DB_NAME}"
      REDASH_DATE_FORMAT: ${REDASH_DATE_FORMAT}
      REDASH_COOKIE_SECRET: ${REDASH_COOKIE_SECRET}
      REDASH_WEB_WORKERS: 4
      REDASH_ALLOW_SCRIPTS_IN_USER_INPUT: ${REDASH_ALLOW_SCRIPTS_IN_USER_INPUT}
      ALLOW_PARAMETERS_IN_EMBEDS: ${ALLOW_PARAMETERS_IN_EMBEDS}
      REDASH_LOG_STDOUT: ${REDASH_LOG_STDOUT}
      REDASH_MAIL_SERVER: ${REDASH_MAIL_SERVER}
      REDASH_MAIL_PORT: ${REDASH_MAIL_PORT}
      REDASH_MAIL_USE_TLS: ${REDASH_MAIL_USE_TLS}
      REDASH_MAIL_USE_SSL: ${REDASH_MAIL_USE_SSL}
      REDASH_MAIL_USERNAME: ${REDASH_MAIL_USERNAME}
      REDASH_MAIL_PASSWORD: ${REDASH_MAIL_PASSWORD}
      REDASH_MAIL_DEFAULT_SENDER: ${REDASH_MAIL_DEFAULT_SENDER}
      REDASH_MAIL_ASCII_ATTACHMENTS: ${REDASH_MAIL_ASCII_ATTACHMENTS}
{{- if eq .Values.INIT_REDASH_DB "true" }}
  server-init:
    image: redash/redash:${REDASH_IMAGE_VERSION}
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
      TZ: ${MY_TIMEZONE}
    {{- if eq .Values.USE_HTTP_PROXY "true" }}
      HTTP_PROXY: ${HTTP_PROXY}
      HTTPS_PROXY: ${HTTPS_PROXY}
      NO_PROXY: ${NO_PROXY}
    {{- end }}
      PYTHONUNBUFFERED: 0
      REDASH_LOG_LEVEL: "INFO"
      REDASH_REDIS_URL: "redis://redis:6379/0"
      REDASH_STATSD_HOST: ${REDASH_STATSD_HOST}
      REDASH_STATSD_PORT: ${REDASH_STATSD_PORT}
      REDASH_STATSD_PREFIX: ${REDASH_STATSD_PREFIX}
      REDASH_HOST: ${REDASH_HOST}
      REDASH_DATE_FORMAT: ${REDASH_DATE_FORMAT}
      REDASH_DATABASE_URL: "postgresql://${REDASH_DB_USER}:${REDASH_DB_PW}@${REDASH_DB_HOST}/${REDASH_DB_NAME}"
      REDASH_COOKIE_SECRET: ${REDASH_COOKIE_SECRET}
      REDASH_WEB_WORKERS: 4
      REDASH_ALLOW_SCRIPTS_IN_USER_INPUT: ${REDASH_ALLOW_SCRIPTS_IN_USER_INPUT}
      ALLOW_PARAMETERS_IN_EMBEDS: ${ALLOW_PARAMETERS_IN_EMBEDS}
      REDASH_LOG_STDOUT: ${REDASH_LOG_STDOUT}
      REDASH_MAIL_SERVER: ${REDASH_MAIL_SERVER}
      REDASH_MAIL_PORT: ${REDASH_MAIL_PORT}
      REDASH_MAIL_USE_TLS: ${REDASH_MAIL_USE_TLS}
      REDASH_MAIL_USE_SSL: ${REDASH_MAIL_USE_SSL}
      REDASH_MAIL_USERNAME: ${REDASH_MAIL_USERNAME}
      REDASH_MAIL_PASSWORD: ${REDASH_MAIL_PASSWORD}
      REDASH_MAIL_DEFAULT_SENDER: ${REDASH_MAIL_DEFAULT_SENDER}
      REDASH_MAIL_ASCII_ATTACHMENTS: ${REDASH_MAIL_ASCII_ATTACHMENTS}
{{- end }}
  worker:
    image: redash/redash:${REDASH_IMAGE_VERSION}
    labels:
      io.rancher.container.hostname_override: container_name
    command: scheduler
    environment:
      TZ: ${MY_TIMEZONE}
    {{- if eq .Values.USE_HTTP_PROXY "true" }}
      HTTP_PROXY: ${HTTP_PROXY}
      HTTPS_PROXY: ${HTTPS_PROXY}
      NO_PROXY: ${NO_PROXY}
    {{- end }}
      PYTHONUNBUFFERED: 0
      REDASH_LOG_LEVEL: "INFO"
      REDASH_REDIS_URL: "redis://redis:6379/0"
      REDASH_STATSD_HOST: ${REDASH_STATSD_HOST}
      REDASH_STATSD_PORT: ${REDASH_STATSD_PORT}
      REDASH_STATSD_PREFIX: ${REDASH_STATSD_PREFIX}
      REDASH_HOST: ${REDASH_HOST}
      REDASH_DATE_FORMAT: ${REDASH_DATE_FORMAT}
      REDASH_DATABASE_URL: "postgresql://${REDASH_DB_USER}:${REDASH_DB_PW}@${REDASH_DB_HOST}/${REDASH_DB_NAME}"
      REDASH_COOKIE_SECRET: ${REDASH_COOKIE_SECRET}
      QUEUES: "queries,scheduled_queries,celery"
      WORKERS_COUNT: 2
      REDASH_ALLOW_SCRIPTS_IN_USER_INPUT: ${REDASH_ALLOW_SCRIPTS_IN_USER_INPUT}
      ALLOW_PARAMETERS_IN_EMBEDS: ${ALLOW_PARAMETERS_IN_EMBEDS}
      REDASH_LOG_STDOUT: ${REDASH_LOG_STDOUT}
      REDASH_MAIL_SERVER: ${REDASH_MAIL_SERVER}
      REDASH_MAIL_PORT: ${REDASH_MAIL_PORT}
      REDASH_MAIL_USE_TLS: ${REDASH_MAIL_USE_TLS}
      REDASH_MAIL_USE_SSL: ${REDASH_MAIL_USE_SSL}
      REDASH_MAIL_USERNAME: ${REDASH_MAIL_USERNAME}
      REDASH_MAIL_PASSWORD: ${REDASH_MAIL_PASSWORD}
      REDASH_MAIL_DEFAULT_SENDER: ${REDASH_MAIL_DEFAULT_SENDER}
      REDASH_MAIL_ASCII_ATTACHMENTS: ${REDASH_MAIL_ASCII_ATTACHMENTS}
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
      TZ: ${MY_TIMEZONE}
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
      TZ: ${MY_TIMEZONE}
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
      TZ: ${MY_TIMEZONE}
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
