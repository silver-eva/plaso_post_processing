# include .env

# PROJECTNAME = $(shell basename $(PWD))
PROJECTNAME := "p3"

# go related variables
GOBASE := $(shell pwd)
GOPATH := "$(GOBASE)/vendor:$(GOBASE)"
GOBIN := "$(GOBASE)/bin"
GOFILES := $(wildcard *.go)

## install: Install missing dependencies. Runs `go get` internally. e.g; make install get=github.com/foo/bar
install: go-get

# Redirect error output to a file, so we can show it in development mode.
STDERR=/tmp/.$(PROJECTNAME)-stderr.txt

## clean: Clean build files. Runs `go clean` internally.
clean:
	@(MAKEFILE) go-clean

## compile: Compile the binary.
compile: go-vendor
	@-touch $(STDERR)
	@-rm $(STDERR)
	@-$(MAKE) -s go-compile 2> $(STDERR)
	@cat $(STDERR) | sed -e '1s/.*/\nError:\n/'  | sed 's/make\[.*/ /' | sed "/^/s/^/     /" 1>&2

go-compile: go-clean go-get go-build

go-vendor:
	@echo "  >  Vendoring dependencies..."
	@if [ ! -d $(GOBASE)/vendor ]; then go mod vendor; fi; 

go-build:
	@echo "  >  Building binary..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go build -o $(GOBIN)/$(PROJECTNAME) $(GOFILES)

go-generate:
	@echo "  >  Generating dependency files..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go generate $(generate)

go-get:
	@echo "  >  Checking if there is any missing dependencies..."
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go get $(get)

go-install:
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go install $(GOFILES)

go-clean:
	@echo "  >  Cleaning build cache"
	@GOPATH=$(GOPATH) GOBIN=$(GOBIN) go clean

all: help
help: Makefile
	@echo
	@echo "Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo