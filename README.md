# Local Monitoring Stack

##  🔥 <span style="color:red">Important Note</span> 🔥

The `dx-observability` local stack is developed for, but is not limited to, use with the [PrePass.Observability Library](https://cvo-devops.visualstudio.com/Architecture/_git/PrePass.Observability). 

The package can be found here, [PrePass.Observability Nuget Pacakage](https://cvo-devops.visualstudio.com/Architecture/_artifacts/feed/PrePass.Common/NuGet/PrePass.Observability/overview)


## Overview

This directory contains a complete monitoring and database solution for local development, designed with developer experience (DX) as the top priority. Features include:
- **Grafana**: Visualization and dashboarding (http://localhost:3000)
- **Grafana Mimir**: Metrics backend with OTLP support (http://localhost:9009)
- **Loki**: Log aggregation system (http://localhost:3100)
- **Promtail**: Log collector for Loki
- **Tempo**: Distributed tracing backend (http://localhost:3200)
- **OTEL Collector**: OpenTelemetry data collection and routing
- **MS SQL 2022**: Enterprise-grade SQL Server database (localhost:1433)

## Quick Start

```bash
# 1. Set up environment variables (optional - defaults provided)
# Set the SQL Server password environment variable (choose the command for your OS):

# macOS/Linux (bash/zsh):
export MSSQL_SA_PASSWORD=YourStrong@Passw0rd

# Windows (PowerShell):
$env:MSSQL_SA_PASSWORD="YourStrong@Passw0rd"

# Windows (cmd.exe):
set MSSQL_SA_PASSWORD=YourStrong@Passw0rd

# 2. Start the monitoring stack
docker-compose up -d

# 3. Verify all services are running
docker-compose ps

# 4. Access Services
- Grafana: http://localhost:3000 (Default credentials: admin/admin)
- Mimir: http://localhost:9009
- Tempo: http://localhost:3200
- SQL Server: localhost:1433 (User: sa, Password: $MSSQL_SA_PASSWORD)
```

## Quick Reference

| Service | Port | URL | Purpose |
|---------|------|-----|---------|
| Grafana | 3000 | http://localhost:3000 | Dashboards & Visualization |
| Mimir | 9009 | http://localhost:9009 | Metrics Storage |
| Loki | 3100 | http://localhost:3100 | Log Aggregation |
| Tempo | 3200 | http://localhost:3200 | Distributed Tracing |
| OTEL Collector | 4317/4318 | - | Data Collection |
| SQL Server | 1433 | localhost:1433 | Database |

## Directory Structure

```
observability/
├── docker-compose.yaml          # Container orchestration
├── grafana/
│   ├── dashboards/             # Pre-configured dashboards
│   ├── provisioning/           # Grafana auto-configuration
│   └── grafana.ini             # Grafana settings
├── mimir/
│   └── mimir.yaml              # Mimir configuration
├── loki-config.yaml            # Loki configuration
├── promtail/
│   └── config.yml              # Promtail configuration
├── tempo/
│   └── tempo.yaml              # Tempo configuration
├── otel-collector/
│   └── config.yaml             # OTEL Collector configuration
└── scripts/
    ├── dx-tools.sh             # Bash helper script
    ├── dx-tools.ps1            # PowerShell helper script
    └── init-db.sh              # Database initialization
```

## Networks

The stack uses a single Docker network:
- `monitoring`: For all observability services communication

## Persistent Storage

The following Docker volumes are created for data persistence:
- `grafana-data`: Grafana configurations and data
- `mssql-data`: SQL Server database files
- `mimir-data`: Mimir metrics storage
- `loki-data`: Loki log storage
- `promtail-positions`: Promtail log positions
- `tempo-data`: Tempo trace storage

## Component Details

### Grafana (Port 3000)

- Main visualization platform
- Pre-configured dashboards for application monitoring
- Anonymous access enabled for development
- Configured data sources:
  - Mimir for metrics (via OTLP)
  - Loki for logs
  - Tempo for traces
- **Traces Drilldown Functionality**: Built-in feature enabled for trace-to-logs and trace-to-metrics correlation

### Grafana Mimir (Port 9009)

- High-performance metrics backend
- Drop-in Prometheus replacement
- Supports OpenTelemetry Protocol (OTLP) for metrics ingestion
- Optimized for modern observability stacks
- Local filesystem storage for development
- 7-day retention by default

### Loki (Port 3100)

- Log aggregation system
- Integrated with Grafana for log visualization
- Works with Promtail for log collection
- Configured for local development

### Promtail

- Log collector for Loki
- Automatically collects container logs
- Forwards logs to Loki for storage

### Tempo (Port 3200)

- Distributed tracing backend
- Receives traces in Jaeger, Zipkin, and OTLP formats
- Integrated with Grafana for trace visualization
- Persistent storage for traces

### OTEL Collector

- OpenTelemetry data collection and routing
- Receives OTLP data on ports 4317 (gRPC) and 4318 (HTTP)
- Routes metrics to Mimir, traces to Tempo
- Provides a single endpoint for your applications

### MS SQL 2022 (Port 1433)

- Enterprise-grade SQL Server database
- Full SQL Server 2022 features and compatibility
- Credentials:
  - User: sa
  - Password: YourStrong@Passw0rd (default)
- Configurable via MSSQL_SA_PASSWORD environment variable
- Includes all SQL Server 2022 features for local development

## Traces Drilldown Functionality

The Traces Drilldown functionality is built into Grafana and enables seamless correlation between traces, logs, and metrics. This feature allows you to:

### Features
- **Trace-to-Logs Correlation**: Click on any span in a trace to view related logs from the same time period
- **Trace-to-Metrics Correlation**: View metrics associated with specific traces and spans
- **Cross-Datasource Navigation**: Seamlessly navigate between Tempo (traces), Loki (logs), and Mimir (metrics)
- **Contextual Investigation**: Investigate issues by following the data flow across all observability pillars

### Configuration
The functionality is automatically enabled and configured with:
- **Feature Toggles**: `tracesToLogs` and `tracesToMetrics` enabled in Grafana configuration
- **Datasource Correlation**: Pre-configured correlations between Tempo, Loki, and Mimir
- **Dashboard Integration**: Sample traces dashboard with drilldown capabilities

### Usage
1. Navigate to the "Traces Overview with Drilldown" dashboard
2. Click on any trace or span to open the trace view
3. Use the drilldown buttons to:
   - View related logs in Loki
   - View related metrics in Mimir
   - Navigate to other traces with similar characteristics

### Datasource Correlations
The following correlations are pre-configured:
- **Tempo → Loki**: Maps trace tags to log queries
- **Tempo → Mimir**: Maps trace tags to metric queries
- **Bidirectional Navigation**: Navigate back and forth between all datasources

## Common Tasks

### Viewing Logs

```bash
# View logs from all services
docker-compose logs

# View logs from a specific service
docker-compose logs grafana
docker-compose logs mimir

# Follow logs in real-time
docker-compose logs -f grafana
```

### Restarting Services

```bash
# Restart everything
docker-compose restart

# Restart single service
docker-compose restart grafana

# Stop and start fresh
docker-compose down && docker-compose up -d
```

### Updating Configuration

1. Edit the relevant configuration file
2. Restart the affected service:
```bash
docker-compose restart <service-name>
```

### Health Checks

```bash
# Check all service health
docker-compose ps

# Test individual service endpoints
curl http://localhost:3000/api/health  # Grafana
curl http://localhost:9009/ready       # Mimir
curl http://localhost:3100/ready       # Loki
curl http://localhost:3200/ready       # Tempo
```

## Integration with Your Service

### 1. Metrics (Mimir via OTLP)

Configure your service to send metrics to Mimir using the OpenTelemetry Protocol (OTLP). Add to your service's `Program.cs`:

```csharp
// For .NET applications using OpenTelemetry
dotnet add package OpenTelemetry.Exporter.OpenTelemetryProtocol

services.AddOpenTelemetry()
    .WithMetrics(builder =>
    {
        builder.AddMeter("YourApp.Metrics");
        builder.AddOtlpExporter(o =>
        {
            o.Endpoint = new Uri("http://localhost:4317"); // OTLP gRPC endpoint (default)
        });
    });
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

### 3. Tracing (Tempo)

Configure your service to send traces to Tempo. For .NET and most SDKs, use OTLP/gRPC (4317):

```csharp
services.AddOpenTelemetryTracing(builder =>
{
    builder.AddOtlpExporter(o =>
    {
        o.Endpoint = new Uri("http://localhost:4317"); // OTLP gRPC endpoint (default)
    });
});
```

### 4. Complete OpenTelemetry Setup

For a complete setup with all three signals:

```csharp
services.AddOpenTelemetry()
    .WithMetrics(builder =>
    {
        builder.AddMeter("YourApp.Metrics");
        builder.AddOtlpExporter(o =>
        {
            o.Endpoint = new Uri("http://localhost:4317");
        });
    })
    .WithTracing(builder =>
    {
        builder.AddAspNetCoreInstrumentation();
        builder.AddHttpClientInstrumentation();
        builder.AddOtlpExporter(o =>
        {
            o.Endpoint = new Uri("http://localhost:4317");
        });
    })
    .WithLogging(builder =>
    {
        builder.AddOtlpExporter(o =>
        {
            o.Endpoint = new Uri("http://localhost:4317");
        });
    });
```

## Additional Resources

- [Grafana Documentation](https://grafana.com/docs/)
- [Grafana Mimir Documentation](https://grafana.com/docs/mimir/latest/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Tempo Documentation](https://grafana.com/docs/tempo/latest/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)

## Troubleshooting

### Common Issues and Solutions

#### Services Not Starting

```bash
# Check if ports are already in use
lsof -i :3000  # Grafana
lsof -i :9009  # Mimir
lsof -i :3100  # Loki

# Check Docker resources
docker system df
docker system prune -f  # Clean up unused resources
```

#### Permission Issues

If you encounter permission issues:

```bash
# Fix Grafana permissions
sudo chown -R 472:472 grafana/
chmod -R 755 grafana/
```

#### Network Issues

If services can't communicate:

```bash
# Verify network
docker network inspect observability_monitoring

# Check service connectivity
docker-compose exec grafana wget -q -O- http://mimir:9009/ready
```

#### Health Check Failures

```bash
# Check specific service health
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"

# View detailed health check logs
docker inspect <container-name> | jq '.[0].State.Health'
```

#### Data Persistence Issues

```bash
# Check volume mounts
docker volume ls | grep observability

# Inspect volume contents
docker run --rm -v observability_grafana-data:/data alpine ls -la /data
```

### Service-Specific Troubleshooting

#### Grafana Issues

```bash
# Check Grafana logs
docker-compose logs grafana

# Verify volumes and permissions
docker volume ls
docker volume inspect observability_grafana-data

# Reset Grafana data (if needed)
docker-compose down
docker volume rm observability_grafana-data
docker-compose up -d
```

#### Mimir Issues

```bash
# Check Mimir logs
docker-compose logs mimir

# Verify Mimir is responding
curl http://localhost:9009/ready

# Check Mimir metrics
curl http://localhost:9009/metrics
```

#### Loki Issues

```bash
# Check Loki logs
docker-compose logs loki

# Verify Loki is responding
curl http://localhost:3100/ready

# Test log ingestion
curl -v -H "Content-Type: application/json" -XPOST -s "http://localhost:3100/loki/api/v1/push" --data-raw '{"streams": [{"stream": {"foo": "bar"}, "values": [["'$(date +%s%N)'", "hello world"]]}]}'
```

#### OTEL Collector Issues

```bash
# Check OTEL Collector logs
docker-compose logs otel-collector

# Test OTLP endpoint
curl -X POST http://localhost:4318/v1/metrics \
  -H "Content-Type: application/json" \
  -d '{"resourceMetrics":[]}'
```

## Pre-configured Dashboards

The following dashboards are pre-configured in Grafana for immediate use:

1. **Service Health Status**
   - Real-time health status of all services
   - Color-coded status indicators
   - Service health over time

2. **.NET Application Metrics**
   - HTTP request rates and latencies
   - CPU and memory usage
   - Process-level metrics
   - System resource monitoring

3. **System Overview**
   - Container resource usage
   - Network I/O
   - Disk operations
   - Service health status

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
./scripts/dx-tools.sh restart mimir

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
.\scripts\dx-tools.ps1 restart mimir

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

### Quick Commands Reference

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# View status
docker-compose ps

# View logs
docker-compose logs -f

# Restart specific service
docker-compose restart <service>

# Check health
curl http://localhost:3000/api/health

# Access Grafana
open http://localhost:3000
```

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
- **OTLP Support**: Modern OpenTelemetry Protocol for metrics and traces
- **Hybrid Architecture**: Mimir for metrics, Loki for logs, Tempo for traces
- **Complete Observability**: Metrics, logs, and traces in one stack

# OTLP Endpoints

- OTLP/gRPC: `localhost:4317` (default for most SDKs, including .NET)
- OTLP/HTTP: `localhost:4318` (if explicitly configured for HTTP)