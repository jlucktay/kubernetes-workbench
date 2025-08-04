FROM golang:1.24 AS build

ARG GOCACHE=/root/.cache/go-build
ARG GOMODCACHE=/root/.cache/go-mod

ENV GOCACHE=${GOCACHE}
ENV GOMODCACHE=${GOMODCACHE}

WORKDIR /controller

# Copy and download dependencies
COPY go.mod go.sum ./
RUN --mount=type=cache,target=${GOCACHE} \
  --mount=type=cache,target=${GOMODCACHE} \
  go mod download

# Copy the source code, then vet, test, and build
COPY . .
RUN --mount=type=cache,target=${GOCACHE} \
  --mount=type=cache,target=${GOMODCACHE} \
  go vet -v ./... \
  && go test -v ./... \
  && CGO_ENABLED=0 go build -o controller ./cmd/controller

FROM gcr.io/distroless/static-debian12:nonroot

# https://docs.github.com/en/packages/learn-github-packages/connecting-a-repository-to-a-package#connecting-a-repository-to-a-container-image-using-the-command-line
LABEL org.opencontainers.image.source=https://github.com/jlucktay/kubernetes-workbench

COPY --from=build /controller/controller /
CMD ["/controller"]
