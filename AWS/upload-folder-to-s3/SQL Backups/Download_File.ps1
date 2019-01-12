# Profile for CLI Creds
Initialize-AWSDefaults -ProfileName default

# Parameters
$destination_path = "C:\Downloads\DB"
$s3_bucket = "clxdbtransfer"
$encryption = "aws:kms"

# Download from S3
$latest_object = Get-S3Object -BucketName $s3_bucket | sort LastModified | select -last 1
$object_name = $latest_object.Key
$file = $destination_path + '\' + $object_name
Read-S3Object -BucketName $s3_bucket -Key $object_name -File $file
