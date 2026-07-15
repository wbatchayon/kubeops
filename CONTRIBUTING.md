# Contributing to KubeOps

Thank you for your interest in contributing to KubeOps!

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](docs/CODE_OF_CONDUCT.md).

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
   git commit -m "feat: add your feature"
   ```

5. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

6. Create a Pull Request

## Commit Message Guidelines

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

- Format: `<type>(<optional scope>): <description>` — e.g. `fix(ansible): pin containerd version`
- Common types: `feat`, `fix`, `docs`, `ci`, `refactor`, `test`, `chore`
- Use clear, descriptive commit messages
- Reference issues using `#issue-number`

## Pull Request Process

1. For significant changes, open an issue first (bug report or feature
   request template) so the approach can be discussed before you invest
   time in it
2. Fill in the pull request template; keep one PR focused on one concern
3. Update documentation for any changes
4. Add tests for new features
5. Ensure the CI passes — all stages, including the airgap guard
   (`make validate-all` and `make test` reproduce the main gates locally)
6. Update the CHANGELOG.md under `[Unreleased]`
7. Review is requested automatically from the code owners
   (`.github/CODEOWNERS`); address feedback with follow-up commits, they
   are squashed on merge with a Conventional Commit title

The `main` branch is protected: direct pushes are reserved to the
maintainers, and a pull request can only be merged with an approving
code-owner review, all CI checks green (airgap guard included), every
conversation resolved, and a linear history (squash merge only).

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

1. Check existing issues first
2. Open a new issue using the **Bug Report** template (description, steps
   to reproduce, expected vs actual behavior, environment details)
3. Security vulnerabilities must **not** be reported in public issues —
   follow [docs/SECURITY.md](docs/SECURITY.md) instead

## Feature Requests

1. Search existing issues first
2. Open a new issue using the **Feature Request** template (problem,
   proposed solution, use cases)

## Releases (maintainers)

1. Move the `[Unreleased]` CHANGELOG entries under a new `[X.Y.Z]` section
   with the date
2. Tag and push: `git tag vX.Y.Z && git push origin vX.Y.Z`
3. The [Release workflow](.github/workflows/release.yaml) does the rest:
   GitHub Release with multi-platform binaries and sha256 checksums
   (GoReleaser), container image on `ghcr.io/wbatchayon/kubeops`, and the
   base Helm chart pushed to `oci://ghcr.io/wbatchayon/charts`
4. Dry-run locally with `make release-snapshot`

## License

By contributing to KubeOps, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).

## Questions?

- Open an issue for questions
- Join our community discussions
- Check the [documentation](docs/)
