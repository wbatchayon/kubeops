# Security Policy

## Supported Versions

KubeOps has no tagged release yet. Until v0.1.0 is published, security fixes
land on the `main` branch only:

| Version | Supported          |
| ------- | ------------------ |
| `main`  | :white_check_mark: |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please report it responsibly.

### How to Report

1. **Do NOT** create a public GitHub issue for security vulnerabilities
2. Report privately via [GitHub Security Advisories](https://github.com/wbatchayon/kubeops/security/advisories/new),
   or email the maintainer at batchayonwilliam@gmail.com
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact of the vulnerability
   - Any suggested fixes (optional)

### Response Timeline

- We aim to acknowledge reports within 48 hours
- We aim to provide a more detailed response within 7 days
- We will work with you to develop a fix
- We will publish a security advisory once the fix is available

## Security Best Practices

### Deployment

- Always use SSH keys instead of passwords for node access
- Use OpenBao for secret management
- Enable network policies with Cilium
- Use TLS for all communications
- Keep Kubernetes and all components up to date

### Access Control

- Follow principle of least privilege
- Use RBAC for Kubernetes resources
- Rotate credentials regularly
- Use separate service accounts for different workloads

### Network Security

- Only 443/HTTPS is exposed externally: the Gateway has a single HTTPS
  listener and the node firewall (nftables, default drop) blocks
  everything else — see [Air-Gapped Deployment](airgap.md)
- Enable network policies
- Use Cilium for pod-to-pod encryption (WireGuard)
- Monitor network traffic

### Monitoring

- Enable audit logging
- Set up Prometheus alerts for suspicious activity
- Monitor for unauthorized access attempts
- Review logs regularly

## Security Updates

We will publish security advisories on:
- GitHub Security Advisories
- Release notes
- Community channels

## Encryption

### Data at Rest

- Terraform state files should be encrypted
- Use OpenBao for sensitive data storage
- Enable disk encryption on VMs

### Data in Transit

- TLS 1.3 for all API communications
- WireGuard or IPSec for pod-to-pod communication
- mTLS for service mesh

## Compliance

KubeOps is designed to help meet various compliance requirements:
- SOC 2
- ISO 27001
- GDPR
- HIPAA

Note: Compliance validation is the responsibility of the operator.

## Security Tools

The CI pipeline runs the following security tooling on every push and pull
request:

- [Trivy](https://github.com/aquasecurity/trivy) - Filesystem vulnerability scan, results uploaded to GitHub code scanning
- [Ansible Lint](https://github.com/ansible/ansible-lint) - Ansible best-practice and security checks

## Thank You

We appreciate your efforts to responsibly disclose security issues.
