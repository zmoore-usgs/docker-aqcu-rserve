# AQCU RServe Docker

This Docker container is an implementation of the RServe used for the AQCU project.

To run, simply use `docker-compose up`. This will build and launch the container.

To build using the docker commandline:
```
$ docker build -t aqcu-rserve:latest .
$ docker run -d -p '6311:6311' aqcu-rserve:latest
```

By default, the username and password are both `rserve`. This can be changed by
adding environment flags into your run or docker-compose file. You can also mount
an RServe pwdfile into `/opt/rserve/etc/Rserv.pwd`. For example:

`$ docker run -d -p '6311:6311' -v ''/path/to/local/Rserv.pwd:/opt/rserve/etc/Rserv.pwd' aqcu-rserve:latest`
