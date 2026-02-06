# SSH Setup for Project

This project has been configured to use SSH for all existing connections.

## SSH Key Details

- **Type**: Ed25519
- **Path**: `~/.ssh/id_ed25519`
- **Public Key**:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeSLWKibLOYIOA794iClIT7WU/32N1BbfzHR8hopSGG jules@google.com
```

## Configured Connections

### 1. GitHub
The git remote `origin` has been updated to use SSH:
`git@github.com:A6-9V/MQL5-Google-Onedrive.git`

**Action Required**:
Please add the public key above to your GitHub account:
[GitHub SSH Key Settings](https://github.com/settings/keys)

### 2. MQL5 Forge (Manual Setup)
If you wish to use SSH with Forge, add the public key to your Forge profile:
[Forge SSH Key Settings](https://forge.mql5.io/user/settings/ssh)

Then update the remote (if you add one):
`git remote add forge git@forge.mql5.io:LengKundee/mql5.git`

### 3. VPS (Manual Setup)
To enable SSH access to your VPS without a password:
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-vps-ip
```
Or manually append the public key to `~/.ssh/authorized_keys` on the VPS.

## Verifying Setup
Once the key is added to GitHub, you can test the connection:
```bash
ssh -T git@github.com
```
