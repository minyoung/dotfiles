BIN_DIR := bin

build:
	go build -o $(BIN_DIR)/count-commands ./cmd/count-commands
	go build -o $(BIN_DIR)/top-commands ./cmd/top-commands
	go build -o $(BIN_DIR)/txc ./cmd/txc

test:
	go test ./...

fmt:
	gofmt -w .

lint:
	golangci-lint run ./...

vet:
	go vet ./...

check: fmt vet test

clean:
	rm -rf $(BIN_DIR)
