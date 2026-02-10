# Boat House Integration

## Overview

The `boat-house` directory contains a microservices-based restaurant management system that has been integrated into this project. This system was sourced from [VitaminC0224/boat-house](https://github.com/VitaminC0224/boat-house).

## What is Boat House?

Boat House (船屋餐饮系统) is a complete restaurant management system built with a microservices architecture. It includes five business service lines:

1. **Statistics Service** - Popular dish statistics with real-time chart visualization
2. **Product Service** - Product and category management
3. **Account Service** - User account management
4. **Order Service** - Order processing and management
5. **Payment Service** - Payment processing

## Architecture

The boat-house system uses:
- **Frontend**: Bootstrap 4, Vue.js, Node.js
- **Backend Services**: Spring Boot (Java), Node.js, .NET Core
- **Databases**: MySQL, PostgreSQL, Redis
- **DevOps**: Jenkins, Docker, Nexus, SonarQube, Jira
- **Testing**: JMeter (API/performance testing), Selenium (UI automation)

## Directory Structure

```
boat-house/
├── client/               # Customer-facing website
├── management/           # Backend management system
├── statistics-service/   # Statistics business service
├── product-service/      # Product business service
├── account-service/      # Account business service
├── order-service/        # Order business service
├── pay-service/          # Payment business service
├── pipelines/            # CI/CD pipeline scripts
├── jmeter/               # Performance testing scripts
├── selenium/             # UI automation tests
├── kompose/              # Kubernetes deployment configs
├── images/               # Documentation images
├── docker-compose.yml    # Docker orchestration
└── README.md             # Original documentation

```

## Quick Start

📖 **For detailed quick start instructions, see [Boat House Quick Start Guide](Boat_House_Quick_Start.md)**

### Running with Docker Compose

The easiest way to run the entire boat-house system is using Docker Compose:

```bash
cd boat-house
docker-compose up -d
```

This will start all services and their dependencies.

Access the applications at:
- Customer Website: http://localhost:5000
- Management Dashboard: http://localhost:5001
- Statistics API: http://localhost:6001
- Product API: http://localhost:7001
- Account API: http://localhost:7002

### Individual Service Development

Each service can be developed and tested independently. Refer to the README in each service directory for specific instructions.

## Integration with MQL5-Google-Onedrive

This boat-house system has been integrated into the MQL5-Google-Onedrive project as a separate module. Both systems can coexist:

- **MQL5 Trading System**: Located in `mt5/`, `scripts/`, `config/` directories
- **Boat House System**: Located in `boat-house/` directory

The two systems are independent and don't interfere with each other. They can be used separately or in combination depending on your needs.

## DevOps Tools

The boat-house project includes comprehensive DevOps tooling:

- **Jenkins**: Continuous Integration server
- **Nexus**: Package and container image management
- **SonarQube**: Code quality analysis
- **Jira**: Project management

## Documentation

For detailed information about the boat-house system, see:
- [boat-house/README.md](../boat-house/README.md) - Main documentation
- [boat-house/github-action.md](../boat-house/github-action.md) - GitHub Actions setup

## License

The boat-house project retains its original license. See [boat-house/LICENSE](../boat-house/LICENSE) for details.

## Source

Original repository: https://github.com/VitaminC0224/boat-house
