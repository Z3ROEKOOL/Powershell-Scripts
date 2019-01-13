# Login
Login-AzureRmAccount

# List all subscriptions
Get-AzureRmSubscription

# Select a subscription
Get-AzureRmSubscription –SubscriptionName "Pay-As-You-Go" | Select-AzureRmSubscription