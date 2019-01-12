Initialize-AWSDefaults -ProfileName aim -Region us-east-1
$instance = "i-ace8a81f"
$volumes = @(get-ec2volume) | ? { $_.Attachments.InstanceId -eq $instance}
$volumeNames = $volumes | % { $_.VolumeId}

$dimension = New-Object 'Amazon.CloudWatch.Model.Dimension'
$dimension.Name = 'VolumeId'
$dimension.Value = $volumeNames

$end = get-date
$start = get-date
$start = $start.AddSeconds(-300)

$getwriteops = Get-CWMetricStatistics -Dimension $dimension -EndTime $end -MetricName VolumeWriteOps -Namespace AWS/EBS -Period 300 -StartTime $start -Statistic "Maximum"
foreach ($datapoint in $getwriteops.Datapoints) {
Write-Host "VolumeWriteOps over 5 mins" "   " $datapoint.Maximum
}

$getreadops = Get-CWMetricStatistics -Dimension $dimension -EndTime $end -MetricName VolumeReadOps -Namespace AWS/EBS -Period 300 -StartTime $start -Statistic "Maximum"
foreach ($datapoint1 in $getreadops.Datapoints) {
Write-Host "VolumeReadOps over 5 mins" "   " $datapoint1.Maximum
}