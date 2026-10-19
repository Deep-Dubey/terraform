
# Add SSH connection configuration to the Windows SSH config file
# This lets us connect using a short alias instead of typing the full command

$sshDir = "$HOME\.ssh"
$configPath = "$sshDir\config"

# Create the SSH directory if it does not exist
New-Item -ItemType Directory -Force -Path $sshDir | Out-Null

# Build the SSH configuration entry
$entry = @'

Host ${hostname}
    HostName ${host_address}
    User ${user}
    IdentityFile ${identityfile}
'@

# Append the SSH configuration without overwriting existing entries
Add-Content -Path $configPath -Value $entry
