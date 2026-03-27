FROM mcr.microsoft.com/mssql/server:2025-latest

USER root

# Copy SQL scripts and calendar data into the container
COPY ForensicAccounting/ /var/opt/mssql/scripts/

# Copy the entrypoint script
COPY docker-entrypoint.sh /var/opt/mssql/docker-entrypoint.sh
RUN chmod +x /var/opt/mssql/docker-entrypoint.sh

USER mssql

ENTRYPOINT ["/var/opt/mssql/docker-entrypoint.sh"]
