# Usage: sh sendevent.sh  -e esaleshub -n esalesns -r training_rg -s esalesevent -t esales

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

EVENTHUB_ENDPOINT=$(az eventgrid topic show --name $TOPIC -g $RESOURCEGROUPNAME --query "endpoint" --output tsv)
EVENTHUB_KEY=$(az eventgrid topic key list --name $TOPIC -g $RESOURCEGROUPNAME --query "key1" --output tsv)
RAND=`echo $RANDOM`
for i in 1 2 3
   do
      echo $RAND
      event='[ {"id": "1", "eventType": "recordInserted", "subject": "ecomm/customers", "eventTime": "'`date +%Y-%m-%dT%H:%M:%S%z`'", "data":{ "make": "TTTTT", "model": "Monster"},"dataVersion": "1.0"} ]'
      echo $event
      curl -X POST -H "aeg-sas-key: $EVENTHUB_KEY" -d "$event" $EVENTHUB_ENDPOINT
   done