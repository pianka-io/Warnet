#!/bin/bash
# Keeps the war.pianka.io certificate current without AMI rebuilds.
#
# 1. Pull the newest cert from the shared S3 cache; install it if it is
#    newer than the local one (instances rotate every 2h, so every fresh
#    instance picks up the latest cert here).
# 2. If the installed cert expires within RENEW_DAYS, issue a fresh one via
#    Route53 DNS-01 using the instance-profile credentials, install it, and
#    upload it back to S3 so no other instance has to re-issue.
set -uo pipefail

DOMAIN="war.pianka.io"
LIVE_DIR="/etc/letsencrypt/live/${DOMAIN}"
BUCKET="warnet-certs-869935095159"
REGION="us-east-2"
RENEW_DAYS=30
ACME="/root/.acme.sh/acme.sh"

log() { logger -t cert-renew "$1"; echo "$(date -Is) $1"; }

expiry() { date -d "$(openssl x509 -enddate -noout -in "$1" | cut -d= -f2)" +%s; }

reload_nginx() { systemctl reload nginx 2>/dev/null || systemctl restart nginx; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# --- 1. sync down from S3 ---
if aws s3 cp "s3://${BUCKET}/${DOMAIN}/fullchain.pem" "${TMP}/fullchain.pem" --region "$REGION" >/dev/null 2>&1 \
&& aws s3 cp "s3://${BUCKET}/${DOMAIN}/privkey.pem" "${TMP}/privkey.pem" --region "$REGION" >/dev/null 2>&1; then
  if [ "$(expiry "${TMP}/fullchain.pem")" -gt "$(expiry "${LIVE_DIR}/fullchain.pem")" ]; then
    install -o root -g root -m 644 "${TMP}/fullchain.pem" "${LIVE_DIR}/fullchain.pem"
    install -o root -g root -m 600 "${TMP}/privkey.pem" "${LIVE_DIR}/privkey.pem"
    reload_nginx
    log "Installed newer certificate from S3."
  fi
fi

# --- 2. renew if close to expiry ---
NOW=$(date +%s)
EXP=$(expiry "${LIVE_DIR}/fullchain.pem")
if [ $(( EXP - NOW )) -gt $(( RENEW_DAYS * 86400 )) ]; then
  exit 0
fi

log "Certificate expires within ${RENEW_DAYS} days; issuing a new one."
if ! "$ACME" --issue --dns dns_aws -d "$DOMAIN" --server letsencrypt --force; then
  log "acme.sh issuance failed."
  exit 1
fi

CERT_DIR="/root/.acme.sh/${DOMAIN}_ecc"
install -o root -g root -m 644 "${CERT_DIR}/fullchain.cer" "${LIVE_DIR}/fullchain.pem"
install -o root -g root -m 600 "${CERT_DIR}/${DOMAIN}.key" "${LIVE_DIR}/privkey.pem"
reload_nginx

aws s3 cp "${LIVE_DIR}/fullchain.pem" "s3://${BUCKET}/${DOMAIN}/fullchain.pem" --region "$REGION"
aws s3 cp "${LIVE_DIR}/privkey.pem" "s3://${BUCKET}/${DOMAIN}/privkey.pem" --region "$REGION"
log "New certificate installed and uploaded to S3."
