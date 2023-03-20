
$marque = (Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer
$model = (Get-WmiObject -Class:Win32_ComputerSystem).Model
$name = (Get-WmiObject -Class Win32_Processor).Name
$ramsize =(Get-WmiObject -Class:Win32_ComputerSystem).TotalPhysicalMemory / 1GB
$ramint = [int]$ramsize
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size
$disksize = $disk.Size / 1GB
$disk2 = [int]$disksize
$mediatype = (get-physicaldisk).mediatype[0]

write-host $marque
write-host $model
write-host $name
write-host $ramint "Go de RAM"
write-host $disk2 "Go de stockage " $mediatype


write-host "verification du status de licence de windows 10 ..." 

$Status = (Get-CimInstance -ClassName SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where PartialProductKey).licensestatus

	If ($Status -eq 1)
	{
		write-host "windows 10 est activé" -foregroundcolor 'green'
	}
	Else
	{
		$ProductKey = (Get-WmiObject -Class SoftwareLicensingService).OA3xOriginalProductKey
		if (-not [string]::IsNullOrEmpty($ProductKey))
		{
			write-host "cle d'activation trouvée" -foregroundcolor 'green'
			write-host $productkey -foregroundcolor 'yellow'
			write-host "activation de windows 10 en cours ..." -foregroundcolor 'yellow'
			cscript c:\Windows\System32\slmgr.vbs -ipk $ProductKey
			cscript c:\Windows\System32\slmgr.vbs -ato
		}
		else
		{
		write-host "Le BIOS ne contient pas de clé windows" -foregroundcolor 'red'
		}
	}





#slmgr /xpr


#Caméra statut
	$cam = Get-PnpDevice -FriendlyName *cam* | select Status
	if ($cam.Status -eq "ok")
	{
		write-host "La caméra fonctionne" -foregroundcolor 'green'
	}
	else
	{
		write-host "La caméra ne fonctionne pas" -foregroundcolor 'red'
	}

#USB status
	$usb = Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
		Foreach($element in $usb) 
	{ 
	if ($element.Status -eq "error")
		{
			write-host "Probleme detecter avec un port USB" -foregroundcolor 'red'
		}
	}
write-host "USB OK" -foregroundcolor 'green'


#Batterie

$DesignedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
$FullChargedCapacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
$heathlbatt = [int](100*$FullChargedCapacity/$DesignedCapacity)
if($heathlbatt -ge 81)
	{
		write-host $heathlbatt "%" -foregroundcolor 'green'	
	}
elseif($heathlbatt -eq 80)
	{
		write-host $heathlbatt "%" -foregroundcolor 'orange'
	}
else
	{
		write-host $heathlbatt "%" -foregroundcolor 'red'
	}


#Gestionnaire de periphérique

$liste = Get-WmiObject Win32_PNPEntity
Foreach($element in $liste) 
	{ 
	if ($element.Status -eq "error")
		{
			write-host "Le gestionnaire de périphérique n'est pas à jour" -foregroundcolor 'red'
		}
	}
write-host "Le gestionnaire de périphérique est à jour" -foregroundcolor 'green'


#Status disque dur

	$hddheat = (get-physicaldisk).healthstatus[0]
	if($hddheat -eq "healthy"){
		write-host "disque dur ok "$hddheat  -foregroundcolor 'green'
	}
	else{
		write-host "test smart echoué"$hddheat -foregroundcolor 'orange'
	}

$opstat = (get-physicaldisk).OperationalStatus[0]
	if($opstat -eq "OK"){
		write-host "statut operationnel du disque "$opstat  -foregroundcolor 'green'
	}
	else{
		write-host "statut operationnel du disque "$opstat -foregroundcolor 'orange'
	}


#temperature disque dur
#Get-PhysicalDisk | Get-StorageReliabilityCounter | select-object -Property "*"

$temp = (Get-PhysicalDisk | Get-StorageReliabilityCounter).Temperature[1]
$temp2 = (Get-PhysicalDisk | Get-StorageReliabilityCounter).Temperature[0]
if($temp -eq 0)
{
	if($temp2 -ge 55)
	{
		write-host $temp2 " C°" -foregroundcolor 'orange'
	}
	else
	{
		write-host $temp2 " C°" -foregroundcolor 'green'
	}
		
}
else
{
	if($temp -ge 55)
	{
	write-host $temp " C°" -foregroundcolor 'orange'
	}
	else
	{
	write-host $temp " C°" -foregroundcolor 'green'
	}	
}


#partition de recuperation

$dsk = Get-Disk | select Number
$numD = $dsk.Number
$par = Get-Partition –DiskNumber $numD
$t = $par.Length

 For ($j = 0; $j -lt $t; $j++)
   {  
       $type = ($par.GetValue($j)).Type
       $numP = ($par.GetValue($j)).PartitionNumber
       
           
          If ($type -eq "Recovery"){
              Write-Host "La partition de récupération est trouvée" -foregroundcolor 'green'
            }
	Else{
		Write-Host "Partition de récupération introuvable" -foregroundcolor 'red'
		}
    }

Read-Host "Appuyez sur ENTREE pour allumé la camera ..."

#ouvrir caméra

start microsoft.windows.camera:


#https://learn.microsoft.com/fr-fr/windows/win32/cimwin32prov/win32-currentprobe
