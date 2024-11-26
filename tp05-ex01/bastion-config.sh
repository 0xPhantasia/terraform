# Insecure, use for debugging only
scp -i ${path.module}/nextcloud-ssh.pem /home/ubuntu/nextcloud-ssh.pem \
ubuntu@${aws_instance.bastion.public_ip}:/home/ubuntu/
