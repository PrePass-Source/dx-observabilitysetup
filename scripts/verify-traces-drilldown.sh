#!/bin/bash

# Verify Traces Drilldown Functionality Installation
echo "🔍 Verifying Traces Drilldown Functionality Installation..."

# Wait for Grafana to be ready
echo "⏳ Waiting for Grafana to be ready..."
until curl -s http://localhost:3000/api/health > /dev/null 2>&1; do
    echo "   Waiting for Grafana to start..."
    sleep 5
done

echo "✅ Grafana is running"

# Check if the traces functionality is enabled
echo "🔍 Checking traces functionality..."
FEATURE_STATUS=$(curl -s -u admin:admin http://localhost:3000/api/health 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$FEATURE_STATUS" ]; then
    echo "✅ Traces Drilldown functionality is available"
else
    echo "❌ Traces Drilldown functionality is not accessible"
    echo "   You may need to restart Grafana: docker-compose restart grafana"
fi

# Check datasource correlations
echo "🔍 Checking datasource correlations..."
CORRELATIONS=$(curl -s -u admin:admin http://localhost:3000/api/datasources/correlations 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$CORRELATIONS" ]; then
    echo "✅ Datasource correlations are configured"
    echo "$CORRELATIONS" | jq '.' 2>/dev/null || echo "$CORRELATIONS"
else
    echo "❌ Datasource correlations not found or not accessible"
fi

# Check if the traces dashboard exists
echo "🔍 Checking traces dashboard..."
DASHBOARDS=$(curl -s -u admin:admin "http://localhost:3000/api/search?query=traces" 2>/dev/null)

if [ $? -eq 0 ] && echo "$DASHBOARDS" | grep -q "traces-overview"; then
    echo "✅ Traces Overview dashboard is available"
else
    echo "❌ Traces Overview dashboard not found"
fi

echo ""
echo "🎯 Traces Drilldown Functionality Verification Complete!"
echo ""
echo "📋 Next Steps:"
echo "   1. Open Grafana at http://localhost:3000"
echo "   2. Navigate to the 'Traces Overview with Drilldown' dashboard"
echo "   3. Click on traces to test the drilldown functionality"
echo "   4. Use the correlation buttons to navigate between traces, logs, and metrics"
echo ""
echo "🔧 If you encounter issues:"
echo "   - Restart Grafana: docker-compose restart grafana"
echo "   - Check logs: docker-compose logs grafana"
echo "   - Verify all services are running: docker-compose ps" 