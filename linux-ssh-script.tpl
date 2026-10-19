
# Append SSH connection details to the existing SSH config file
cat >> ~/.ssh/config <<EOF

# Define a short alias for the remote server
Host ${hostname}

    # Set the server's hostname or public IP address
    HostName ${hostname}

    # Specify the username used to log in to the server
    User ${user}

    # Specify the private SSH key used for authentication
    IdentityFile ${identityfile}
EOF
