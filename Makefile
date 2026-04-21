# Makhua Lexicon - Development Makefile
# Handles Firebase deployments, Flutter web builds, and testing

.PHONY: help install deps clean test test-watch build-web deploy-rules deploy-web deploy-all lint format check

# Default target
help: ## Show this help message
	@echo "Makhua Lexicon Development Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Installation and Dependencies
install: ## Install Flutter dependencies
	flutter pub get

deps: install ## Alias for install

# Development
clean: ## Clean build artifacts and dependencies
	flutter clean
	flutter pub get

# Testing
test: ## Run all tests
	flutter test

test-watch: ## Run tests in watch mode
	flutter test --watch

test-coverage: ## Run tests with coverage report
	flutter test --coverage
	@echo "Coverage report generated in coverage/lcov.info"

# Code Quality
lint: ## Run Flutter linter
	flutter analyze

format: ## Format Dart code
	dart format .

check: lint test ## Run linting and tests

# Build
build-web: ## Build Flutter web app for production
	flutter build web --release

build-web-debug: ## Build Flutter web app for debugging
	flutter build web --debug

# Firebase Operations
firebase-login: ## Login to Firebase CLI
	firebase login

firebase-init: ## Initialize Firebase project (run once)
	firebase init

# Firebase Deployments
deploy-rules: ## Deploy Firestore rules and indexes
	@echo "Deploying Firestore rules and indexes..."
	firebase deploy --only firestore:rules,firestore:indexes

deploy-hosting: ## Deploy to Firebase Hosting
	@echo "Building web app..."
	$(MAKE) build-web
	@echo "Deploying to Firebase Hosting..."
	firebase deploy --only hosting

deploy-firestore: ## Deploy Firestore configuration
	@echo "Deploying Firestore rules and indexes..."
	firebase deploy --only firestore

deploy-all: ## Deploy everything (rules, indexes, and hosting)
	@echo "Deploying complete application..."
	$(MAKE) build-web
	firebase deploy

# Development Workflow
dev-setup: install firebase-login ## Initial development setup
	@echo "Development setup complete!"
	@echo "Run 'make dev' to start development server"

dev: ## Start development server
	flutter run -d web-server --web-port 3000

dev-debug: ## Start development server in debug mode
	flutter run -d web-server --web-port 3000 --debug

# Production Workflow
prod-deploy: check build-web deploy-all ## Full production deployment with checks
	@echo "Production deployment complete!"

# Firebase Project Management
firebase-status: ## Check Firebase project status
	firebase projects:list

firebase-use: ## Switch Firebase project
	@echo "Available projects:"
	firebase projects:list
	@echo "Run: firebase use <project-id>"

# Utility Commands
logs: ## View Firebase logs
	firebase functions:log

emulators: ## Start Firebase emulators for local development
	firebase emulators:start

emulators-ui: ## Start Firebase emulators with UI
	firebase emulators:start --ui

# Quick Commands
quick-deploy: build-web deploy-hosting ## Quick web deployment without rules
	@echo "Quick deployment complete!"


# Git Integration
pre-commit: check format ## Run pre-commit checks
	@echo "Pre-commit checks passed!"

# Emergency Commands
rollback: ## Rollback Firebase deployment
	firebase hosting:channel:deploy live

