# Azure Cloud Security Baseline

## Overview
This document outlines security best practices and baseline configurations for Azure cloud infrastructure.

## Identity and Access Management

### Entra ID (Azure AD) Configuration
- Enable password complexity requirements
- Enforce password expiration (90 days)
- Implement account lockout policies
- Enable password history (12 passwords)

### Multi-Factor Authentication (MFA)
- Require MFA for all admin accounts
- Require MFA for all users accessing cloud resources
- Use Conditional Access policies to enforce MFA

### Role-Based Access Control (RBAC)
- Follow principle of least privilege
- Use built-in roles when possible
- Create custom roles for specific needs
- Regularly review and audit role assignments
- Remove unused role assignments

## Network Security

### Virtual Network Configuration
- Use private IP addressing (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Implement network segmentation
- Use Network Security Groups (NSGs) for traffic control
- Enable DDoS protection for public-facing resources

### Network Security Groups (NSGs)
- Deny all inbound traffic by default
- Allow only necessary ports and protocols
- Use service tags for Azure services
- Log all NSG traffic

### Azure Firewall
- Deploy Azure Firewall for centralized management
- Configure application rules for web traffic
- Implement network rules for non-HTTP traffic
- Enable threat intelligence-based filtering

## Compute Security

### Virtual Machines
- Use Azure Key Vault for secrets management
- Enable Azure Disk Encryption
- Keep VMs patched and updated
- Use Azure Security Center recommendations
- Implement Just-In-Time (JIT) access for RDP/SSH

### Container Security
- Scan container images for vulnerabilities
- Use Azure Container Registry for private images
- Implement network policies for containers
- Enable Azure Defender for containers

## Storage Security

### Storage Accounts
- Enable Secure Transfer (HTTPS only)
- Use private endpoints for storage access
- Implement blob-level access policies
- Enable soft delete for blobs

### Data Encryption
- Enable encryption at rest
- Use customer-managed keys (CMK) when possible
- Enable encryption in transit (TLS 1.2+)

## Monitoring and Logging

### Azure Monitor
- Enable diagnostic logging for all resources
- Send logs to Log Analytics workspace
- Configure alert rules for security events
- Set up activity log alerts

### Azure Security Center
- Enable Azure Defender for all subscriptions
- Review security recommendations
- Implement security baselines
- Configure continuous assessment

### Azure Sentinel
- Enable Azure Sentinel for SIEM capabilities
- Configure data connectors
- Create detection rules for threats
- Set up playbooks for automation

## Compliance and Governance

### Azure Policy
- Implement organizational policies
- Enforce naming conventions
- Require resource tagging
- Enforce security configurations

### Tags and Resource Organization
- Tag all resources with:
  - Environment (dev, test, prod)
  - Cost Center
  - Owner
  - Project
- Use resource groups for logical grouping

### Cost Management
- Set up budget alerts
- Review cost reports regularly
- Use Azure Cost Management + Billing
- Implement cost allocation tags

## Backup and Disaster Recovery

### Backup Strategy
- Enable Azure Backup for VMs
- Configure backup retention policies
- Test backup restoration regularly
- Document recovery procedures

### Disaster Recovery
- Use Azure Site Recovery for VM replication
- Define Recovery Time Objectives (RTO)
- Define Recovery Point Objectives (RPO)
- Test disaster recovery plans

## Incident Response

### Security Incident Procedures
1. Detect and identify security incidents
2. Contain the threat
3. Eradicate the threat
4. Recover affected systems
5. Document lessons learned

### Security Contacts
- Security Team: security@organization.com
- Azure Support: Available through Azure Portal
- Incident Response: incident@organization.com

## Compliance Standards

### Standards to Consider
- ISO 27001
- NIST Cybersecurity Framework
- CIS Azure Foundations Benchmark
- PCI DSS (if handling payment data)
- HIPAA (if handling healthcare data)

## Regular Security Tasks

### Daily
- Review security alerts
- Check for failed login attempts
- Monitor resource usage

### Weekly
- Review access logs
- Check for unused resources
- Review cost reports

### Monthly
- Audit RBAC assignments
- Review security recommendations
- Update security baselines
- Test backup restoration

### Quarterly
- Conduct security assessments
- Review and update policies
- Train staff on security practices
- Review disaster recovery plans




























