# vi:set ft=dockerfile:
# --- stage 1 ---
FROM registry.redhat.io/rhel8/go-toolset:1.17 as builder

USER root

WORKDIR /build

# Cache optimization
COPY go.mod go.sum Makefile ./
RUN go mod download

COPY . ./
RUN make build

# --- stage 2 ---
FROM registry.access.redhat.com/ubi8/ubi-minimal@sha256:574f201d7ed185a9932c91cef5d397f5298dff9df08bc2ebb266c6d1e6284cd1

USER root
RUN mkdir -p /ocm/.config/ocm/
RUN chown noroot /ocm

USER noroot
COPY --from=builder /build/bin/clusters-checker /ocm/clusters-checker

ENTRYPOINT ["/ocm/clusters-checker"]