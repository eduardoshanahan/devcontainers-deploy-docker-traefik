# Traefik installation with a Docker container, running on a VPS

## Why do I need this project

I want to be able to work in Visual Studio Code or Cursor using devcontainers to develop and deploy a Docker container running Traefik. The objective is to deploy other web applications later, and to have Traefik acting as a reverse proxy.

The deployment is done by way of Ansible scripts. The prerequisite is that the VPS server where this will be deployed is already running Docker, ideally from a setup done using [Docker Installation in a remote Ubuntu VPS with Ansible & Devcontainers](https://github.com/eduardoshanahan/devcontainers-deploy-docker).

The original set of files were created as a clone of [Development Container Template - Just Ansible](https://github.com/eduardoshanahan/devcontainers-ansible).
