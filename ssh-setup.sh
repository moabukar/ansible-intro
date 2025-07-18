NEW_WEB_IP=$(multipass list | grep web-server | awk '{print $3}')
NEW_DB_IP=$(multipass list | grep db-server | awk '{print $3}')
NEW_APP_IP=$(multipass list | grep app-server | awk '{print $3}')

echo "New IPs:"
echo "Web: $NEW_WEB_IP"
echo "DB: $NEW_DB_IP"
echo "App: $NEW_APP_IP"

# Setup SSH keys for all VMs
for vm in web-server db-server app-server; do
    echo "Setting up SSH for $vm..."
    multipass exec $vm -- bash -c 'mkdir -p /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh'
    multipass transfer ~/.ssh/id_rsa.pub $vm:/home/ubuntu/.ssh/authorized_keys
    multipass exec $vm -- bash -c 'chmod 600 /home/ubuntu/.ssh/authorized_keys && chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys'
done