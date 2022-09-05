FROM elixir:1.13-slim

WORKDIR /app

EXPOSE 8080

COPY . /app

RUN mix local.hex --force \
    && mix local.rebar --force

RUN MIX_ENV=prod mix do deps.get, compile, release

ENTRYPOINT ["/app/_build/prod/rel/job_processor/bin/job_processor"]
CMD ["start"]