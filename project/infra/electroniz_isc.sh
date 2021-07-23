####################################################################################################################################################
Usage:
$ sh ~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra/electroniz_isc.sh
####################################################################################################################################################


####################################################################################################################################################
# Edit this section for desired names and settings for Azure resources

IACRESOURCEGROUPNAME="elz_iac"
RESOURCEGROUPNAME="elz_prod"
LOCATION="eastus"
KEYVAULTNAME="deploykvelz"
ENVIRONMENT="prod"
PROJECT="dlake"
STORAGEACCOUNTNAME="elz"
BRONZELAYER="bronze"
SILVERLAYER="silver"
GOLDLAYER="gold"
SERVERNAME="elzsql"
DATABASENAME="salesdb"
VAULTNAME="deploykvelz"
PASSWORDSECRETNAME="SQLPASSWORD"
USERSECRETNAME="SQLUSER"
TOPICNAME="esales"
SUBSCRIPTIONNAME="esalesevent"
EVENTHUBNAMESPACE="esalesns"
EVENTHUBNAME="esaleshub"
STORAGEACCOUNTNAMEECOMM="elzlogs"
STORAGEACCOUNTCONTAINERNAME="ecommlogs"
DATABRICKSWORKSPACENAME="elzdbws"
FACTORYNAME="elzdf"
SYNAPSEWORKSPACENAME="elzsyn"
####################################################################################################################################################

####################################################################################################################################################
echo "Start creation of Resource group: $RESOURCEGROUPNAME"

az group create --name $RESOURCEGROUPNAME --location $LOCATION 

echo "End creation of Resource group: $RESOURCEGROUPNAME"
####################################################################################################################################################


####################################################################################################################################################
echo "Start creation of Lakehouse_Storage_Account: $STORAGEACCOUNTNAME"

TEMPLATE_FILE="~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra/storage_accounts/storage_accounts.json"
az deployment group create --name Lakehouse_Storage_Account --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters environment=$ENVIRONMENT project=$PROJECT storageAccountName=$STORAGEACCOUNTNAME bronzeLayer=$BRONZELAYER silverLayer=$SILVERLAYER goldLayer=$GOLDLAYER location=$LOCATION 

echo "End creation of Lakehouse_Storage_Account: $STORAGEACCOUNTNAME"
####################################################################################################################################################    


####################################################################################################################################################
echo "Start creation of Stores_Azure_SQL_Database: $SERVERNAME"

TEMPLATE_FILE="~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra/azure_sql/azure_sql.json"
az deployment group create --name Stores_Azure_SQL_Database --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters vaultName=$VAULTNAME databaseName=$DATABASENAME adminPasswordsecretName=$PASSWORDSECRETNAME sqlServerName=$SERVERNAME adminLoginUsersecretName=$USERSECRETNAME vaultResourceGroupName=$IACRESOURCEGROUPNAME 

echo "End creation of Stores_Azure_SQL_Database: $SERVERNAME"
####################################################################################################################################################    


####################################################################################################################################################
echo "Start creation of Lakehouse_Event_Hub: $EVENTHUBNAMESPACE"

TEMPLATE_FILE="~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra/event_hubs/event_hub.json"
az deployment group create --name Lakehouse_Event_Hub --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters environment=$ENVIRONMENT project=$PROJECT topicName=$TOPICNAME subscriptionName=$SUBSCRIPTIONNAME eventHubNamespace=$EVENTHUBNAMESPACE eventHubName=$EVENTHUBNAME storageAccountName=$STORAGEACCOUNTNAMEECOMM storageAccountContainerName=$STORAGEACCOUNTCONTAINERNAME location=$LOCATION

echo "End creation of Lakehouse_Event_Hub: $EVENTHUBNAMESPACE"
####################################################################################################################################################    


####################################################################################################################################################
echo "Start creation of Lakehouse_Databricks: $DATABRICKSWORKSPACENAME"

TEMPLATE_FILE="~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra/databricks/databricks.json"
az deployment group create --name Lakehouse_Databricks --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters environment=$ENVIRONMENT project=$PROJECT databricksWorkspaceName=$DATABRICKSWORKSPACENAME location=$LOCATION

echo "End creation of Lakehouse_Databricks: $DATABRICKSWORKSPACENAME"
####################################################################################################################################################    


####################################################################################################################################################
echo "Start creation of Lakehouse_DataFactory: $FACTORYNAME"

TEMPLATE_FILE="~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra/data_factory/data_factory.json"
az deployment group create --name Lakehouse_DataFactory --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters environment=$ENVIRONMENT project=$PROJECT location=$LOCATION factoryName=$FACTORYNAME 

echo "End creation of Lakehouse_DataFactory: $FACTORYNAME"
####################################################################################################################################################

####################################################################################################################################################
echo "Start creation of Lakehouse_Synapse: $SYNAPSEWORKSPACENAME"

TEMPLATE_FILE="~/Data-Engineering-with-Apache-Spark-Delta-Lake-and-Lakehouse/project/infra/synapse/synapse.json"
az deployment group create --name Lakehouse_Synapse --resource-group $RESOURCEGROUPNAME --template-file $TEMPLATE_FILE --parameters vaultName=$VAULTNAME synapseWorkspaceName=$SYNAPSEWORKSPACENAME synapseStorageAccount=$STORAGEACCOUNTNAME synapseStorageAccountFilesystem=$GOLDLAYER  adminPasswordsecretName=$PASSWORDSECRETNAME adminLoginUsersecretName=$USERSECRETNAME vaultResourceGroupName=$IACRESOURCEGROUPNAME 

echo "End creation of Lakehouse_Synapse: $SYNAPSEWORKSPACENAME"
####################################################################################################################################################    


