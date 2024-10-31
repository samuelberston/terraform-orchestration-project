Terraform orchestration and GitOps project

This terraform configuration provides the infrastructure for a three-tier distributed web application.
It contains a public subnet for the web endpoint and a private subnet for the backend server.
There is also an RDS PostgreSQL instance to store application data.
The configuration is hardened using Security Groups, Network ACLs, IAM roles/policies and SSH keys.
Security and performance monitoring are set up with CloudTrail and CloudWatch.
Additionally, there is a GitOps workflow which includes Chekov and Trivy security scans.
