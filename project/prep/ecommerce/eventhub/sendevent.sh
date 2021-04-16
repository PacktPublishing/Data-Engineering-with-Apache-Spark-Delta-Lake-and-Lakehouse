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

while read -r ORDER;
   do
      echo $ORDER
      curl -X POST -H "aeg-sas-key: $EVENTHUB_KEY" -d "$ORDER" $EVENTHUB_ENDPOINT
   done < ~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/prep/ecommerce/eventhub/ecomm_orders.txt