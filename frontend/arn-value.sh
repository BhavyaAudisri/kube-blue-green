#!/bin/bash

# Fetch ARN from SSM
TG_ARN=$(aws ssm get-parameter \
  --name "/expense/dev/aws_lb_target_group_arn" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

# Check if ARN retrieval was successful
if [ -z "$TG_ARN" ]; then
  echo "Error: Failed to retrieve ARN from SSM."
  exit 1
fi

# Print the fetched ARN (optional)
echo "Successfully fetched ARN: $TG_ARN"

# Create the TargetGroupBinding YAML template with the fetched ARN
cat <<EOF > target-group.yaml
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: frontend
  namespace: expense
spec:
  serviceRef:
    name: frontend # route traffic to the frontend service
    port: 80
  targetGroupARN: ${TG_ARN}
EOF

echo "Applied TargetGroupBinding successfully to the Kubernetes cluster."
