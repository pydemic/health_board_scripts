FROM elixir:1.10.4

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
      git \
      && \
    apt-get clean && \
    mix local.hex --force && \
    mix local.rebar --force

CMD ["sleep", "infinity"]
