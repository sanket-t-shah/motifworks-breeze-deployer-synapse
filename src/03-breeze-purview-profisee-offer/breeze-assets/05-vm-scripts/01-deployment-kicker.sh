#/bin/bash -e
echo $@
while getopts "a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:" opt; do
	case $opt in
	a)
		resourceGroupName=$OPTARG
		;;
	b)
		location=$OPTARG
		;;
	c)
		storageAccountName=$OPTARG
		;;
	d)
		synapseWorkspaceName=$OPTARG
		;;
	e)
		synapseAdminUsername=$OPTARG
		;;
	f)
		synapseAdminPassword=$OPTARG
		;;
	g)
		synapseDedicatedPoolName=$OPTARG
		;;
	h)
		synapseDedicatedPoolSize=$OPTARG
		;;
	i)
		synapseAADAdministratorGuid=$OPTARG
		;;
	j)
		purviewAccountName=$OPTARG
		;;
	k)
		tagsSynapseWorkspace=$OPTARG
		;;
	l)
		tagsSynapseDedicatedPool=$OPTARG
		;;
	m)
		tagsPurviewAccount=$OPTARG
		;;
	n)
		profiseeLicenseData=$OPTARG
		;;
	o)
		profiseeAksClusterName=$OPTARG
		;;
	esac
done
echo "................................................................................"
echo "Currently into Directory..."
echo $(pwd)

echo "................................................................................"
# Install az purview.
# Install .NET Core.
# Install Helm.
# Install kubectl.
# Install Profisee License Reader.
# Install HELM Repos locally.

az extension add --name purview

curl -fsSL -o dotnet-install.sh https://dot.net/v1/dotnet-install.sh
chmod 755 ./dotnet-install.sh
./dotnet-install.sh -c LTS

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -fsSL -o LicenseReader.tar.001 "https://raw.githubusercontent.com/profisee/kubernetes/master/Utilities/LicenseReader/LicenseReader.tar.001"
curl -fsSL -o LicenseReader.tar.002 "https://raw.githubusercontent.com/profisee/kubernetes/master/Utilities/LicenseReader/LicenseReader.tar.002"
curl -fsSL -o LicenseReader.tar.003 "https://raw.githubusercontent.com/profisee/kubernetes/master/Utilities/LicenseReader/LicenseReader.tar.003"
curl -fsSL -o LicenseReader.tar.004 "https://raw.githubusercontent.com/profisee/kubernetes/master/Utilities/LicenseReader/LicenseReader.tar.004"
cat LicenseReader.tar.* | tar xf -
rm LicenseReader.tar.001
rm LicenseReader.tar.002
rm LicenseReader.tar.003
rm LicenseReader.tar.004

helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts
helm repo add aad-pod-identity https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts
helm repo add azurefile-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add profisee https://profisee.github.io/kubernetes
helm repo update

echo "................................................................................"
echo "Getting Profisee License..."
profiseeLicenseData = $(echo $profiseeLicenseData | tr -d '\n')

echo $"Searching Profisee license for the Fully Qualified Domain Name value..."
profiseeLicenseExternalDnsUrl=$(./LicenseReader "ExternalDnsUrl" $profiseeLicenseData)

#Use FQDN that is in license, otherwise use the Azure generated FQDN.
if [ "$profiseeLicenseExternalDnsUrl" = "" ]; then
	echo $"Profisee License External DNS URL is empty."
else
	echo $"Profisee License External DNS URL is not empty."
	profiseeLicenseExternalDnsName=$(echo $profiseeLicenseExternalDnsUrl | sed 's~http[s]*://~~g')
	profiseeLicenseDnsHostName=$(echo "${profiseeLicenseExternalDnsUrl%%.*}")
fi

profiseeAcrUsername=$(./LicenseReader "ACRUserName" $LICENSEDATA)
profiseeAcrPassword=$(./LicenseReader "ACRUserPassword" $LICENSEDATA)

echo "................................................................................"
echo "Calling PowerShell script..."
echo "sudo pwsh -Command ./02-deployment-executor.ps1 
	-resourceGroupName $resourceGroupName
	-location $location
	-storageAccountName $storageAccountName
	-synapseWorkspaceName $synapseWorkspaceName
	-synapseAdminUsername $synapseAdminUsername
	-synapseAdminPassword $synapseAdminPassword
	-synapseDedicatedPoolName $synapseDedicatedPoolName
	-synapseDedicatedPoolSize $synapseDedicatedPoolSize
	-synapseAADAdministratorGuid $synapseAADAdministratorGuid
	-purviewAccountName $purviewAccountName
	-tagsSynapseWorkspace $tagsSynapseWorkspace
	-tagsSynapseDedicatedPool $tagsSynapseDedicatedPool
	-tagsPurviewAccount $tagsPurviewAccount
	-profiseeLicenseExternalDnsUrl $profiseeLicenseExternalDnsUrl
	-profiseeLicenseExternalDnsName $profiseeLicenseExternalDnsName
	-profiseeLicenseDnsHostName $profiseeLicenseDnsHostName
	-profiseeAksClusterName $profiseeAksClusterName"

# sudo pwsh -Command ./02-deployment-executor.ps1 \
# 	-resourceGroupName $resourceGroupName \
# 	-location $location \
# 	-storageAccountName $storageAccountName \
# 	-synapseWorkspaceName $synapseWorkspaceName \
# 	-synapseAdminUsername $synapseAdminUsername \
# 	-synapseAdminPassword $synapseAdminPassword \
# 	-synapseDedicatedPoolName $synapseDedicatedPoolName \
# 	-synapseDedicatedPoolSize $synapseDedicatedPoolSize \
# 	-synapseAADAdministratorGuid $synapseAADAdministratorGuid \
# 	-purviewAccountName $purviewAccountName \
# 	-tagsSynapseWorkspace $tagsSynapseWorkspace \
# 	-tagsSynapseDedicatedPool $tagsSynapseDedicatedPool \
# 	-tagsPurviewAccount $tagsPurviewAccount \
# 	-profiseeLicenseExternalDnsUrl $profiseeLicenseExternalDnsUrl \
# 	-profiseeLicenseExternalDnsName $profiseeLicenseExternalDnsName \
# 	-profiseeLicenseDnsHostName $profiseeLicenseDnsHostName \
# 	-profiseeAksClusterName $profiseeAksClusterName

echo "Called PowerShell script."
echo "We are done successfully..."
