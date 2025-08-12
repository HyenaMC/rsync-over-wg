# Rsync over WireGuard

This composite action connects to your WireGuard network using a single wg-quick config, then optionally runs pre/post SSH commands and deploys files via rsync.

Tech stack:
- WireGuard: niklaskeerl/easy-wireguard-action@v2
- Pre/Post hooks: appleboy/ssh-action@v1.0.3
- File sync: up9cloud/action-rsync@master

## Inputs

- wg_config_file (required): Full text content of your WireGuard config (the same file used by wg-quick).
- remote_host (required): Host/IP reachable through WireGuard (e.g., 10.0.0.2).
- ssh_username (required)
- ssh_private_key (required)
- ssh_port: Default 22
- source: Local path to sync. Default ./
- target (required): Remote path to deploy to.
- rsync_args: Base rsync args. Default -az
- rsync_args_more: Appended rsync args. Optional.
- verbose: true/false to enable rsync verbose logs. Default false
- pre_script: Optional shell to run on remote before rsync.
- post_script: Optional shell to run on remote after rsync.
- auto_install_rsync_on_target: If true (default), the action will attempt to install rsync on the remote host if it's missing using a detected package manager (apt, yum, dnf, apk, zypper, pacman, opkg, brew). Set to 'false' to skip.

## Example

```yaml
name: Deploy over WireGuard

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        uses: HyenaMC/rsync-over-wg@v1.0.0
        with:
          wg_config_file: ${{ secrets.WG_CONFIG_FILE }}
          remote_host: 10.66.66.1
          ssh_username: ubuntu
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          target: /var/www/html/
          source: ./public/
          rsync_args: -az --delete --exclude=/.git/ --exclude=/.github/
          pre_script: |
            sudo systemctl stop myapp || true
          post_script: |
            sudo systemctl start myapp && sudo systemctl status --no-pager myapp
          auto_install_rsync_on_target: 'true'
```

Notes
- Provide the entire WireGuard config file content via a secret, for example by pasting your wg-quick profile into WG_CONFIG_FILE.
- up9cloud/action-rsync accepts KEY as the private key content directly; no extra ssh-agent setup is needed.
- Use rsync_args_more to append flags without replacing your base args.
- If your remote doesn't have rsync, leave auto_install_rsync_on_target as 'true' (default) and ensure your user can elevate with sudo. For distros without the listed package managers or locked-down environments, set it to 'false' and pre-install rsync yourself (e.g., in pre_script).