#!/bin/bash
set -e

# Start SQL Server in the background
/opt/mssql/bin/sqlservr &
MSSQL_PID=$!

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to start..."
for i in {1..60}; do
    if /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" &>/dev/null; then
        echo "SQL Server is ready."
        break
    fi
    sleep 1
done

# Run each SQL script in order
SCRIPTS_DIR="/var/opt/mssql/scripts"
echo "Initializing ForensicAccounting database..."

for script in \
    "00 - Calendar.sql" \
    "01 - Employee.sql" \
    "02 - Bus.sql" \
    "03 - ExpenseCategory.sql" \
    "04 - Vendor.sql" \
    "05 - VendorExpenseCategory.sql" \
    "06 - LineItem.sql" \
    "07 - Populate LineItem.sql"; do
    echo "Running $script..."
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i "$SCRIPTS_DIR/$script"
done

echo "Database initialization complete."

# Keep SQL Server running in the foreground
wait $MSSQL_PID
