#  EKS PLATFORM: MANAGED NODE

---

## ✅ What’s included?

| Component                   |  Description                                      |
|-----------------------------|---------------------------------------------------|
| **Terraform**               | Modular infrastructure definition                 |
| `modules/vpc`               | VPC with public and private subnets               |
| `modules/vpc_endpoints`     | For Bastion host in priv subnet to connect SSM    |
| `modules/sg`                | Security Groups                                   |
| `modules/iam`               | IAM roles and policies for EKS                    |
| `modules/eks`               | EKS                                               |
| `dev.auto.tfvars`           | Example configuration with domain and certificate |

---

## 🔧 Prerequisites

To run this project, you’ll need:

1. **AWS credentials** configured in your local environment    

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

or set your ~/.aws/credentials  
```
[default]
aws_access_key_id = "your-access-key"
aws_secret_access_key = "your-secret-key"
```

## 🚀 Deploy resources  

```
terraform init
terraform plan
terraform apply
```

## ARTICLE  ##############################################################################

Connection to AWS from your machine is done by using SSM Agent. EC2 does not use public IP.
```
aws ssm start-session --target i-XXXXXXXXXXXX --region <region>
```

## EKS  WORKLOAD TYPES ###################################################################
There are 4 types of running workloads:  

## EKS compute options

**1. Managed Node Groups (EC2)**  
EKS creates ASG and Launch Template for you.  
**Pros:** simple, rolling node updates  
**Cons:** still manage EC2s, AMI lifecycle, capacity, costs

**2. Self-managed nodes (EC2, own ASG)**  
You create the ASG and Launch Template yourself and join nodes to the cluster.  
**Pros:** full control, custom/non-standard AMIs  
**Cons:** more manual work, more operational overhead

**3. Karpenter (EC2 without ASG)**  
Provisions EC2 instances dynamically based on pending Pods.  
**Pros:** better instance fit, fast scale-up, lower costs  
**Cons:** extra component to maintain, different model than ASG

**4. Fargate (serverless Pods)**  
No EC2 nodes or ASGs; you pay for requested CPU and RAM.  
**Pros:** no node management, good for small/simple workloads  
**Cons:** no DaemonSets, limited CSI support, often higher cost



## EKS RESOURCES  
########################################################################################
1) VPC/subnets  
1) OIDC  (connected with issuer)  
2) EKS Control Plane  
    - name  
    - role  
    - vpc_config  
4) Managed Node Group  
    - cluster_name  
    - node_role_arn  
    - subnets_ids  
    - ami_type  
    - capacity_type  
    - scalling_config  
6) Managed add-ons  
    - cni  
    - coredns  
    - kubeproxy  
    - ebs_csi  
7) IAM Role eks_cluster  
8) IAM Role eks_node  
   - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy  
   - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy  
   - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
7) Access Entries ( instead aws-auth ) # Responsible for access into CLUSTER   
8) EKS Access Policy association   

## EKS LOGGING INTO CLUSTER  
########################################################################################  
) FOR LOGGING INTO CLUSTER WE HAVE TWO OPTIONS  
  - Access Entries <<< preferred and used below
  - aws-auth  

