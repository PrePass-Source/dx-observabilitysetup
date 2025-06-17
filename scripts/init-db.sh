#!/bin/bash

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to be ready..."
sleep 30s

# Run SQL Server health check
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD:-YourStrong@Passw0rd}" -Q "SELECT 1" || exit 1

# Set proper permissions
chown -R mssql:mssql /var/opt/mssql
chmod -R 755 /var/opt/mssql

# Optional: Create a database for your application
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD:-YourStrong@Passw0rd}" -Q "
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'YourAppDB')
BEGIN
    CREATE DATABASE YourAppDB;
END
GO"

echo "SQL Server initialization completed"