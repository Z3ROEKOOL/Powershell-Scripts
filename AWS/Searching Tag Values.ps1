Initialize-AWSDefaults -ProfileName aim -Region us-east-1

$deploymentIps = @()
$filter_tag = New-Object Amazon.EC2.Model.Filter
$filter_value="healthy_living"
$filter_tag.WithName( "key" ).WithValue("business_unit") | out-null
$filter_tag.WithName( "value" ).WithValue( "$filter_value" ) | out-null
$instances = get-ec2tag -Filter $filter_tag
$instances = $instances | select-object -uniq ResourceId
$instances | foreach-object{
	$i = get-ec2instance -instance $_.ResourceId
	foreach ($id in $i) {
		$deploymentIps += $id.runninginstance | select-object -first 1 privateipaddress
	}
}