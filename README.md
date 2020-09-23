# jupyterlab

# build 
```dockerfile
docker build -f Dockerfile -t jupyterlab:alpine . 
```

# run
```dockerfile
docker run -it -p 8888:8888 -v /usr/local/data/jupyterlab/:/root/jupyterlab -v /etc/localtime:/etc/localtime -v /usr/local/data/.jupyter/:~/.jupyter/ --name jupyterlab loveismile/jupyterlab
```

# password
default password is ccx0lw
if you want change password, you can `` -e PASSWORD=sha1:d7c0a1595529:921a6a436d60a77e91fdc01cc257b5ee6e9e3477``
SHA1 in passwords is python encryption
```python3
from notebook.auth import passwd
passwd()
```

# other
