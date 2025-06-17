#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if a service is healthy
check_service_health() {
    local service=$1
    local status=$(docker-compose ps $service | grep "healthy")
    if [[ -z $status ]]; then
        echo -e "${RED}❌ $service is not healthy${NC}"
        return 1
    else
        echo -e "${GREEN}✅ $service is healthy${NC}"
        return 0
    fi
}

# Function to show all service statuses
status() {
    echo "Checking service statuses..."
    echo "------------------------"
    check_service_health prometheus
    check_service_health loki
    check_service_health grafana
    check_service_health jaeger
    check_service_health db
}

# Function to show logs with color coding
logs() {
    local service=$1
    if [[ -z $service ]]; then
        docker-compose logs --tail=100 --follow
    else
        docker-compose logs --tail=100 --follow $service
    fi
}

# Function to restart a service
restart() {
    local service=$1
    if [[ -z $service ]]; then
        echo "Restarting all services..."
        docker-compose restart
    else
        echo "Restarting $service..."
        docker-compose restart $service
    fi
}

# Function to show resource usage
resources() {
    echo "Resource usage for all services:"
    docker stats --no-stream
}

# Function to show help
show_help() {
    echo "DX Tools - Developer Experience Helper Script"
    echo "Usage: ./dx-tools.sh [command] [service]"
    echo ""
    echo "Commands:"
    echo "  status              Show health status of all services"
    echo "  logs [service]      Show logs for all services or specific service"
    echo "  restart [service]   Restart all services or specific service"
    echo "  resources           Show resource usage for all services"
    echo "  help                Show this help message"
}

# Main command handling
case "$1" in
    "status")
        status
        ;;
    "logs")
        logs $2
        ;;
    "restart")
        restart $2
        ;;
    "resources")
        resources
        ;;
    "help"|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac 