

# Setup array with vCenters
$vcenter = @( 
    "x.x.x.x"
);

# Store your User&Password
$user = "VCusername" 
$password = "VCpassword"

# Connect 
Connect-VIServer -Server $vcenter -User $user -Password $password

$vms = Import-Csv C:\PCLI\test.csv


foreach ($vm in $vms){
	#CSV field
	$vmname = $vm.name
	$cluster = $vm.cluster
	$vmnetwork = $vm.vmnetwork
	$mac = $vm.mac
	$ip = $vm.ip
	$subnet = $vm.subnet
	$gateway = $vm.gateway
	$dns = $vm.dns
	
	#OVA File location
	$ovffile = "C:\$vmname.ova"
	$ovfconfig = Get-OvfConfiguration $ovffile
	
	#Host & Datastore location
	$vmhost = Get-Cluster $Cluster | Get-VMHost | Sort MemoryGB | Select -first 1
	$datastore = $vmhost | Get-datastore | Sort FreeSpaceGB -Descending | Select -first 1
	
	# Deploy the OVF/OVA with the config parameters
	Import-VApp -Source $ovffile -Name $vmname -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin
	
	# Configuration VM of Portgroup
	$vmna = Get-VM $vmname | Get-NetworkAdapter -Name "Network adapter 1"
	$vdspg = Get-VDPortgroup -Name $vmnetwork
	Set-NetworkAdapter -NetworkAdapter $vmna -Portgroup $vdspg -confirm:$false 
	#Set-NetworkAdapter -NetworkAdapter $vmna -Portgroup $vdspg -MacAddress $mac -confirm:$false 
	
	# Start the Virtual Machine
	Start-VM -VM $VMName -Confirm:$false
	
}