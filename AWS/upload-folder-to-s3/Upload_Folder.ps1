# Script to upload all contents of a folder to a folder in a S3 bucket.

# Profile for CLI Creds
# Set-AWSCredentials -AccessKey AKI*************XA -SecretKey Nux******************************wx/5G -StoreAs personal
Initialize-AWSDefaults -ProfileName personal

# Parameters
$source_path = "c:\backups"
$s3_bucket = "ataylor-test"
$s3_destination_path = "backups\"
$encryption = "aws:kms"     # None or aws:kms are valid values. Add this parameter to use a custom KMS key -ServerSideEncryptionKeyManagementServiceKeyId <String>

# Upload to S3
Write-S3Object -BucketName $s3_bucket -Folder $source_path -KeyPrefix $s3_destination_path -ServerSideEncryption $encryption -Recurse 

# Clean up source folder
$source_path2 = $source_path + "\*"
Remove-Item $source_path2 -recurse