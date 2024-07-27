# Version and registry settings
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
REGISTRY := digi64
TARGETOS := linux
TARGETARCH := $(shell uname -m)

# Map uname -m output to GOARCH
ifeq ($(TARGETARCH), x86_64)
	TARGETARCH := amd64
endif
ifeq ($(TARGETARCH), aarch64)
	TARGETARCH := arm64
endif

all: linux macos windows arm

linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -o ${APP}_linux_amd64 -ldflags "-X=github.com/digi64/kbot/cmd.appVersion=${VERSION}"

macos:
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -v -o ${APP}_macos_amd64 -ldflags "-X=github.com/digi64/kbot/cmd.appVersion=${VERSION}"

windows:
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -v -o ${APP}_windows_amd64.exe -ldflags "-X=github.com/digi64/kbot/cmd.appVersion=${VERSION}"

arm:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -v -o ${APP}_linux_arm64 -ldflags "-X=github.com/digi64/kbot/cmd.appVersion=${VERSION}"


format:
	gofmt -s -w ./

# Lint the code
lint:
	golint

# Run tests
test:
	go test -v

# Get dependencies
get:
	go get

# Build the application
build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X=github.com/digi64/kbot/cmd.appVersion=${VERSION}"

image:
	docker build . -t ${REGISTRY}/${APP}${VERSION}-${TARGETARCH}  --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}
	rm -f ${APP}_linux_amd64 ${APP}_macos_amd64 ${APP}_windows_amd64.exe ${APP}_linux_arm64