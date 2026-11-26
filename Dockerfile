# =========================================================================
# Init
# =========================================================================
# ARGs (can be passed to Build/Final) <BEGIN>
ARG SaM_REPO=${SaM_REPO:-ghcr.io/kristianstad/secure_and_minimal}
ARG ALPINE_VERSION=${ALPINE_VERSION:-3.24}
ARG APP_VERSION=${APP_VERSION:-5.82}
ARG IMAGETYPE="application"
ARG BUILDDEPS="openssl-dev"
ARG BUILDCMDS=\
" gcc -O2 -o /tmp/healthcheck /tmp/healthcheck.c -lssl -lcrypto "\
"&& strip --strip-all /tmp/healthcheck "\
"&& chmod ugo+rx-w /tmp/healthcheck "\
"&& cp -a /tmp/healthcheck /finalfs/usr/local/bin/"
ARG RUNDEPS="stunnel openssl ca-certificates-bundle"
ARG MAKEDIRS="/etc/stunnel"
ARG REMOVEFILES="/etc/stunnel/stunnel.conf"
ARG STARTUPEXECUTABLES="/usr/bin/stunnel /usr/bin/openssl"
# ARGs (can be passed to Build/Final) </END>

# Generic template (don't edit) <BEGIN>
FROM ${CONTENTIMAGE1:-scratch} AS content1
FROM ${CONTENTIMAGE2:-scratch} AS content2
FROM ${CONTENTIMAGE3:-scratch} AS content3
FROM ${CONTENTIMAGE4:-scratch} AS content4
FROM ${CONTENTIMAGE5:-scratch} AS content5
FROM ${BASEIMAGE:-$SaM_REPO:base-${ALPINE_VERSION}} AS base
FROM ${INITIMAGE:-scratch} AS init
# Generic template (don't edit) </END>

# =========================================================================
# Build
# =========================================================================
# Generic template (don't edit) <BEGIN>
FROM ${BUILDIMAGE:-$SaM_REPO:build-${ALPINE_VERSION}} AS build
FROM ${BASEIMAGE:-$SaM_REPO:base-${ALPINE_VERSION}} AS final
COPY --from=build /finalfs /
# Generic template (don't edit) </END>

COPY ./healthcheck.c /tmp/

# =========================================================================
# Final
# =========================================================================
# Re-declare ARGs
ARG ALPINE_VERSION
ARG APP_VERSION

ENV VAR_LINUX_USER="stunnel" \
    VAR_LISTEN_PORT="8443" \
    VAR_SERVICE="stunnel" \
    VAR_CLIENT="no" \
    VAR_DEBUG="5" \
    VAR_DELAY="no" \
    VAR_VERIFY_CHAIN="no" \
    VAR_CA_FILE="/etc/ssl/certs/ca-certificates.crt" \
    VAR_CONFIG_DIR="/etc/stunnel" \
    VAR_CONFIG_FILE="/etc/stunnel/generated.conf" \
    VAR_CERT_FILE="/etc/stunnel/stunnel.pem" \
    VAR_KEY_FILE="/etc/stunnel/stunnel.key" \
    VAR_CERT_CN="localhost" \
    VAR_CERT_DAYS="365" \
    VAR_FINAL_COMMAND='stunnel $VAR_CONFIG_FILE'

# Generic template (don't edit) <BEGIN>
USER starter
ONBUILD USER root
# Generic template (don't edit) </END>

LABEL org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.title="stunnel" \
      org.opencontainers.image.description="TLS proxy (stunnel) ${APP_VERSION} based on secure_and_minimal ${ALPINE_VERSION}"
