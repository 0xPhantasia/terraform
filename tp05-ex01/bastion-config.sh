# Insecure, use for debugging only
scp -i ${path.module}/nextcloud-ssh.pem /home/ubuntu/nextcloud-ssh.pem \
ubuntu@${aws_instance.bastion.public_ip}:/home/ubuntu/

# scp -i ./bastion-ssh.pem $PWD/nextcloud-ssh.pem ubuntu@13.48.26.123:/home/ubuntu/nextcloud-ssh.pem