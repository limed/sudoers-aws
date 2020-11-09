#!/bin/bash

STATE_REGION="eu-west-1"
STATE_PREFIX="sudoers-terraform-state"

if [ -z "${AWS_ACCESS_KEY_ID}" ] && [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo "AWS Env not set"
    exit 1
fi

usage() {
    echo -en "Usage: $0 [options] [commands] \n\n"
    echo -en "Options: \n"
    echo -en "  -x | --debug            Debug mode\n\n"
    echo -en "Commands: \n"
    echo -en "  create-tf-state           Creates a terraform state bucket\n"
    echo -en "  create-state-table        Create dynamodb state table\n\n"
}

account_id(){
    aws sts get-caller-identity --query "Account" --output text
}

create_tf_state_bucket() {

    STATE_BUCKET=$(aws --region "${STATE_REGION}" s3 ls | grep "${STATE_PREFIX}" | cut -d ' ' -f 3)
    if [ -z "${STATE_BUCKET}" ]; then
        STATE_BUCKET="${STATE_PREFIX}"

        echo "Creating remote state bucket ${STATE_BUCKET}"
        aws --region "${STATE_REGION}" s3 mb "s3://${STATE_BUCKET}"
        aws --region "${STATE_REGION}" s3api put-bucket-versioning --bucket "${STATE_BUCKET}" --versioning-configuration Status=Enabled
    else
        # Check for versionning
        BUCKET_VERSIONNING=$(aws --region "${STATE_REGION}" s3api get-bucket-versioning --bucket "${STATE_BUCKET}" | jq -r .Status)
        if [ "${BUCKET_VERSIONNING}" != "Enabled" ]; then
            echo "Enabling Versioning on state bucket"
            aws --region "${STATE_REGION}" s3api put-bucket-versioning --bucket "${STATE_BUCKET}" --versioning-configuration Status=Enabled
        fi
    fi
}

create_state_table() {

    STATE_TABLE=$(aws dynamodb list-tables --region "${STATE_REGION}" --query "TableNames[]" --output text | grep "${STATE_PREFIX}")
    if [ -z "${STATE_TABLE}" ]; then
        STATE_TABLE="${STATE_PREFIX}"

        echo "Creating dynamodb state table ${STATE_TABLE}"
        aws dynamodb create-table \
            --region "${STATE_REGION}" \
            --table-name "${STATE_TABLE}" \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
            --key-schema AttributeName=LockID,KeyType=HASH \
            --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
    fi
}

while [ "$1" != "" ]; do
    case $1 in
        -x | --setx )
            set -x
            export TF_LOG='DEBUG'
        ;;
        -h | --help )
            usage
            GOT_COMMAND=1
        ;;
        create-tf-state)
            create_tf_state_bucket
            GOT_COMMAND=1
        ;;
        create-state-table)
            create_state_table
            GOT_COMMAND=1
        ;;
	esac
	shift
done

# If we did not get a valid command print the help message
if [ "${GOT_COMMAND:-0}" == 0 ]; then
    usage
    exit 1
fi
