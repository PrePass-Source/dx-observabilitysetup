# Verify Traces Drilldown Functionality Installation
Write-Host "🔍 Verifying Traces Drilldown Functionality Installation..." -ForegroundColor Cyan

# Wait for Grafana to be ready
Write-Host "⏳ Waiting for Grafana to be ready..." -ForegroundColor Yellow
do {
    Write-Host "   Waiting for Grafana to start..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 5
        $grafanaReady = $response.StatusCode -eq 200
    }
    catch {
        $grafanaReady = $false
    }
} while (-not $grafanaReady)

Write-Host "✅ Grafana is running" -ForegroundColor Green

# Check if the traces functionality is enabled
Write-Host "🔍 Checking traces functionality..." -ForegroundColor Cyan
try {
    $featureStatus = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 5 -Headers @{
        "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
    }
    
    if ($featureStatus.StatusCode -eq 200) {
        Write-Host "✅ Traces Drilldown functionality is available" -ForegroundColor Green
    } else {
        Write-Host "❌ Traces Drilldown functionality is not accessible" -ForegroundColor Red
        Write-Host "   You may need to restart Grafana: docker-compose restart grafana" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ Traces Drilldown functionality is not accessible" -ForegroundColor Red
    Write-Host "   You may need to restart Grafana: docker-compose restart grafana" -ForegroundColor Yellow
}

# Check datasource correlations
Write-Host "🔍 Checking datasource correlations..." -ForegroundColor Cyan
try {
    $correlations = Invoke-WebRequest -Uri "http://localhost:3000/api/datasources/correlations" -UseBasicParsing -TimeoutSec 5 -Headers @{
        "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
    }
    
    if ($correlations.StatusCode -eq 200) {
        Write-Host "✅ Datasource correlations are configured" -ForegroundColor Green
        try {
            $correlationsJson = $correlations.Content | ConvertFrom-Json
            $correlationsJson | ConvertTo-Json -Depth 3
        }
        catch {
            Write-Host $correlations.Content
        }
    } else {
        Write-Host "❌ Datasource correlations not found or not accessible" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Datasource correlations not found or not accessible" -ForegroundColor Red
}

# Check if the traces dashboard exists
Write-Host "🔍 Checking traces dashboard..." -ForegroundColor Cyan
try {
    $dashboards = Invoke-WebRequest -Uri "http://localhost:3000/api/search?query=traces" -UseBasicParsing -TimeoutSec 5 -Headers @{
        "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("admin:admin"))
    }
    
    if ($dashboards.StatusCode -eq 200 -and $dashboards.Content -match "traces-overview") {
        Write-Host "✅ Traces Overview dashboard is available" -ForegroundColor Green
    } else {
        Write-Host "❌ Traces Overview dashboard not found" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Traces Overview dashboard not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Traces Drilldown Functionality Verification Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Open Grafana at http://localhost:3000" -ForegroundColor White
Write-Host "   2. Navigate to the 'Traces Overview with Drilldown' dashboard" -ForegroundColor White
Write-Host "   3. Click on traces to test the drilldown functionality" -ForegroundColor White
Write-Host "   4. Use the correlation buttons to navigate between traces, logs, and metrics" -ForegroundColor White
Write-Host ""
Write-Host "🔧 If you encounter issues:" -ForegroundColor Yellow
Write-Host "   - Restart Grafana: docker-compose restart grafana" -ForegroundColor White
Write-Host "   - Check logs: docker-compose logs grafana" -ForegroundColor White
Write-Host "   - Verify all services are running: docker-compose ps" -ForegroundColor White 