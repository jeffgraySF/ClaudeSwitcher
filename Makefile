PROJECT := Claude Switcher/Claude Switcher.xcodeproj
SCHEME  := Claude Switcher

.PHONY: build run install

build:
	xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration Debug build

run: install
	pkill -x "Claude Switcher" 2>/dev/null; sleep 0.5; \
	open "/Applications/Claude Switcher.app"

install: build
	@APP=$$(xcodebuild -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration Debug -showBuildSettings 2>/dev/null \
		| grep '^\s*BUILT_PRODUCTS_DIR' | cut -d= -f2 | xargs); \
	cp -R "$$APP/Claude Switcher.app" "/Applications/Claude Switcher.app"
