# Usage: sh eventhub.sh  -e esaleshub -n esalesns -r training_rg -s esalesevent -t esales

while getopts e:n:r:s:t: option
do
case "${option}"
in
e) EVENTHUB_NAME=${OPTARG};;
n) EVENTHUB_NAMESPACE=${OPTARG};;
r) RESOURCEGROUPNAME=${OPTARG};;
s) EVENT_SUBSCRIPTION=${OPTARG};;
t) TOPIC=${OPTARG};;
esac
done

az eventhubs eventhub show --name $EVENTHUB_NAME --namespace-name $EVENTHUB_NAMESPACE --resource-group $RESOURCEGROUPNAME  --query id --output tsv
EVENTHUB_SUBSCRIPTION=$(az eventhubs eventhub show --name $EVENTHUB_NAME --namespace-name $EVENTHUB_NAMESPACE --resource-group $RESOURCEGROUPNAME --query id --output tsv)
EVENTGRID_SUBSCRIPTION=$(az eventgrid topic show --name $TOPIC -g $RESOURCEGROUPNAME --query id --output tsv)
az eventgrid event-subscription create --source-resource-id $EVENTGRID_SUBSCRIPTION --name $EVENT_SUBSCRIPTION --endpoint-type eventhub --endpoint $EVENTHUB_SUBSCRIPTION