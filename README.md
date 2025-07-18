# Ansible Intro

## What is Ansible?

Ansible is a tool for configuration management, application deployment, orchestration, and many other things. It uses a declarative language to describe the desired state of the system.

## Setup 

```bash
brew install multipass 

# or you can use a VM or EC2. 
```

```bash
# control node (where we'll run Ansible)
## multipass launch --name ansible-control --cpus 2 --memory 2G --disk 20G (if you dont have ansible installed)
## i will use my mac here thought as the control node

# target nodes
# Create target nodes (your Mac will be the control node)
multipass launch --name web-server --cpus 1 --memory 1G --disk 50G
multipass launch --name db-server --cpus 1 --memory 1G --disk 5G
multipass launch --name app-server --cpus 1 --memory 1G --disk 5G

multipass list

multipass shell ansible-control

sudo apt update
sudo apt install -y ansible python3-pip

ssh-keygen -t rsa -b 4096 -C "ansible@lab" -f ~/.ssh/id_rsa -N ""

# Get the public key
cat ~/.ssh/id_rsa.pub

# For each target node, run:
ssh-copy-id ubuntu@<TARGET_IP>
# Example: ssh-copy-id ubuntu@192.168.64.4

# Or if ssh-copy-id doesn't work on Mac:
ssh ubuntu@<TARGET_IP> 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_rsa.pub

```

## Testing

```bash
#### Connection test ####

# Test connection to all hosts
ansible all -m ping

# Test specific group
ansible webservers -m ping

#### Gather system information/facts ####

# Gather system information
ansible all -m setup

# Get specific facts
ansible all -m setup -a "filter=ansible_os_family"

#### Ad-hoc commands ####

# Check disk space
ansible all -m shell -a "df -h"

# Check memory usage
ansible all -m shell -a "free -h"

# Install package
ansible all -m apt -a "name=htop state=present" --become

# Create a user
ansible all -m user -a "name=testuser state=present" --become
```

### Individual playbooks

```bash
ansible-playbook web-setup.yml
ansible-playbook db-setup.yml
ansible-playbook app-setup.yml
```

## All plays at once

```bash
ansible-playbook site.yml
```

## Verify installation

```bash
# Check web server
curl http://<WEB_SERVER_IP>

# Check if services are running
ansible all -m shell -a "systemctl status nginx" --limit webservers
ansible all -m shell -a "systemctl status mysql" --limit databases
```