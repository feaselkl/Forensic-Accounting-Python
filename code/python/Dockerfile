FROM python:3.12-slim

# Install system dependencies for pyodbc and graphviz
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    unixodbc-dev \
    graphviz \
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /app

# Copy project files and install dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# Copy notebooks and assets
COPY *.ipynb ./
COPY Images/ ./Images/
COPY *.svg ./

EXPOSE 8888

# Generate config.toml from environment variables at startup, then launch Jupyter
CMD printf '[database]\nserver = "%s"\nname = "%s"\nusername = "%s"\npassword = "%s"\n' \
    "$DB_SERVER" "$DB_NAME" "$DB_USERNAME" "$DB_PASSWORD" > ../config.toml \
    && uv run jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''
