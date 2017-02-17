#!/bin/bash
# assumes you use aws-vault

STATE_REGION="eu-west-1"
STATE_BUCKET="sudoers-terraform-state"

function die() {
    echo $@
    exit 1
}

# Requirements
hash aws-vault 2> /dev/null || die "Requires aws-vault. https://github.com/99designs/aws-vault"
hash jq 2>/dev/null || die "Requires jq. https://github.com/stedolan/jq"
hash aws 2> /dev/null || die "Requires awscli"

if [ "$(uname)" == "Darwin" ]; then
    WORK_DIR=$(cd "$(dirname "$0")/../" && pwd)
else
    WORK_DIR=$(readlink -f "$(dirname "$(readlink -f "$0")")/../")
fi

if [ -z "${AWS_ACCESS_KEY_ID}" ] && [  -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    die "[Error]: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY is not set"
fi

STATE_BUCKET=$(aws --region ${STATE_REGION} s3 ls | awk '${ print $3}' | grep ${STATE_BUCKET} | head)
if [ -z "${STATE_BUCKET}" ]; then
    echo "Creating remote state bucket"
    aws --region "${STATE_REGION}" s3 mb s3://"${STATE_BUCKET}"
fi

echo "Setting up remote config"
terraform remote config \
    -backend=s3
    -backend-config="bucket=${STATE_BUCKET}" \
    -backend-config="key=sudoers-aws/terraform.tfstate" \
    -backend-config="region=${STATE_REGION}"
