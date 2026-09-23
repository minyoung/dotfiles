BINARY := txc
BIN_DIR := bin

.PHONY: build test fmt vet check install clean

build:
	go build -o $(BIN_DIR)/$(BINARY) .

test:
	go test ./...

fmt:
	gofmt -w .

vet:
	go vet ./...

check: fmt vet test

install:
	go install .

clean:
	rm -rf $(BIN_DIR)
