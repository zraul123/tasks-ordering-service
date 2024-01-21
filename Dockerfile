FROM hexpm/elixir:1.16.0-erlang-26.2.1-alpine-3.18.4 as builder

WORKDIR /app

ENV MIX_ENV=prod
RUN mix local.hex --force

# Build the application
COPY mix.exs mix.lock ./
COPY config config
COPY apps apps

RUN mix deps.get
RUN mix release


# Copy release to container
# Raw alpine container seems bugged, let's stick to this for now
FROM hexpm/elixir:1.16.0-erlang-26.2.1-alpine-3.18.4 as release

WORKDIR /app
EXPOSE 80
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

COPY --from=builder /app/_build/$MIX_ENV/rel/tasks_ordering_service .
RUN chown -R nobody: /app
USER nobody

CMD ["bin/tasks_ordering_service", "start"]
