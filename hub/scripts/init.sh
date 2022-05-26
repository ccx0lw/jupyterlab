#!/usr/bin/env bash

file="/root/createusers.txt"

if [ -f $file ]
  then
    while IFS=: read -r username password is_sudo
        do
            echo "Username: $username, Password: $password , Sudo: $is_sudo"

            if getent passwd $username > /dev/null 2>&1
              then
                echo "User Exists"
              else
                useradd -ms /bin/bash $username
                usermod -aG audio $username
                usermod -aG video $username
                mkdir -p /run/user/$(id -u $username)/dbus-1/
                chmod -R 700 /run/user/$(id -u $username)/
                chown -R "$username" /run/user/$(id -u $username)/
                echo "$username:$password" | chpasswd
                if [ "$is_sudo" = "Y" ]
                  then
                    usermod -aG sudo $username
                fi
            fi
    done <"$file"
fi

startfile="/root/startup.sh"
if [ -f $startfile ]
  then
    sh $startfile
fi

export JUPYTER_ALLOW_INSECURE_WRITES=1

mkdir -p ~/.jupyter
mkdir -p ~/.local/share/jupyter/runtime

cd /root

nohup iperl

iperldir="$(jupyter --data-dir)/kernels/iperl"

until [[ -d $iperldir ]]
do
    echo "iperl not exists ......."
    sleep 10
done

cp -r $(jupyter --data-dir)/kernels/* /opt/conda/share/jupyter/kernels/

if [ -f /etc/jupyterhub/jupyterhub_config.py ]
  then
    jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
  else
    jupyterhub 
fi
