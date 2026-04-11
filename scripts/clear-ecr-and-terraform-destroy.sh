#!/usr/bin/env bash
#
# Teardown helper: remove every image from the ECR repository, then terraform destroy.
# AWS often blocks deleting a non-empty ECR repo; emptying it first avoids that error.
#
# Prerequisites: AWS CLI configured; run from repo root or via path as shown.
#
# Usage:
#   ./scripts/clear-ecr-and-terraform-destroy.sh [terraform destroy args...]
#
# Example:
#   ./scripts/clear-ecr-and-terraform-destroy.sh -auto-approve
#
# Environment:
#   ECR_REPOSITORY_NAME  Repository name (default: portfolio-app).
# Region is fixed to us-east-1.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

REGION="us-east-1"
ECR_REPOSITORY_NAME="${ECR_REPOSITORY_NAME:-portfolio-app}"

echo "Removing all images from ${ECR_REPOSITORY_NAME} (${REGION})..."

# Delete in batches of up to 100 (ECR batch-delete-image limit). Loop until none remain.
while true; do
  DIGESTS=()
  while IFS= read -r line; do
    [[ -n "${line}" ]] && DIGESTS+=("${line}")
  done < <(aws ecr list-images \
    --repository-name "${ECR_REPOSITORY_NAME}" \
    --region "${REGION}" \
    --query 'imageIds[*].imageDigest' \
    --output text 2>/dev/null | tr '\t' '\n' | grep -E '^sha256:' || true)

  if [[ ${#DIGESTS[@]} -eq 0 ]]; then
    break
  fi

  batch=("${DIGESTS[@]:0:100}")
  ids=()
  for d in "${batch[@]}"; do
    ids+=(imageDigest="${d}")
  done

  aws ecr batch-delete-image \
    --repository-name "${ECR_REPOSITORY_NAME}" \
    --region "${REGION}" \
    --image-ids "${ids[@]}"
done

echo "ECR repository is empty. Running terraform destroy in ${TF_DIR}..."
cd "${TF_DIR}"
terraform destroy "$@"
