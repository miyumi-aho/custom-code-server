#!/bin/bash

echo "Starting maintenance and updates... (≧◡≦)"

# Pull the latest base image from the internet
docker compose pull

# Rebuild the container. 
# This will re-run the Dockerfile, fetching the latest uv, node, and apt packages!
docker compose up -d --build

# 3. Clean up the old, unused images to save space
docker system prune -f

echo "All done! Your environment is fresh and updated! (ﾉ´ヮ\`)ﾉ*: ･ﾟ✧"

