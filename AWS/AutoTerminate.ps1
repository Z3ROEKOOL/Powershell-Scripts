Initialize-AWSDefaults -ProfileName personal

$regions = 'us-east-1', 'us-west-1', 'us-west-2'

foreach ($region in $regions){

    # Remove Auto Scaling without AutoTerminate tag
    $autoscalinggroups = Get-ASAutoScalingGroup -Region $region
    foreach ($autoscalinggroup in $autoscalinggroups){
        if ($autoscalinggroup.Tags.Key -eq 'AutoTerminate' -and $autoscalinggroup.Tags.Value -eq 'false') {Write-Host 'Doing Nothing'}
        else {Remove-ASAutoScalingGroup -AutoScalingGroupName $autoscalinggroup.AutoScalingGroupName -Region $region -Force -ForceDelete 1}
    }
    $launchconfigs = Get-ASLaunchConfiguration -Region $region
    foreach ($launchconfig in $launchconfigs) {
        Remove-ASLaunchConfiguration -Region $region -LaunchConfigurationName $launchconfig.LaunchConfigurationName -Force -ErrorAction SilentlyContinue
    }

    # Remove instances without AutoTerminate tag
    $instances = (Get-EC2Instance -Region $region).instances
    foreach ($instance in $instances){
        if ($instance.Tag.Key -eq 'AutoTerminate' -and $instance.Tag.Value -eq 'false') {Write-Host 'Leaving ' $instance.InstanceId}
        else {Remove-EC2Instance -InstanceId $instance.InstanceId -Region $region -Force}
    }

    # Remove EBS volumes not attached to any instances
    $volumes = Get-EC2Volume -Region $region | Where-Object {$_.state -eq 'available'}
    foreach ($volume in $volumes){
        Remove-EC2Volume -Force -VolumeId $volume.VolumeId -Region $region
    }

    # Remove ELB's without AutoTerminate tag
    $elbs = Get-ELBLoadBalancer -Region $region
    foreach ($elb in $elbs){
        $elb_tag = Get-ELBTags -LoadBalancerName $elb.LoadBalancerName
        if ($elb_tag.Tags.Key -eq 'AutoTerminate' -and $elb_tag.Tags.Value -eq 'false') {Write-Host 'Doing Nothing'}
        else{Remove-ELBLoadBalancer -Force -LoadBalancerName $elb.LoadBalancerName -Region $region}
    }

    # Remove S3 buckets without AutoTerminate tag
    $buckets = Get-S3Bucket -Region $region
    foreach ($bucket in $buckets){
        $bucket_tags = Get-S3BucketTagging -BucketName $bucket.BucketName
        if ($bucket_tags.Key -eq 'AutoTerminate' -and $bucket_tags.Value -eq 'false') {Write-Host 'Doing Nothing'}
        else {Remove-S3Bucket -BucketName $bucket.BucketName -Force -DeleteBucketContent -ErrorAction SilentlyContinue}
    }

    # Remove all RDS instances
    $rds_instances = Get-RDSDBInstance -Region $region
    foreach ($rds_instance in $rds_instances){
        Remove-RDSDBInstance -DBInstanceIdentifier $rds_instance.DBInstanceIdentifier -Force -SkipFinalSnapshot 1
    }
}