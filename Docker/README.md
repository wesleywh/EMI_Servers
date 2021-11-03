# Running A Server With Docker
## Pre-Req
You need to make sure you build your unity server into a folder call `Server`. That way it will match this dockerfile exactly. If you have not done this, you will need to modify the dockerfile according to your own naming scheme.

## Build Your Docker
This will require you to build your dockerfile locally using the docker build command:
```
docker build -t my-dockerfile-tag:my-tag-value .
```
or if you're running that build command from the root of this project:
```
docker build -t my-dockerfile-tag:my-tag-value -f Docker/Dockerfile .
```
Note: You can change `my-dockerfile-tag` and `my-tag-value` to whatever you want. However, if you plan on pushing this to something like aws ECR then be sure to follow their instructions on proper naming and tagging of your docker.

## Run Your Docker
Now that you have your docker built you can start the docker.
```
docker run --name my-docker-name -p 7777:7777 my-dockerfile-tag:my-tag-value
```
If you're running on a different port inside your docker or want to connect using a different port be sure to change `-p 7777:7777` to your needs. 

If you want to run the docker as a background daemon running your server, include the `-d` command like so:
```
docker run -d --name my-docker-name -p 7777:7777 my-dockerfile-tag:my-tag-value
```