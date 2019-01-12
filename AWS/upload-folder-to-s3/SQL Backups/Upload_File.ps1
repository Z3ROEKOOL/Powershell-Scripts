# Profile for CLI Creds
Initialize-AWSDefaults -ProfileName default

# Parameters
$source_path = "C:\DataStore\SQL Backups"
$s3_bucket = "clxdbtransfer"
$encryption = "aws:kms"

# Upload to S3
$latest_file = Get-ChildItem $source_path *.bak | sort LastWriteTime | select -last 1
$file = $source_path + '\' + $latest_file
Write-S3Object -BucketName $s3_bucket -Key $latest_file -File $file -ServerSideEncryption $encryption 