[日本語](README.ja.md) | English

# Custom [code-server](https://github.com/coder/code-server) Setup

A fully customized, rootless-Docker-friendly [`code-server`](https://github.com/coder/code-server) (VS Code in the browser) environment with Python, `uv`, Node.js, and cute terminal prompts!

> [!IMPORTANT]
> The code-server service in this container runs with root privileges (UID 0) inside the container. The actual Linux user account is named coder, but we use a neat little terminal hack so whoami proudly says itomi!

## Features
- **Rootless Docker Friendly:** Solves the annoying file permission issues (no more `sudo` or lock icons!) by dynamically mapping the container user to your host user.
- **Pre-installed Tools:** Comes with Python 3, `uv` (super fast Python package manager), `jq`, Japanese fonts, and the latest "Current" Node.js via `nvm`.
- **Custom Terminal:** Features a cute pastel prompt with git branch integration and random tsundere/pun motivational messages.
- **Persistent Data:** All your settings, extensions, and tools are saved in local bind mounts so they survive container rebuilds.

## Folder Structure
When you run this, it will create the following folders in your directory:
- `workspace/` - Your actual coding projects.
- `.config/` - VS Code and code-server settings.
- `.local/` - Local tool installations and binaries.
- `.ssh/` - Your SSH keys (for use with git).

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/miyumi-aho/custom-code-server
   cd custom-code-server
   ```

2. **Create the necessary folders:**
   *(Important: Creating them beforehand prevents rootless Docker permission errors!)*
   ```bash
   mkdir -p workspace .config .local
   ```

3. **Build and run the container:**
   ```bash
   docker compose up -d --build
   ```

4. **Open your browser:**
   Go to [`http://localhost:8443`](http://localhost:8443) OR [`http://127.0.0.1:8443`](http://127.0.0.1:8443) and start coding!

## Maintenance & Updating
To keep your tools (Node.js, uv, Python packages) up-to-date with the latest versions and security patches, simply run the included update script:
```bash
./update.sh
```
This will pull the latest base images, rebuild the container with the newest tools, and clean up old Docker caches to save space!

## How it Works (The Permissions!!!!)

> [!NOTE]
> I used the following repository as reference & inspiration for the permission mapping:
> https://github.com/martinussuherman/alpine-code-server

If you've ever used `code-server` in rootless Docker, you know the pain of files being owned by a random UID (like `525287`) because of user namespace remapping. 

This setup uses a custom `entrypoint.sh` script that runs `gosu` (similar to `su-exec`). It changes the internal `coder` user's UID/GID to `0` (root) *inside* the container. Because of how rootless Docker maps UIDs, Container UID `0` maps directly back to your Host UID (usually `1000`). This means all files created inside the container are perfectly owned by your actual user on your host machine!

## Customization
- **Terminal Prompt:** Edit `custom.bashrc` to change the colors, kaomojis, or the motivational messages!
- **Adding Tools:** Add your favorite `apt-get` packages to the `Dockerfile` under the `root` user section.
- **Node Version:** Change `nvm install node` in the `Dockerfile` to a specific version (like `nvm install 26`) if you prefer to lock it.

