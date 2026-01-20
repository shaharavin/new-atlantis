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

# Install Claude Code globally (as root before switching users)
RUN npm install -g @anthropic-ai/claude-code

# Install Beads (bd CLI) for issue tracking
RUN curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

# Create atlantis user (non-root for security)
RUN useradd -m -s /bin/bash atlantis

# Set up working directories
RUN mkdir -p /atlantis /new-atlantis-repo
RUN chown -R atlantis:atlantis /atlantis /new-atlantis-repo

# Switch to atlantis user
USER atlantis
WORKDIR /home/atlantis

# Set up git config for the container
RUN git config --global user.name "New Atlantis Scholar" && \
    git config --global user.email "scholars@new-atlantis.local"

# Create Claude Code config directory
RUN mkdir -p /home/atlantis/.config/claude

# Set environment variables
ENV HOME=/home/atlantis
ENV ATLANTIS_WORKSPACE=/atlantis
ENV NEW_ATLANTIS_REPO=/new-atlantis-repo

# Default working directory
WORKDIR /atlantis

# Create entrypoint script to configure Claude Code with API key
COPY --chown=atlantis:atlantis <<'EOF' /home/atlantis/entrypoint.sh
#!/bin/bash
# Configure Claude Code to use API key if available
if [ -n "$ANTHROPIC_API_KEY" ]; then
    mkdir -p /home/atlantis/.config/claude
    cat > /home/atlantis/.config/claude/config.json <<CONFIG
{
  "apiKey": "$ANTHROPIC_API_KEY",
  "allowedPrompts": [
    {"tool": "Bash", "prompt": "run commands in /atlantis"},
    {"tool": "Bash", "prompt": "use git commands"},
    {"tool": "Bash", "prompt": "use bd commands"},
    {"tool": "Bash", "prompt": "read files"},
    {"tool": "Bash", "prompt": "write files"}
  ]
}
CONFIG
fi

# Execute the command passed to the container
exec "$@"
EOF

RUN chmod +x /home/atlantis/entrypoint.sh

# Entry point - configure then run bash
ENTRYPOINT ["/home/atlantis/entrypoint.sh"]
CMD ["/bin/bash"]
