# Load log4net assembly
#Add-Type -Path "D:\tools\log4net\log4netbin\log4net.dll"

[Reflection.Assembly]::LoadFrom(".\log4net\log4net.dll") |  Out-Null

# Get the folder path of the PowerShell script
$scriptFolderPath = $PSScriptRoot
$LogDir = "$scriptFolderPath\logs"
[log4net.GlobalContext]::Properties.Item("LogDir") = $LogDir;


Write-Verbose "[New-Logger] Log4net dll path is : '$log4netDllPath'"
# Log4net configuration loading
$log4netConfigFilePath = Resolve-Path "$scriptFolderPath\log4net-config.xml" -ErrorAction SilentlyContinue -ErrorVariable Err
if ($Err){
	throw "Log4Net configuration file $Configuration cannot be found"
}
else{
    Write-Verbose "[New-Logger] Log4net configuration file is '$log4netConfigFilePath' "
    $FileInfo = New-Object System.IO.FileInfo($log4netConfigFilePath)
    [log4net.Config.XmlConfigurator]::Configure($FileInfo)
    $logger = [log4net.LogManager]::GetLogger("root")
    Write-Verbose "[New-Logger] Logger is configured"
}

# Log messages of various levels
$logger.Debug("This is a DEBUG message.")
$logger.Info("This is an INFO message.")
$logger.Warn("This is a WARN message.")
$logger.Error("This is an ERROR message.")
$logger.Fatal("This is a FATAL message.")
