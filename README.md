# WireGuard File Sync Action

This GitHub Action connects to a WireGuard network and syncs files from a repository to a remote server.

## Features

- Connect to a WireGuard network automatically
- Sync files from any branch or tag to a remote server
- Two sync modes: overwrite (only update existing files) or clean_copy (delete non-existent files)
- Flexible exclusion and protection rules
- Dry-run mode for testing
- Detailed output and statistics

## Inputs

### WireGuard Connection Parameters

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `wireguard_private_key` | WireGuard private key | Yes | - |
| `wireguard_local_ip` | Local WireGuard IP (e.g., 192.168.1.2/24) | Yes | - |
| `wireguard_peer_ip` | Peer WireGuard IP (e.g., 192.168.1.1/24) | Yes | - |
| `wireguard_peer_public_key` | Peer WireGuard public key | Yes | - |
| `wireguard_peer_endpoint` | Peer endpoint (e.g., 1.2.3.4:51820) | Yes | - |
| `wireguard_local_port` | Local WireGuard port | No | 51820 |

### SSH Connection Parameters

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `ssh_private_key` | SSH private key for remote server | Yes | - |
| `ssh_user` | SSH username | Yes | - |
| `ssh_port` | SSH port | No | 22 |

### Sync Parameters

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `source_path` | Source path in repository | No | ./ |
| `target_path` | Target path on remote server | Yes | - |
| `sync_mode` | Sync mode: overwrite or clean_copy | No | overwrite |
| `exclude_patterns` | Comma-separated list of additional patterns to exclude | No | - |
| `protect_patterns` | Comma-separated list of patterns to protect from deletion | No | - |
| `custom_rsync_filter` | Custom rsync filter file path in repository | No | - |

### Git Parameters

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `repository` | Repository to sync | No | Current repository |
| `ref` | Git ref to sync (branch, tag, or SHA) | No | Current SHA |

### Debug Parameters

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `dry_run` | Dry run mode | No | false |
| `debug` | Enable debug output | No | false |

## Outputs

| Output | Description |
|--------|-------------|
| `sync_status` | Status of the sync operation (success/failure) |
| `sync_files_count` | Number of files synced |
| `sync_bytes_transferred` | Number of bytes transferred |

## Usage Example

### Basic Usage

```yaml
name: Sync to Production

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Sync files via WireGuard
        uses: your-username/wireguard-file-sync@v1
        with:
          # WireGuard parameters
          wireguard_private_key: ${{ secrets.WIREGUARD_PRIVATE_KEY }}
          wireguard_local_ip: 192.168.1.2/24
          wireguard_peer_ip: 192.168.1.1/24
          wireguard_peer_public_key: ${{ secrets.WIREGUARD_PEER_PUBLIC_KEY }}
          wireguard_peer_endpoint: ${{ secrets.WIREGUARD_PEER_ENDPOINT }}
          
          # SSH parameters
          ssh_private_key: ${{ secrets.SSH_PRIVATE_KEY }}
          ssh_user: ubuntu
          ssh_port: 22
          
          # Sync parameters
          source_path: ./
          target_path: /var/www/html/
          sync_mode: clean_copy