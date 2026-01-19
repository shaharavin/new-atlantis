# New Atlantis - Containerized Intellectual Community
# Provides full isolation for agent-driven scholarly work

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create atlantis user (non-root for security)
RUN useradd -m -s /bin/bash atlantis

# Set up working directories
RUN mkdir -p /atlantis /new-atlantis-repo
RUN chown -R atlantis:atlantis /atlantis /new-atlantis-repo

# Switch to atlantis user
USER atlantis
WORKDIR /home/atlantis

# Install Claude Code globally for the atlantis user
RUN npm install -g @anthropic-ai/claude-code

# Set up git config for the container
RUN git config --global user.name "New Atlantis Scholar" && \
    git config --global user.email "scholars@new-atlantis.local"

# Set environment variables
ENV HOME=/home/atlantis
ENV ATLANTIS_WORKSPACE=/atlantis
ENV NEW_ATLANTIS_REPO=/new-atlantis-repo

# Default working directory
WORKDIR /atlantis

# Entry point - bash shell by default
CMD ["/bin/bash"]
