#cloud-config
hostname: ${hostname}
users:
  - name: ${ssh_user}
    ssh_authorized_keys:
      %{ for key in ssh_authorized_keys }
      - ${key}
      %{ endfor }
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
packages:
  - curl
  - wget
  - git
  - vim
  - htop
  - net-tools
runcmd:
  - systemctl disable --now snapd.service || true
  - echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
  - echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
  - echo "net.bridge.bridge-nf-call-ip6tables=1" >> /etc/sysctl.conf
  - sysctl --system
