.PHONY: lint build test

DESTINATION ?= platform=iOS Simulator,name=iPhone 17 Pro Max

lint: ## Format Swift code using swift-format
	swift-format --in-place --recursive .

build: ## Build the project
	xcodebuild -project swisscroche.xcodeproj -destination '$(DESTINATION)' build

test: ## Run the unit tests on a simulator
	xcodebuild -project swisscroche.xcodeproj -scheme swisscroche -destination '$(DESTINATION)' test
