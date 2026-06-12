#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Deploying LogIQ Dashboard to AWS EKS${NC}"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured. Run 'aws configure' first${NC}"
    exit 1
fi

# Set variables
export AWS_REGION=${AWS_REGION:-"us-east-1"}
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export ECR_REPO="logiq-dashboard"

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "   Region: $AWS_REGION"
echo "   Account: $AWS_ACCOUNT_ID"
echo "   Repo: $ECR_REPO"

# Check if EKS cluster exists
if ! eksctl get cluster logiq-demo &> /dev/null; then
    echo -e "${YELLOW}🔧 Creating EKS cluster (this takes 10-15 minutes)...${NC}"
    eksctl create cluster \
        --name logiq-demo \
        --region $AWS_REGION \
        --nodegroup-name workers \
        --node-type t3.medium \
        --nodes 2 \
        --managed
else
    echo -e "${GREEN}✅ EKS cluster already exists${NC}"
fi

# Update kubeconfig
echo -e "${YELLOW}🔑 Updating kubeconfig...${NC}"
aws eks update-kubeconfig --name logiq-demo --region $AWS_REGION

# Create ECR repository if it doesn't exist
if ! aws ecr describe-repositories --repository-names $ECR_REPO &> /dev/null; then
    echo -e "${YELLOW}📦 Creating ECR repository...${NC}"
    aws ecr create-repository --repository-name $ECR_REPO
else
    echo -e "${GREEN}✅ ECR repository already exists${NC}"
fi

# Login to ECR
echo -e "${YELLOW}🔐 Logging into ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Build Docker image
echo -e "${YELLOW}🏗️ Building Docker image...${NC}"
docker build -f docker/Dockerfile -t $ECR_REPO:latest .

# Tag and push
echo -e "${YELLOW}📤 Pushing to ECR...${NC}"
docker tag $ECR_REPO:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/$ECR_REPO:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/$ECR_REPO:latest

# Update deployment.yaml with AWS account ID
cp k8s/deployment.yaml k8s/deployment.yaml.tmp
sed -i.bak "s/\${AWS_ACCOUNT_ID}/$AWS_ACCOUNT_ID/g" k8s/deployment.yaml
sed -i.bak "s/\${AWS_REGION}/$AWS_REGION/g" k8s/deployment.yaml

# Apply Kubernetes manifests
echo -e "${YELLOW}☸️ Deploying to Kubernetes...${NC}"
kubectl apply -f k8s/deployment.yaml

# Wait for deployment
echo -e "${YELLOW}⏳ Waiting for deployment to be ready...${NC}"
kubectl rollout status deployment/logiq-dashboard --timeout=5m

# Get the LoadBalancer URL
echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo -e "${GREEN}📊 Dashboard URL:${NC}"
kubectl get svc logiq-dashboard-service -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
echo ""
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo "   1. Create email secret: kubectl create secret generic email-secrets --from-literal=email-user='your-email@gmail.com' --from-literal=email-pass='your-password'"
echo "   2. Access the dashboard at the URL above"
echo "   3. Monitor with: kubectl get pods -w"
