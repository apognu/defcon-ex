#
# Build
#

FROM elixir:1.9-alpine as build
LABEL maintainer "Antoine POPINEAU <antoine.popineau@appscho.com>"

ENV MIX_ENV=prod

WORKDIR /opt/defcon

RUN \
  apk add -U build-base nodejs yarn git && \
  mix local.rebar --force && \
  mix local.hex --force

COPY mix.exs mix.lock deps/ ./

RUN mix deps.get

COPY assets assets

RUN \
  cd assets && \
  yarn install && yarn deploy && \
  cd .. && \
  mix phx.digest

COPY . .

RUN \
  mix release --overwrite default && \
  mv _build/prod/rel/default /opt/release && \
  ln -s /opt/release/bin/default /opt/release/bin/run

#
# Run
#

FROM alpine:3.9.4
LABEL maintainer "Antoine POPINEAU <antoine.popineau@appscho.com>"

ENV MIX_ENV=prod

RUN apk add -U openssl-dev ncurses-libs

COPY --from=build /opt/release /opt/release

CMD ["/opt/release/bin/run", "start"]
