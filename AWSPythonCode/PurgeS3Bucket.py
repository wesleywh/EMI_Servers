import argparse
import boto3
# Install boto3: pip install boto3 --target=C:\path\to\dir
parser = argparse.ArgumentParser(description='Deletes everything in a bucket including versions.')
parser.add_argument('--bucket', dest='bucket', help='The S3 bucket name to compeltely purge.')
parser.add_argument('--profile', dest='profile', help='The AWS profile to use.')
parser.add_argument('--region', dest='region', help='The AWS region of this s3 bucket.')
args = parser.parse_args()

session = boto3.session.Session(profile_name=args.profile)
s3 = session.resource('s3', region_name=args.region)
bucket = s3.Bucket(args.bucket)
bucket.objects.all().delete()
bucket.object_versions.delete()