FROM golang:1.24 AS build

ARG GOCACHE=/root/.cache/go-build
ARG GOMODCACHE=/root/.cache/go-mod

ENV GOCACHE=${GOCACHE}
ENV GOMODCACHE=${GOMODCACHE}

WORKDIR /controller

# Copy and download dependencies
COPY go.mod .
COPY go.sum .
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

COPY --from=build /controller/controller /
CMD ["/controller"]
