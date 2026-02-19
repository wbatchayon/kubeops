# Contributing to KubeOps

Thank you for your interest in contributing to KubeOps!

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

### Prerequisites

- Go 1.21 or later
- Terraform 1.6+ 
- Ansible 2.14+
- Kubernetes cluster (for testing)
- Docker (for building containers)

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/kubeops.git
   cd kubeops
   ```

3. Install dependencies:
   ```bash
   go mod download
   make deps
   ```

4. Run tests:
   ```bash
   make test
   ```

5. Build the binary:
   ```bash
   make build
   ```

## Making Changes

1. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes
3. Run tests:
   ```bash
   make test
   make lint
   ```

4. Commit your changes:
   ```bash
   git commit -m "Add your feature or fix"
   ```

5. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

6. Create a Pull Request

## Commit Message Guidelines

- Use clear, descriptive commit messages
- Start with a verb (Add, Fix, Update, Remove)
- Reference issues using `#issue-number`

## Pull Request Process

1. Update documentation for any changes
2. Add tests for new features
3. Ensure all tests pass
4. Update the CHANGELOG.md
5. Request review from maintainers

## Coding Standards

- Go: Follow [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- YAML: Use 2-space indentation
- Terraform: Follow HashiCorp best practices
- Ansible: Follow Ansible Galaxy guidelines

## Documentation

- Keep documentation up to date with code changes
- Use clear, simple language
- Include examples where possible

## Reporting Bugs

1. Check existing issues
2. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details

## Feature Requests

1. Search existing issues
2. Create an issue with:
   - Clear description
   - Use cases
   - Proposed solution

## License

By contributing to KubeOps, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).

## Questions?

- Open an issue for questions
- Join our community discussions
- Check the [documentation](docs/)
