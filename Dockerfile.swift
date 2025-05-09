FROM swift:5.7

# Install dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Swift source files
COPY *.swift /app/
COPY *.sh /app/

# Ensure shell scripts are executable
RUN chmod +x *.sh

# Copy iOS project files (if present)
COPY SoftEtherVPN-iOS/ /app/SoftEtherVPN-iOS/

# Set the entry point to run the fixed VPN client
CMD ["swift", "fixed_vpn_client.swift"]
