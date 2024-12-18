FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1
# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

RUN --mount=type=cache,target=/root/.cache/uv \
  --mount=type=bind,source=uv.lock,target=uv.lock \
  --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
  uv sync --frozen --no-install-project --no-dev

ADD . /app

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --frozen --no-dev

FROM python:3.12-slim AS runner

ARG VERSION
ARG BUILD_TIME

ENV PYTHON_ENV=production

ENV PATH="/app/.venv/bin:$PATH"

COPY --from=builder /app /app

WORKDIR /app

EXPOSE 8000

CMD ["fastapi", "run", "server/main.py", "--host", "0.0.0.0", "--port", "8000"]