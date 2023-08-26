FROM rust:1.71.1-alpine3.17 as base
RUN apk update
RUN apk upgrade
RUN apk upgrade musl
RUN apk add perl
RUN apk add alpine-sdk
RUN apk add libressl-dev
RUN apk add cmake
RUN apk add --upgrade unixodbc
RUN apk add --upgrade unixodbc-dev
RUN cargo install cargo-chef
RUN mkdir /root/.cargo
COPY config.toml /root/.cargo
ENV CARGO_HOME /root/.cargo
ENV OPENSSL_DIR=/usr
ENV OPENSSL_STATIC=1

# Build
FROM base as planner
WORKDIR /source
RUN mkdir app

RUN apk update
RUN apk add unixodbc-dev
# For docker to cache rust deps
WORKDIR /source/app
COPY . .
RUN cargo chef prepare --recipe-path recipe.json


FROM base AS builder 
RUN apk add unixodbc-dev
COPY --from=planner /source/app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
# Build application
WORKDIR /source/app
RUN cargo b --release --target-dir=/rust
RUN mv /rust/release/chef-builds ./

# Prod

FROM alpine:3.15
WORKDIR /app
RUN apk update

RUN addgroup -S myapp && adduser -S myapp -G myapp
USER myapp
COPY --from=builder /source/app/chef-builds ./

ENV RUST_LOG=info
ENV RUST_LOG_STYLE=always
CMD ["./chef-builds"]
