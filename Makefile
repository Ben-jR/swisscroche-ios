.PHONY: lint test

DESTINATION ?= platform=iOS Simulator,name=iPhone 17 Pro Max

lint: ## Format Swift code using swift-format
	swift-format --in-place --recursive .

test: ## Run the unit tests on a simulator
	xcodebuild -project saracroche.xcodeproj -scheme saracroche -destination '$(DESTINATION)' test
