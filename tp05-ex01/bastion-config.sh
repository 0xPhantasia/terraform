# Insecure, use for debugging only
scp -i ${path.module}/nextcloud-ssh.pem /home/ubuntu/nextcloud-ssh.pem \
ubuntu@${aws_instance.bastion.private_ip}:/home/ubuntu/
