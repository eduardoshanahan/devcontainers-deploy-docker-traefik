FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
# Install the locales package
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/*

# Generate the desired locale (e.g., en_IE.UTF-8)
RUN locale-gen en_IE.UTF-8

# Set the default locale
ENV LANG en_IE.UTF-8
ENV LANGUAGE en_IE:en
ENV LC_ALL en_IE.UTF-8

# Install other dependencies, including Ansible (via apt or pip as desired)
RUN apt-get update && \
    apt-get install -y \
    git \
    curl \
    build-essential \
    sudo \
    python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip (optional but recommended)
RUN pip3 install --upgrade pip

# Install a more recent version of Ansible via pip
RUN pip3 install ansible ansible-lint

# Arguments for user and Git configuration
ARG HOST_USERNAME
ARG HOST_UID
ARG HOST_GID
ARG GIT_USER_NAME
ARG GIT_USER_EMAIL

# Create group and user
RUN groupadd --gid $HOST_GID $HOST_USERNAME \
    && useradd --uid $HOST_UID --gid $HOST_GID -m $HOST_USERNAME \
    && echo "$HOST_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER $HOST_USERNAME

# Set the working directory
WORKDIR /workspace

# Configure Git
RUN git config --global user.name "${GIT_USER_NAME}" && \
    git config --global user.email "${GIT_USER_EMAIL}" && \
    git config --global init.defaultBranch main
