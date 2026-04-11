#!/usr/bin/env bash
#
# One-shot bootstrap helper: apply Terraform, then build and push a Docker image
# to ECR so the ECS service can run a task before the first CodePipeline run.
# Day-to-day deploys normally go through GitHub → CodePipeline → CodeBuild.
#
# Prerequisites: AWS CLI configured, Docker running, terraform.tfvars set in ./terraform.
#
# Usage:
#   ./scripts/terraform-apply-and-push-docker-ecr.sh [terraform apply args...] [-- [image-tag]]
#
# Examples:
#   ./scripts/terraform-apply-and-push-docker-ecr.sh
#   ./scripts/terraform-apply-and-push-docker-ecr.sh -auto-approve
#   ./scripts/terraform-apply-and-push-docker-ecr.sh -auto-approve -- v1.0.0
#
# Environment:
#   ECR_REPOSITORY_NAME  Repository name (default: portfolio-app, must match Terraform).
# Region is fixed to us-east-1.

set -euo pipefail

# Repo root (parent of scripts/)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

REGION="us-east-1"
ECR_REPOSITORY_NAME="${ECR_REPOSITORY_NAME:-portfolio-app}"

# Split arguments: everything before "--" goes to terraform; optional tag after "--".
TF_ARGS=()
while [[ $# -gt 0 ]]; do
  if [[ "$1" == "--" ]]; then
    shift
    break
  fi
  TF_ARGS+=("$1")
  shift
done

IMAGE_TAG_ARG="${1:-}"
if [[ -n "${IMAGE_TAG_ARG}" ]]; then
  shift || true
fi
if [[ $# -gt 0 ]]; then
  echo "Unexpected arguments after image tag: $*" >&2
  exit 1
fi

echo "Running terraform apply in ${TF_DIR}..."
cd "${TF_DIR}"
terraform apply "${TF_ARGS[@]}"

cd "${ROOT_DIR}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REPOSITORY_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}"

# Default tag: short git SHA, or "manual" if not in a git checkout.
IMAGE_TAG="${IMAGE_TAG_ARG:-$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || echo manual)}"

echo "Logging in to ECR (${REGION})..."
aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${REPOSITORY_URI}"

# --provenance=false: omit OCI build attestations (keeps manifests compatible with
# typical ECR/ECS consumption; aligns with common AWS container image practices).
echo "Building ${REPOSITORY_URI}:${IMAGE_TAG}..."
docker build --provenance=false -t "${REPOSITORY_URI}:${IMAGE_TAG}" .
docker tag "${REPOSITORY_URI}:${IMAGE_TAG}" "${REPOSITORY_URI}:latest"

echo "Pushing ${IMAGE_TAG} and latest..."
docker push "${REPOSITORY_URI}:${IMAGE_TAG}"
docker push "${REPOSITORY_URI}:latest"

echo "Done. Image: ${REPOSITORY_URI}:${IMAGE_TAG}"
