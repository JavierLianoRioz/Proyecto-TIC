# Use the official itzg/minecraft-server image as the base
FROM itzg/minecraft-server

# Set environment variables for Minecraft server configuration
ENV EULA=TRUE
ENV SERVER_NAME=MyMinecraftServer
ENV MAX_PLAYERS=20
ENV MEMORY=2G

# Expose the default Minecraft server port
EXPOSE 25565

# The base image's entrypoint and command will handle running the server with these environment variables