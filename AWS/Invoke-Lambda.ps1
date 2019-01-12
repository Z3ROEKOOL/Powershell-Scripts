# Assume role from user
$MFA_Token = Read-Host -Prompt 'Enter the MFA code.'
$MFA_Serial = 'arn:aws:iam::476597908832:mfa/ataylor'
$API_Access_key = 'AKIAIZH***********************'
$API_Secret_Key = 'wZD8QbHHn************************r'
$Region = 'us-east-2'
$session = Get-STSSessionToken -DurationInSeconds 7200 -SerialNumber $MFA_Serial -TokenCode $MFA_Token -AccessKey $API_Access_key -SecretKey $API_Secret_Key

Invoke-LMFunction -FunctionName create-jenkins-image -InvocationType RequestResponse -Region $Region -SessionToken $session.SessionToken -AccessKey $session.AccessKeyId -SecretKey $session.SecretAccessKey