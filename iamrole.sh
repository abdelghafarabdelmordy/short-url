#!/usr/bin/env bash

# Set role name
ROLE_NAME="CodeBuildKubectlRole"

# Define assume role policy
TRUST=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

# Define inline IAM policy
IAM_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "eks:Describe*",
      "Resource": "*"
    }
  ]
}
EOF
)

# List of policies to attach
POLICIES=(
  "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
  "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
)

# Function to create IAM role
create_role() {
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "$TRUST" \
    --output text \
    --query 'Role.Arn'
}

# Function to add inline policy
add_inline_policy() {
  aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "eks-describe" \
    --policy-document "$IAM_POLICY"
}

# Function to attach managed policies
attach_policies() {
  for policy in "${POLICIES[@]}"; do
    aws iam attach-role-policy \
      --role-name "$ROLE_NAME" \
      --policy-arn "$policy"
  done
}

# Execute functions
create_role
add_inline_policy
attach_policies

echo "IAM Role $ROLE_NAME and policies have been configured successfully."
