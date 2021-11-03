# Purge S3 Bucket
This is used to completely delete everything out of a target bucket, including versions. This is extremely helpful when you want to delete the cloudformation stack but it requires the bucket to be empty. This prevents you from having to go to each individual object in the bucket and deleting it.

This requires that you have the AWS CLI setup with a profile. You can use it like the following:

```
python PurgeS3Bucket.py --region us-west-2 --profile my-profile --bucket my-bucket-name
```
The `region` should be the AWS region holding your bucket.
The `bucket` is the name of your S3 bucket.
The `profile` is the aws cli setup profile that has permissions to purge your s3 bucket.