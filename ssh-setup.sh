#!/bin/bash

NEW_WEB_IP=$(multipass list | grep web-server | awk '{print $3}')
NEW_DB_IP=$(multipass list | grep db-server | awk '{print $3}')
NEW_APP_IP=$(multipass list | grep app-server | awk '{print $3}')

echo "New IPs:"
echo "Web: $NEW_WEB_IP"
echo "DB: $NEW_DB_IP"
echo "App: $NEW_APP_IP"

for vm in web-server db-server app-server; do
    echo "Setting up SSH for $vm..."
    echo "mkdir -p ~/.ssh && chmod 700 ~/.ssh && exit" | multipass shell $vm
    multipass transfer ~/.ssh/id_rsa.pub $vm:/home/ubuntu/.ssh/authorized_keys
    echo "chmod 600 ~/.ssh/authorized_keys && chown ubuntu:ubuntu ~/.ssh/authorized_keys && exit" | multipass shell $vm
    echo "SSH setup complete for $vm"
done

# inv file
echo "Updating inventory.yml..."
cat > inventory.yml << EOF
all:
  children:
    webservers:
      hosts:
        web-server:
          ansible_host: $NEW_WEB_IP
    databases:
      hosts:
        db-server:
          ansible_host: $NEW_DB_IP
    appservers:
      hosts:
        app-server:
          ansible_host: $NEW_APP_IP
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    ansible_python_interpreter: /usr/bin/python3.12
EOF

echo "Testing SSH connections..."
ssh ubuntu@$NEW_WEB_IP "echo 'web-server connection OK'"
ssh ubuntu@$NEW_DB_IP "echo 'db-server connection OK'"
ssh ubuntu@$NEW_APP_IP "echo 'app-server connection OK'"

echo "Testing Ansible connectivity..."
ansible all -m ping