$Camera = Get-PnpDevice -FriendlyName *cam* | select Status
$Usb = Get-PnpDevice -PresentOnly | Where-Object { $_.InstanceId -match '^USB' }
$Battery = [int](100 * (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity / (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity)
$Driver = Get-WmiObject Win32_PNPEntity
$StatusDisk = (get-physicaldisk).OperationalStatus[0]
$Temperature = (Get-PhysicalDisk | Get-StorageReliabilityCounter).Temperature[1]
$Temperature2 = (Get-PhysicalDisk | Get-StorageReliabilityCounter).Temperature[0]
$License = (Get-WmiObject -Class SoftwareLicensingService).OA3xOriginalProductKey

write-host "`n " 'Ordinateur' "`n" -ForegroundColor White

write-host ' ' (Get-WmiObject -Class:Win32_ComputerSystem).Model '' -ForegroundColor Yellow
write-host ' ' (Get-WmiObject -Class Win32_Processor).Name '' -ForegroundColor Yellow
write-host ' ' 'RAM [' ([int]((Get-WmiObject -Class:Win32_ComputerSystem).TotalPhysicalMemory / 1GB)) '] GB ' -ForegroundColor Yellow
write-host ' ' (get-physicaldisk).mediatype[0] '[' ([int]((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size).Size / 1GB))'] GB' "`n" -ForegroundColor Yellow

if ($Camera.Status -eq "ok") {
	write-host ' ' "Camera OK" -ForegroundColor Yellow
} else {
	write-host ' ' "Camera Not OK" -ForegroundColor Red
}

$UsbCount = 0 
Foreach($element in $Usb) { 
	if ($element.Status -eq "error") {
		$UsbCount = $UsbCount + 1
	}
}

if ($UsbCount -ge 1) {
	write-host ' ' "USB Not OK" -ForegroundColor Red
} else {
	write-host ' ' "USB OK" -ForegroundColor Yellow
}

$DriverCount = 0
Foreach($element in $Driver) { 
	if ($element.Status -eq "error") {
		$DriverCount = $DriverCount + 1
	}
}

if ($DriverCount -ge 1) {
	write-host ' ' "Driver Not OK" -ForegroundColor Red
} else {
	write-host ' ' "Driver OK" -ForegroundColor Yellow
}

if ($StatusDisk -eq "OK"){
	write-host ' ' "Disque" $StatusDisk  -ForegroundColor Yellow
} else {
	write-host ' ' "Disque" $StatusDisk -ForegroundColor Red
}

if ($Temperature -eq 0) {
	if($Temperature2 -ge 55) {
		write-host ' ' "Temperature [" $Temperature2 "]" -ForegroundColor Red
	} else {
		write-host ' ' "Temperature [" $Temperature2 "]" -ForegroundColor Yellow
	}	
} else {
	if($Temperature -ge 55) {
		write-host ' ' "Temperature [" $Temperature "]" -ForegroundColor Red
	} else {
		write-host ' ' "Temperature [" $Temperature "]" -ForegroundColor Yellow
	}	
}

if ($Battery -ge 80) {
	write-host ' ' $Battery "%" -ForegroundColor Yellow	
} else {
	write-host ' ' $Battery "%" -ForegroundColor Red
}

write-host "`n " 'Windows 10' "`n" -ForegroundColor White

if (-not [string]::IsNullOrEmpty($License)) {
	write-host ' ' "License [" $License "] `n" -ForegroundColor Yellow
	cscript c:\Windows\System32\slmgr.vbs -ato
} else {
	write-host ' ' "Pas de Key" -ForegroundColor Red
}

Read-Host -Prompt "`n  "