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

# shadow-utils contains adduser and groupadd binaries
RUN microdnf install shadow-utils \
	&& groupadd --gid 1000 noroot \
	&& adduser \
		--no-create-home \
		--no-user-group \
		--uid 1000 \
		--gid 1000 \
		noroot

WORKDIR /

COPY --from=builder /build/bin/clusters-checker /usr/local/bin/

USER "noroot"

ENTRYPOINT ["/usr/local/bin/clusters-checker", "scan"]