scp -i ${path.module}/nextcloud-ssh.pem /home/ubuntu/nextcloud-ssh.pem ubuntu@${aws_instance.my_instances[0]}:/home/ubuntu/nextcloud-ssh.pem
