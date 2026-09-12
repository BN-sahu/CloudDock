# -------------------------------
# Stage 1: Build dependencies
# -------------------------------
FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt


# -------------------------------
# Stage 2: Minimal runtime image
# -------------------------------
FROM python:3.11-slim

WORKDIR /app

# Update installed OS packages
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd --create-home --shell /usr/sbin/nologin appuser

# Copy only the virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application
COPY app/ .

# Make virtual environment the default Python environment
ENV PATH="/opt/venv/bin:$PATH"

# Run as non-root user
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
