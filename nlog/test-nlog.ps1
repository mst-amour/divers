# Load the NLog assembly (assuming NLog.dll is available in the current directory)
[Reflection.Assembly]::LoadFile(".\nlog.5.3.4\lib\net46\nlog.dll") # | Out-Null

# Load NLog configuration file
$configFilePath = Join-Path -Path $PSScriptRoot -ChildPath "nlog-config.xml"
[NLog.LogManager]::LoadConfiguration($configFilePath)

# Create a logger instance
$logger = [NLog.LogManager]::GetLogger("testLogger")

# Sample logging statements
$logger.Debug("This is a Debug message, should appear in the console only.")
$logger.Info("This is an Info message, should appear in info.log and console.")
$logger.Warn("This is a Warning message, should appear in console only.")
$logger.Error("This is an Error message, should appear in error.log, info.log, and console.")
$logger.Fatal("This is a Fatal error message, should appear in error.log, info.log, and console.")

# End NLog session (optional for testing purposes)
[NLog.LogManager]::Shutdown()
