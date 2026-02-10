# Boat House Quick Start Guide

## Overview

This guide provides quick instructions for getting started with the Boat House restaurant management system that has been integrated into this repository.

## Prerequisites

- Docker and Docker Compose installed
- At least 4GB of available RAM
- Ports 3306, 5000, 5001, 6001, 6379, 7001, 7002 available

## Quick Start

### 1. Navigate to the boat-house directory

```bash
cd boat-house
```

### 2. Start all services with Docker Compose

```bash
docker-compose up -d
```

This command will:
- Build all service containers
- Start databases (MySQL, PostgreSQL, Redis)
- Launch all microservices
- Set up the required networks

### 3. Verify services are running

```bash
docker-compose ps
```

You should see all services in "Up" status.

### 4. Access the applications

Once all services are running, you can access:

- **Customer Website**: http://localhost:5000
- **Management Dashboard**: http://localhost:5001
- **Statistics API**: http://localhost:6001
- **Product API**: http://localhost:7001
- **Account API**: http://localhost:7002

## Service Architecture

```
┌─────────────────┐     ┌──────────────────┐
│  Client (5000)  │     │ Management (5001)│
└────────┬────────┘     └────────┬─────────┘
         │                       │
    ┌────┴───────────────────────┴────┐
    │         API Services             │
    ├──────────────────────────────────┤
    │ Statistics (6001) + Redis (6379) │
    │ Product (7001) + MySQL (3306)    │
    │ Account (7002)                   │
    └──────────────────────────────────┘
```

## Common Commands

### View logs for all services
```bash
cd boat-house
docker-compose logs -f
```

### View logs for a specific service
```bash
cd boat-house
docker-compose logs -f client
```

### Stop all services
```bash
cd boat-house
docker-compose down
```

### Stop and remove volumes (clean reset)
```bash
cd boat-house
docker-compose down -v
```

### Rebuild services after code changes
```bash
cd boat-house
docker-compose up -d --build
```

## Troubleshooting

### Port conflicts
If you get port conflict errors, you can either:
1. Stop the conflicting service on your machine
2. Edit `docker-compose.yml` to use different ports

### Database initialization issues
If services fail to connect to databases:
1. Check database logs: `docker-compose logs statistics-service-db product-service-db`
2. Ensure databases are fully initialized before services start
3. Restart services: `docker-compose restart`

### Out of memory errors
If containers crash due to memory:
1. Check available resources: `docker stats`
2. Stop unnecessary services
3. Increase Docker's memory allocation in Docker Desktop settings

## Development Workflow

### Working on a specific service

1. Make changes to the service code
2. Rebuild only that service:
   ```bash
   docker-compose up -d --build service-name
   ```
3. View logs to verify:
   ```bash
   docker-compose logs -f service-name
   ```

### Running tests

Each service has its own test suite. Refer to the service's README for specific test commands.

## Next Steps

- Read the [full integration documentation](Boat_House_Integration.md)
- Explore individual service READMEs in their directories
- Check the original [boat-house README](../boat-house/README.md)

## Support

For issues specific to:
- **Boat House system**: Refer to the [original repository](https://github.com/VitaminC0224/boat-house)
- **Integration**: Open an issue in this repository
