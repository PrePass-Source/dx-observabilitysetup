# DX Tools - Developer Experience Helper Script for PowerShell
# Usage: .\dx-tools.ps1 [command] [service]

# Function to check if a service is healthy
function Check-ServiceHealth {
    param (
        [string]$Service
    )
    
    $status = docker-compose ps $Service | Select-String "healthy"
    if (-not $status) {
        Write-Host "❌ $Service is not healthy" -ForegroundColor Red
        return $false
    } else {
        Write-Host "✅ $Service is healthy" -ForegroundColor Green
        return $true
    }
}

# Function to show all service statuses
function Show-Status {
    Write-Host "Checking service statuses..."
    Write-Host "------------------------"
    Check-ServiceHealth "loki"
    Check-ServiceHealth "mimir"
    Check-ServiceHealth "otel-collector"
    Check-ServiceHealth "grafana"
    Check-ServiceHealth "tempo"
    Check-ServiceHealth "db"
}

# Function to show logs with color coding
function Show-Logs {
    param (
        [string]$Service
    )
    
    if ([string]::IsNullOrEmpty($Service)) {
        docker-compose logs --tail=100 --follow
    } else {
        docker-compose logs --tail=100 --follow $Service
    }
}

# Function to restart a service
function Restart-Service {
    param (
        [string]$Service
    )
    
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "Restarting all services..."
        docker-compose restart
    } else {
        Write-Host "Restarting $Service..."
        docker-compose restart $Service
    }
}

# Function to show resource usage
function Show-Resources {
    Write-Host "Resource usage for all services:"
    docker stats --no-stream
}

# Function to verify traces drilldown functionality
function Verify-TracesDrilldown {
    Write-Host "Verifying Traces Drilldown Functionality..."
    & .\scripts\verify-traces-drilldown.ps1
}

# Function to show help
function Show-Help {
    Write-Host "DX Tools - Developer Experience Helper Script for PowerShell"
    Write-Host "Usage: .\dx-tools.ps1 [command] [service]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  status              Show health status of all services"
    Write-Host "  logs [service]      Show logs for all services or specific service"
    Write-Host "  restart [service]   Restart all services or specific service"
    Write-Host "  resources           Show resource usage for all services"
    Write-Host "  verify-traces       Verify Traces Drilldown functionality"
    Write-Host "  help                Show this help message"
    Write-Host ""
    Write-Host "Available services: loki, mimir, otel-collector, grafana, tempo, db"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\dx-tools.ps1 status"
    Write-Host "  .\dx-tools.ps1 logs grafana"
    Write-Host "  .\dx-tools.ps1 restart loki"
    Write-Host "  .\dx-tools.ps1 resources"
}

# Main command handling
$command = $args[0]
$service = $args[1]

switch ($command) {
    "status" {
        Show-Status
    }
    "logs" {
        Show-Logs $service
    }
    "restart" {
        Restart-Service $service
    }
    "resources" {
        Show-Resources
    }
    "verify-traces" {
        Verify-TracesDrilldown
    }
    "help" {
        Show-Help
    }
    default {
        if ([string]::IsNullOrEmpty($command)) {
            Show-Help
        } else {
            Write-Host "Unknown command: $command" -ForegroundColor Red
            Show-Help
            exit 1
        }
    }
} 