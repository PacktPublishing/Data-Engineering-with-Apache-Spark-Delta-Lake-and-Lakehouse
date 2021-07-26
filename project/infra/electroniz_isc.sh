####################################################################################################################################################
# Usage:
# $ sh ~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra/electroniz_isc.sh IACRESOURCEGROUPNAME=elz_iac RESOURCEGROUPNAME=elz_prod LOCATION=eastus \
#   FILE_PATH=~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra
####################################################################################################################################################


####################################################################################################################################################
# Get arguments

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            IACRESOURCEGROUPNAME)              IACRESOURCEGROUPNAME=${VALUE} ;;
            RESOURCEGROUPNAME)                 RESOURCEGROUPNAME=${VALUE} ;;
            LOCATION)                          LOCATION=${VALUE} ;;
            FILE_PATH)                         FILE_PATH=${VALUE} ;;
            *)
    esac


done
####################################################################################################################################################

####################################################################################################################################################
echo "Start creation of Resource group: $RESOURCEGROUPNAME"

az group create --name $RESOURCEGROUPNAME --location $LOCATION 

echo "End creation of Resource group: $RESOURCEGROUPNAME"
####################################################################################################################################################


####################################################################################################################################################
echo "Start creation of Lakehouse_Storage_Account"

TEMPLATE_FILE=$FILE_PATH/storage_accounts/storage_accounts.json
PARAMETERS_FILE=$FILE_PATH/storage_accounts/storage_accounts_parameters.json
az deployment group create --name Lakehouse_Storage_Account --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE


echo "End creation of Lakehouse_Storage_Account"
####################################################################################################################################################    


####################################################################################################################################################
echo "Start creation of Stores_Azure_SQL_Database"

TEMPLATE_FILE=$FILE_PATH/azure_sql/azure_sql.json
PARAMETERS_FILE=$FILE_PATH/azure_sql/azure_sql_parameters.json
az deployment group create --name Stores_Azure_SQL_Database --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE 

echo "End creation of Stores_Azure_SQL_Database"
####################################################################################################################################################    


####################################################################################################################################################
echo "Start creation of Lakehouse_Event_Hub"

TEMPLATE_FILE=$FILE_PATH/event_hubs/event_hub.json
PARAMETERS_FILE=$FILE_PATH/event_hubs/event_hub_parameters.json
az deployment group create --name Lakehouse_Event_Hub --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE 

echo "End creation of Lakehouse_Event_Hub"
####################################################################################################################################################    


####################################################################################################################################################
echo "Start creation of Lakehouse_Databricks"

TEMPLATE_FILE=$FILE_PATH/databricks/databricks.json
PARAMETERS_FILE=$FILE_PATH/databricks/databricks_parameters.json
az deployment group create --name Lakehouse_Databricks --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE

echo "End creation of Lakehouse_Databricks"
####################################################################################################################################################    


####################################################################################################################################################
echo "Start creation of Lakehouse_DataFactory"

TEMPLATE_FILE=$FILE_PATH/data_factory/data_factory.json
PARAMETERS_FILE=$FILE_PATH/data_factory/data_factory_parameters.json
az deployment group create --name Lakehouse_DataFactory --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE

echo "End creation of Lakehouse_DataFactory"
####################################################################################################################################################

####################################################################################################################################################
echo "Start creation of Lakehouse_Synapse"

TEMPLATE_FILE=$FILE_PATH/synapse/synapse.json
PARAMETERS_FILE=$FILE_PATH/synapse/synapse_parameters.json
az deployment group create --name Lakehouse_Synapse --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters $PARAMETERS_FILE

echo "End creation of Lakehouse_Synapse"
####################################################################################################################################################    


