.PHONY: build
.PHONY: frameworks

CWD := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

all: build frameworks

# OPENSSL_VERSION="3.1.4" $(CWD)/scripts/build.sh

build:
	OPENSSL_VERSION="1.1.1w" $(CWD)/scripts/build.sh -s

frameworks:
	$(CWD)/scripts/create-frameworks.sh