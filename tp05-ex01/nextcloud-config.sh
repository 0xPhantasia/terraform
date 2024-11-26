# Update system and ensure everything is up to date.
sudo apt update -y && sudo apt upgrade -y

# Install requirement to mount EFS.
sudo apt install nfs-common

# Create EFS mount directory.
sudo mkdir /mnt/efs

# Mount EFS using the previously created directory. DNS is required.
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
fs-0537d2e1c72534748.efs.eu-north-1.amazonaws.com:/ /mnt/efs

# Enabling mount point persistence by appending config to /etc/fstab.
sudo echo fs-0537d2e1c72534748.efs.eu-north-1.amazonaws.com:/ /mnt/efs nfs4 defaults,_netdev 0 0 >> /etc/fstab
