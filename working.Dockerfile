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
WORKDIR /source/app
COPY . .
RUN cargo b --release --target-dir=/rust
RUN mv /rust/release/chef-builds ./

# Prod

FROM alpine:3.15
WORKDIR /app
RUN apk update

RUN addgroup -S myapp && adduser -S myapp -G myapp
USER myapp
COPY --from=base /source/app/chef-builds ./

ENV RUST_LOG=info
ENV RUST_LOG_STYLE=always
CMD ["./chef-builds"]
