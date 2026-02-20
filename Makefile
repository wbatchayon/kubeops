# Makefile for KubeOps

# Variables
BINARY_NAME=kubeops
VERSION=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILDER=$(shell whoami)
GO=go
GOFLAGS=-ldflags="-X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.date=$(DATE) -X main.builtBy=$(BUILDER)"
INSTALL_DIR=/usr/local/bin

# Colors
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
BLUE=\033[0;34m
NC=\033[0m # No Color

.PHONY: all build test clean install lint vet fmt check help deps

# Default target
all: lint test build

# Build the binary
build:
	@echo "$(BLUE)Building $(BINARY_NAME)...$(NC)"
	$(GO) build $(GOFLAGS) -o bin/$(BINARY_NAME) ./cmd/kubeops
	@echo "$(GREEN)Binary built successfully: bin/$(BINARY_NAME)$(NC)"

# Build for multiple platforms
build-all:
	@echo "$(BLUE)Building for multiple platforms...$(NC)"
	GOOS=linux GOARCH=amd64 $(GO) build $(GOFLAGS) -o bin/$(BINARY_NAME)-linux-amd64 ./cmd/kubeops
	GOOS=linux GOARCH=arm64 $(GO) build $(GOFLAGS) -o bin/$(BINARY_NAME)-linux-arm64 ./cmd/kubeops
	GOOS=darwin GOARCH=amd64 $(GO) build $(GOFLAGS) -o bin/$(BINARY_NAME)-darwin-amd64 ./cmd/kubeops
	GOOS=darwin GOARCH=arm64 $(GO) build $(GOFLAGS) -o bin/$(BINARY_NAME)-darwin-arm64 ./cmd/kubeops
	@echo "$(GREEN)All binaries built successfully$(NC)"

# Run tests
test:
	@echo "$(BLUE)Running tests...$(NC)"
	$(GO) test -v -race -coverprofile=coverage.out -covermode=atomic ./...
	@echo "$(GREEN)Tests passed$(NC)"

# Run unit tests only
test-unit:
	@echo "$(BLUE)Running unit tests...$(NC)"
	$(GO) test -v -short ./...

# Run integration tests
test-integration:
	@echo "$(BLUE)Running integration tests...$(NC)"
	$(GO) test -v -tags=integration ./test/integration/...

# Run E2E tests
test-e2e:
	@echo "$(BLUE)Running E2E tests...$(NC)"
	$(GO) test -v -tags=e2e ./test/e2e/...

# Clean build artifacts
clean:
	@echo "$(BLUE)Cleaning...$(NC)"
	rm -rf bin/
	rm -f coverage.out
	@echo "$(GREEN)Cleaned$(NC)"

# Install the binary
install: build
	@echo "$(BLUE)Installing $(BINARY_NAME)...$(NC)"
	install -m 755 bin/$(BINARY_NAME) $(INSTALL_DIR)/$(BINARY_NAME)
	@echo "$(GREEN)Installed to $(INSTALL_DIR)/$(BINARY_NAME)$(NC)"

# Run linters
lint:
	@echo "$(BLUE)Running linters...$(NC)"
	which golangci-lint > /dev/null 2>&1 && golangci-lint run ./... || echo "$(YELLOW)golangci-lint not found, skipping...$(NC)"
	which staticcheck > /dev/null 2>&1 && staticcheck ./... || echo "$(YELLOW)staticcheck not found, skipping...$(NC)"

# Run go vet
vet:
	@echo "$(BLUE)Running go vet...$(NC)"
	$(GO) vet ./...

# Format code
fmt:
	@echo "$(BLUE)Formatting code...$(NC)"
	$(GO) fmt ./...
	gofmt -s -w .

# Check code (format, vet, lint)
check: fmt vet lint

# Download dependencies
deps:
	@echo "$(BLUE)Downloading dependencies...$(NC)"
	$(GO) mod download
	$(GO) mod tidy
	@echo "$(GREEN)Dependencies downloaded$(NC)"

# Terraform targets
terraform-init:
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	cd terraform/environments/dev && terraform init

terraform-plan:
	@echo "$(BLUE)Running Terraform plan...$(NC)"
	cd terraform/environments/dev && terraform plan

terraform-apply:
	@echo "$(RED)Applying Terraform (this will create resources)...$(NC)"
	cd terraform/environments/dev && terraform apply

terraform-destroy:
	@echo "$(RED)Destroying Terraform resources...$(NC)"
	cd terraform/environments/dev && terraform destroy

terraform-validate:
	@echo "$(BLUE)Validating Terraform...$(NC)"
	cd terraform/environments/dev && terraform validate

# Ansible targets
ansible-lint:
	@echo "$(BLUE)Running Ansible lint...$(NC)"
	which ansible-lint > /dev/null 2>&1 && ansible-lint ansible/ || echo "$(YELLOW)ansible-lint not found, skipping...$(NC)"

ansible-playbook:
	@echo "$(BLUE)Running Ansible playbook...$(NC)"
	which ansible-playbook > /dev/null 2>&1 && ansible-playbook ansible/playbooks/bootstrap.yaml || echo "$(YELLOW)ansible-playbook not found, skipping...$(NC)"

# Cluster API targets
capi-install:
	@echo "$(BLUE)Installing Cluster API...$(NC)"
	clusterctl init --infrastructure proxmox

capi-generate:
	@echo "$(BLUE)Generating Cluster API manifests...$(NC)"
	clusterctl generate cluster kubeops-cluster --kubeconfig ~/.kube/config

capi-apply:
	@echo "$(BLUE)Applying Cluster API manifests...$(NC)"
	kubectl apply -f cluster-api/overlays/dev/

# Helm targets
helm-dependency-update:
	@echo "$(BLUE)Updating Helm dependencies...$(NC)"
	cd helm-charts/base-chart && helm dependency update

helm-template:
	@echo "$(BLUE)Templating Helm charts...$(NC)"
	helm template kubeops helm-charts/base-chart

# Argo CD targets
argocd-sync:
	@echo "$(BLUE)Syncing Argo CD applications...$(NC)"
	argocd app sync kubeops --sync-wave 1

argocd-apps:
	@echo "$(BLUE)Deploying Argo CD applications...$(NC)"
	kubectl apply -f argo-cd/applications/

# Validation targets
validate-all: validate-terraform validate-ansible validate-yaml

validate-terraform:
	@echo "$(BLUE)Validating Terraform...$(NC)"
	cd terraform/environments/dev && terraform fmt -recursive && terraform validate

validate-ansible:
	@echo "$(BLUE)Validating Ansible...$(NC)"
	ansible-playbook --check ansible/playbooks/bootstrap.yaml

validate-yaml:
	@echo "$(BLUE)Validating YAML files...$(NC)"
	find . -name "*.yaml" -o -name "*.yml" | xargs -I {} yamllint -c .yamllint.yaml {} 2>/dev/null || echo "$(YELLOW)yamllint not found, skipping...$(NC)"

# CI/CD targets
ci: check test validate-all build

# Release target
release: build-all
	@echo "$(GREEN)Creating release for $(VERSION)$(NC)"
	gh release create $(VERSION) --title $(VERSION) bin/*

# Help target
help:
	@echo "$(BLUE)KubeOps Makefile$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  all              - Run lint, test, and build (default)"
	@echo "  build            - Build the binary"
	@echo "  build-all        - Build for multiple platforms"
	@echo "  test             - Run all tests"
	@echo "  test-unit        - Run unit tests only"
	@echo "  test-integration - Run integration tests"
	@echo "  test-e2e         - Run E2E tests"
	@echo "  clean            - Clean build artifacts"
	@echo "  install          - Install the binary"
	@echo "  lint             - Run linters"
	@echo "  vet              - Run go vet"
	@echo "  fmt              - Format code"
	@echo "  check            - Run format, vet, and lint"
	@echo "  deps             - Download dependencies"
	@echo ""
	@echo "  terraform-init   - Initialize Terraform"
	@echo "  terraform-plan   - Run Terraform plan"
	@echo "  terraform-apply  - Apply Terraform changes"
	@echo "  terraform-destroy- Destroy Terraform resources"
	@echo ""
	@echo "  ansible-lint     - Run Ansible lint"
	@echo "  ansible-playbook - Run Ansible playbook"
	@echo ""
	@echo "  capi-install     - Install Cluster API"
	@echo "  capi-generate    - Generate CAPI manifests"
	@echo "  capi-apply       - Apply CAPI manifests"
	@echo ""
	@echo "  helm-dependency-update - Update Helm dependencies"
	@echo "  helm-template    - Template Helm charts"
	@echo ""
	@echo "  argocd-sync      - Sync Argo CD applications"
	@echo "  argocd-apps      - Deploy Argo CD applications"
	@echo ""
	@echo "  validate-all     - Run all validations"
	@echo "  ci               - Run CI pipeline"
	@echo "  release          - Create release"
	@echo ""
	@echo "  help             - Show this help"
