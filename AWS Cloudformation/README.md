# Unity Mirror Server In AWS With EC2
This is a set of automation that is built using `Cloudformation` an AWS service. I have a whole video explaining this on YouTube. 

## Pre-Req
This requires that you have built your server into an executable called `Server`. If you don't like that look at the `LaunchConfig` in the template and change this according to your naming scheme. That's the only thing you need to change.

This will require you to do the following manually:
* Mount additional EBS Volumes (if you're using them)
* Create HostedZone with A Record to update
* Create SSH Key using the create key in the AWS Console of EC2

## What Does This Do?
This will create an auto healing EC2 cluster of one instance that will do the following:
* Auto pull the server code from S3
* Automatically start the server code when the EC2 server spins up
* Automatically register the EC2 instances public ip to a Route53 "A" record

