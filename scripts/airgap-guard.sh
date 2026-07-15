#!/usr/bin/env bash
# Air-gap compliance guard (see docs/airgap.md).
# Fails when a change would reintroduce an internet dependency into the
# cluster or an opening besides the Gateway's 443 listener.
set -euo pipefail

fail=0

# 1. Argo CD sources must stay inside the perimeter: the GitOps repo or
#    the Harbor OCI chart project. Comments are ignored.
urls=$(grep -rhE '^[^#]*https?://' --include='*.yaml' argo-cd/ \
  | grep -oE 'https?://[^"'\'' ]+' \
  | grep -vE '^https://(github\.com/wbatchayon/kubeops\.git|kubernetes\.default\.svc)' || true)
if [ -n "$urls" ]; then
  echo "ERROR: forbidden external sources in argo-cd/ (use Harbor or the GitOps repo):"
  echo "$urls"
  fail=1
fi

# 2. 443-only policy: no plain HTTP listener on the Gateway
if grep -rnE 'protocol: *HTTP$' gateway-api/; then
  echo "ERROR: plain HTTP listener found; only the HTTPS (443) listener is allowed"
  fail=1
fi

# 3. No ACME issuers: Let's Encrypt is unreachable from an air-gapped
#    cluster; certificates come from the internal PKI (kubeops-ca).
#    Comment lines are ignored.
if grep -rniE '^[^#]*(acme|letsencrypt)' --include='*.yaml' \
    argo-cd/ cert-manager/ cilium/ gateway-api/ harbor/ monitoring/; then
  echo "ERROR: ACME/Let's Encrypt reference found; use the internal PKI (kubeops-ca)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "Air-gap compliance: OK"
fi
exit "$fail"
