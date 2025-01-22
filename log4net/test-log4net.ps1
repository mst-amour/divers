param (
    [string]$xmlPath,
    [string]$xsltPath,
    [string]$outputPath
)

# Get the full path of the PowerShell script
$scriptPath = $MyInvocation.MyCommand.Path

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

# Log command-line parameters
$logger.info("Script '$scriptPath' started with parameters ")
$logger.Info("xmlPath: $xmlPath")
$logger.Info("xsltPath: $xsltPath")
$logger.Info("outputPath: $outputPath")

# Check if parameters are provided
if (-not $xmlPath) {
    $logger.error("Error: xmlPath parameter is missing or empty.")
	$logger.info("Script execution failed")
    exit 1
}

if (-not $xsltPath) {
    $logger.error("Error: xsltPath parameter is missing or empty.")
	$logger.info("Script execution failed")
    exit 1
}

if (-not $outputPath) {
	$logger.info("Script execution failed")
    exit 1
}

# Check if the provided paths exist
if (-not (Test-Path $xmlPath)) {
    $logger.error("Error: Input XML file '$xmlPath' not found.")
	$logger.info("Script execution failed")
    exit 1
}

if (-not (Test-Path $xsltPath)) {
    $logger.error("Error: XSLT transformation file '$xsltPath' not found.")
	$logger.info("Script execution failed")
    exit 1
}

try {

	# Load the XML document
	$logger.info("Loading XML file '$xmlPath'...")
	
	$xmlDoc = New-Object System.Xml.XmlDocument
	$xmlDoc.Load($xmlPath)

	# Load the XSLT document
	$logger.info("Loading XLST file '$xsltPath'...")
	$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
	$xslt.Load($xsltPath)

	# Configure XmlWriterSettings for pretty-indented formatting
	$xmlWriterSettings = New-Object System.Xml.XmlWriterSettings
	$xmlWriterSettings.Indent = $true
	$xmlWriterSettings.IndentChars = "  " # Use two spaces for indentation
	$xmlWriterSettings.NewLineOnAttributes = $false

	# Perform the transformation and save the output
	$output = New-Object System.IO.StringWriter
	$xmlWriter = [System.Xml.XmlWriter]::Create($output, $xmlWriterSettings)

	$logger.info("Transforming XML with XSLT...")
	$xslt.Transform($xmlDoc, $xmlWriter)
	$xmlWriter.Close()

	# Save the transformed XML to a file
	$logger.info("Writing output file to '$outputPath'...")
	$output.ToString() | Out-File -Encoding utf8 $outputPath

	$logger.info("Transformation completed. Output saved to $outputPath")

}
catch {
    $errorMessage = $_.Exception.Message
    $logger.Error("Error during XSLT transformation: $errorMessage")
	Write-Error $_.Exception.StackTrace
    exit 1  # Exit with non-zero code to indicate failure
}

$logger.info("Ending script")
