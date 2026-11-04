# -------------------------------
# Stage 1: Build dependencies
# -------------------------------
FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .

RUN python -m venv /opt/venv \
    && /opt/venv/bin/python -m pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/python -m pip install --no-cache-dir --upgrade \
       "setuptools>=84.1.0" \
       "wheel>=0.46.2" \
    && /opt/venv/bin/python -m pip install --no-cache-dir -r requirements.txt


# -------------------------------
# Stage 2: Minimal runtime image
# -------------------------------
FROM python:3.11-slim

WORKDIR /app

# Update OS packages and Python packaging tools
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir --upgrade \
       "setuptools>=84.1.0" \
       "wheel>=0.46.2"

# Create a non-root user
RUN useradd --create-home --shell /usr/sbin/nologin appuser

# Copy updated virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Remove pip's bundled SBOM containing outdated package metadata
RUN rm -f /opt/venv/lib/python3.11/site-packages/pip/_vendor/bom.cdx.json

# Copy application
COPY app/ .

# Make virtual environment the default Python environment
ENV PATH="/opt/venv/bin:$PATH"

# Run as non-root user
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
