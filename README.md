# Local Monitoring Stack

## Overview

This directory contains a complete monitoring and database solution for local development, designed with developer experience (DX) as the top priority. Features include:
- **Grafana**: Visualization and dashboarding (http://localhost:3000)
- **Prometheus**: Metrics collection and storage (http://localhost:9090)
- **Loki**: Log aggregation system (http://localhost:3100)
- **Promtail**: Log collector for Loki
- **Jaeger**: Distributed tracing (http://localhost:16686)
- **MS SQL 2022**: Enterprise-grade SQL Server database (localhost:1433)

## Quick Start

```bash
# 1. Set up environment variables (optional - defaults provided)
export MSSQL_SA_PASSWORD=YourStrong@Passw0rd  # Default SQL password if not set

# 2. Start the monitoring stack
docker-compose up -d

# 3. Verify all services are running
docker-compose ps

# 4. Access Services
- Grafana: http://localhost:3000 (Default credentials: admin/admin)
- Prometheus: http://localhost:9090
- Jaeger UI: http://localhost:16686
- SQL Server: localhost:1433 (User: sa, Password: $MSSQL_SA_PASSWORD)
```

## Directory Structure

```
observability/
├── docker-compose.yaml          # Container orchestration
├── grafana/
│   ├── dashboards/             # Pre-configured dashboards
│   │   └── dotnet-dashboard.json
│   ├── provisioning/           # Grafana auto-configuration
│   │   ├── dashboards/
│   │   │   └── default.yml
│   │   └── datasources/
│   │       └── ds.yaml
│   └── grafana.ini            # Grafana settings
├── prometheus/
│   └── prometheus.yaml        # Prometheus configuration
└── loki/
    └── loki-config.yaml      # Loki configuration
```

## Networks

The stack uses two Docker networks:
- `monitoring`: For observability services communication
- `database`: For database-related services

## Persistent Storage

The following Docker volumes are created for data persistence:
- `prometheus-data`: Prometheus time series data
- `grafana-data`: Grafana configurations and data
- `azure-sql-edge-data`: SQL Server database files

## Component Details

### Grafana (Port 3000)

- Main visualization platform
- Pre-configured dashboards for .NET metrics
- Anonymous access enabled for development
- Configured data sources:
  - Prometheus for metrics
  - Loki for logs
  - Jaeger for traces

### Prometheus (Port 9090)

- Metrics collection and storage
- Scrapes metrics every 15 seconds
- Configured to discover your service at `host.docker.internal:8080`
- Retention: 7 days, max 5GB (configurable in docker-compose.yaml)

### Loki (Port 3100)

- Log aggregation system
- Integrated with Grafana for log visualization
- Works with Promtail for log collection
- Configured for local development

### Promtail

- Log collector for Loki
- Automatically collects container logs
- Forwards logs to Loki for storage

### Jaeger (Multiple Ports)

- Distributed tracing system
- UI available at http://localhost:16686
- Collects traces via:
  - HTTP (14268)
  - gRPC (14250)
  - UDP (6831, 6832)

### MS SQL 2022 (Port 1433)

- Enterprise-grade SQL Server database
- Full SQL Server 2022 features and compatibility
- Credentials:
  - User: sa
  - Password: YourStrong@Passw0rd (default)
- Configurable via MSSQL_SA_PASSWORD environment variable
- Includes all SQL Server 2022 features for local development

## Common Tasks

### Viewing Logs

```bash
# View logs from all services
docker-compose logs

# View logs from a specific service
docker-compose logs grafana
docker-compose logs prometheus
```

### Restarting Services

```bash
# Restart everything
docker-compose restart

# Restart single service
docker-compose restart grafana
```

### Updating Configuration

1. Edit the relevant configuration file
2. Restart the affected service:
```bash
docker-compose restart <service-name>
```

### Troubleshooting

#### Grafana Issues

```bash
# Check Grafana logs
docker-compose logs grafana

# Verify volumes and permissions
docker volume ls
docker volume inspect observability_grafana-data
```

#### Prometheus Issues

```bash
# Check if Prometheus can reach your service
curl http://localhost:9090/targets

# View Prometheus logs
docker-compose logs prometheus
```

#### Container Issues

```bash
# Check container status
docker ps --format "table {% raw %}{{.Names}}{% endraw %}\t{% raw %}{{.Status}}{% endraw %}\t{% raw %}{{.Health}}{% endraw %}"

# Alternative: Use docker compose
docker compose ps

# For detailed health checks
docker compose ps --format json | jq
```

## Integration with Your Service

### 1. Metrics (Prometheus)

Add to your service's `Program.cs`:
```csharp
app.UseMetricServer();  // Exposes /metrics endpoint
```

### 2. Logging (Loki)

Configure in `appsettings.json`:

```json
{
  "Serilog": {
    "WriteTo": [
      {
        "Name": "GrafanaLoki",
        "Args": {
          "uri": "http://localhost:3100"
        }
      }
    ]
  }
}
```

### 3. Tracing (Jaeger)

Configure in your service:

```csharp
services.AddOpenTelemetryTracing(builder =>
{
    builder.AddJaegerExporter(o =>
    {
        o.AgentHost = "localhost";
        o.AgentPort = 6831;
    });
});
```

## Additional Resources

- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/1.41/)

## Common Issues and Solutions

### Permission Issues

If you encounter permission issues:

```bash
# Fix Grafana permissions
sudo chown -R 472:472 grafana/
chmod -R 755 grafana/
```

### Network Issues

If services can't communicate:

```bash
# Verify network
docker network inspect observability_monitoring

# Check container connectivity
docker-compose exec grafana ping prometheus
```

### Storage Issues

If data isn't persisting:

```bash
# Check volume status
docker volume ls
docker volume inspect observability_grafana-data
```

## Pre-configured Dashboards

The following dashboards are pre-configured in Grafana for immediate use:

1. **.NET Application Metrics**
   - CPU and memory usage
   - Request rates and latencies
   - Exception tracking
   - Garbage collection metrics

2. **System Overview**
   - Container resource usage
   - Network I/O
   - Disk operations
   - Service health status

3. **Database Performance**
   - Query performance metrics
   - Connection statistics
   - Buffer cache hit ratios
   - Transaction rates

4. **Log Analysis**
   - Application logs
   - Error tracking
   - Log patterns
   - Correlation with metrics

To access these dashboards:
1. Open Grafana (http://localhost:3000)
2. Navigate to Dashboards
3. Browse the pre-configured dashboards

## Developer Experience (DX) Tools

We've added several tools to make working with the monitoring stack easier:

### DX Helper Scripts

We provide two versions of our DX helper script for maximum flexibility:

#### Bash Version (Unix/Linux/macOS)
```bash
# Make the script executable
chmod +x scripts/dx-tools.sh

# Check health status of all services
./scripts/dx-tools.sh status

# View logs (all services or specific service)
./scripts/dx-tools.sh logs
./scripts/dx-tools.sh logs grafana

# Restart services
./scripts/dx-tools.sh restart
./scripts/dx-tools.sh restart prometheus

# Monitor resource usage
./scripts/dx-tools.sh resources

# Show help
./scripts/dx-tools.sh help
```

#### PowerShell Version (Windows)
```powershell
# Check health status of all services
.\scripts\dx-tools.ps1 status

# View logs (all services or specific service)
.\scripts\dx-tools.ps1 logs
.\scripts\dx-tools.ps1 logs grafana

# Restart services
.\scripts\dx-tools.ps1 restart
.\scripts\dx-tools.ps1 restart prometheus

# Monitor resource usage
.\scripts\dx-tools.ps1 resources

# Show help
.\scripts\dx-tools.ps1 help
```

Both scripts provide the same functionality:
- Service health status checking
- Log viewing with color coding
- Service restart capabilities
- Resource usage monitoring
- Built-in help system

### Health Status Dashboard

A new health status dashboard is available in Grafana that provides:
- Real-time health status of all services
- Color-coded status indicators
- Quick access to service metrics
- Automatic refresh every 5 seconds

Access it at: http://localhost:3000/d/health-status/health-status

## Developer Experience (DX) Focus

This monitoring stack is designed with developer experience as the primary focus:

- **Zero Configuration**: Pre-configured dashboards and data sources
- **Quick Start**: Single command to start all services
- **Local Development**: All services run locally with minimal setup
- **Persistent Data**: Data persists between restarts
- **Easy Integration**: Simple configuration for your applications
- **Comprehensive Monitoring**: Full observability stack in one place
- **Modern Stack**: Latest versions of all components
- **Resource Efficient**: Optimized for local development
- **Health Monitoring**: Real-time health status dashboard
- **DX Tools**: Convenient command-line tools for common operations
- **Color-Coded Output**: Easy-to-read status indicators
- **Quick Troubleshooting**: Built-in tools for service management