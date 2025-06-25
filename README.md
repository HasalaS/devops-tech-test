
# devops-tech-test

## EKS Cluster Setup & NGINX Deployment

This guide walks you through setting up an Amazon EKS cluster on AWS using Terraform, configuring IAM roles, security groups, and deploying a simple NGINX web application.

---

## Prerequisites

- AWS CLI configured with permissions to create EKS, EC2, IAM, and networking resources.
- Terraform installed (v1.3+ recommended).
- kubectl installed (compatible with your EKS version).
- AWS region: `ap-southeast-1`

---

## Steps

### 1. Deploy Infrastructure with Terraform

Run the following commands to initialize, plan, and apply your Terraform configuration:

```bash
terraform init
terraform plan
terraform apply
```

---

### 2. Verify EKS Cluster

After the cluster is created, configure kubectl and check the nodes:

```bash
kubectl get nodes
```

---

### 3. Deploy NGINX Application

Apply the Kubernetes manifests for the NGINX deployment and service:

```bash
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
```

---

### 4. Get Load Balancer URL

Fetch the external Load Balancer URL:

```bash
kubectl get svc nginx-service
```

Open the `EXTERNAL-IP` URL in your browser to see the NGINX welcome page.

---

## References

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
