PROJECT := Claude Switcher/Claude Switcher.xcodeproj
SCHEME  := Claude Switcher

.PHONY: build run

build:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration Debug build

run: build
	@APP=$$(xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration Debug -showBuildSettings 2>/dev/null \
		| awk '/^\s+BUILT_PRODUCTS_DIR/{print $$3}'); \
	pkill -x "Claude Switcher" 2>/dev/null; sleep 0.5; \
	open "$$APP/Claude Switcher.app"
