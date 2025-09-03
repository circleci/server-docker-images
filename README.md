# CircleCI Server Docker Images

## Overview

This repository hosts Docker image files and corresponding Helm charts for internalized CircleCI server services, including MongoDB, PostgreSQL, RabbitMQ, and Redis. These charts and images are primarily forks/copies of corresponding Bitnami charts, which have been maintained for legacy reasons.

The migration was necessary as Bitnami began the process of archiving these charts on August 28th, 2025. Additionally, maintaining our own versions allows us to proactively patch them for CVEs and install additional dependencies such as plugins.

## File Structure

The repository is organized as follows:

* `./helm/<service>` - Contains the Helm charts for the various services
* `./<service>` - Dockerfiles for the various services
* `./do` - Script to run various common commands for development (run `./do help` for available commands)

## Release Process

While images are automatically tagged and pushed to Docker Hub, the Helm charts are published to PackageCloud and require manual approval during release with an approval gate job. There is a CI job to ensure that the version is bumped accordingly in the Chart first before release.

The `main` branch corresponds to the latest release candidate, while there are server branches of the form `server-x.y` corresponding to the two most recent supported server versions.
