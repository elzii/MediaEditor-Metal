all: build

# Optimization Flags:
# -O3: Aggressive code optimization
# -ffast-math: Fast (but potentially less precise) math
# -flto: Link-time optimization (across all files)
# -DNDEBUG: Disables assertions for performance
OPTIM_FLAGS = -Xcc -O3 -Xcc -ffast-math -Xcc -flto -Xcc -DNDEBUG -Xswiftc -O

build:
	swift build $(OPTIM_FLAGS)

release:
	swift build -c release $(OPTIM_FLAGS)

run:
	swift run mec $(OPTIM_FLAGS)

run-release:
	swift run -c release mec $(OPTIM_FLAGS)

package: release
	./package.sh

embed:
	./embed

archive:
	./migrate.sh

clean:
	swift package clean
	rm -rf dist/

.PHONY: all build release run run-release clean package
