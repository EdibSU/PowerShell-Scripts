<#
.SYNOPSIS
Disables a list of network adapters, based on name.

.DESCRIPTION
Disables a list of network adapters, based on name. By default disables only the Hyper-V Default Switch. 

.PARAMETER names
List of names of the network adapters to disable.

.EXAMPLE
DisableNetAdapter
DisableNetAdapter(["{adapter name 1}", "{adapter name 2}"])

.NOTES
If you would like to avoid having to type the names of the network adapters to disable, or you would like to use StartDM function,
you need to set default value to name(s) of adapters you need disabled in order to start DataMiner.
#>
function DisableNetAdapters {
    param (
        [string[]]$names = @("vEthernet (Default Switch)")
    )

    foreach ($name in $names) {
        Get-NetAdapter -Name $name | Disable-NetAdapter -Confirm:$false
    }
}

<#
.SYNOPSIS
Enables a list of network adapters, based on name.

.DESCRIPTION
Enables a list of network adapters, based on name. By default enables only the Hyper-V Default Switch.
After starting up DataMiner you can use this function to reenable the disabled adapters.

.PARAMETER names
List of names of the network adapters to enable.

.EXAMPLE
EnableNetAdapter
EnableNetAdapter(["{adapter name 1}", "{adapter name 2}"])

.NOTES
If you would like to avoid having to type the names of the network adapters to enable, you need to set default 
value to name(s) of adapters you need enabled. Generally, you would call this function with same parameters as DisableNetAdapter 
#>
function EnableNetAdapters {
    param (
        [string[]]$names = @("vEthernet (Default Switch)")
    )

    foreach ($name in $names) {
        Get-NetAdapter -Name $name | Enable-NetAdapter -Confirm:$false
    }
}

<#
.SYNOPSIS
Restarts DataMiner agent.

.DESCRIPTION
Restarts DataMiner agent. 
Function calls these functions and in this order: 
    - first calls DisableNetAdapter with default parameter to avoid licensing issues.
    - second Remove-DMANodes with default parameter in order to remove any preexisting IPs in DMS.xml
    - third Remove-NATSServerNodes with default parameter in order to remove any preexisting IPs in SLCloud.xml
    - forth "DataMiner Restart DataMiner And SLNet.bat" from C:\Skyline DataMiner\Tools

.EXAMPLE
RestartDM
#>
function RestartDM {
    DisableNetAdapters
    Remove-DMANodes
    Remove-NATSServerNodes
    Invoke-Item "C:\Skyline DataMiner\Tools\DataMiner Restart DataMiner And SLNet.bat"
}

<#
.SYNOPSIS
Starts DataMiner agent.

.DESCRIPTION
Starts DataMiner agent. 
Function calls these functions and in this order: 
    - first calls DisableNetAdapter with default parameter to avoid licensing issues.
    - second Remove-DMANodes with default parameter in order to remove any preexisting IPs in DMS.xml
    - third Remove-NATSServerNodes with default parameter in order to remove any preexisting IPs in SLCloud.xml
    - forth "DataMiner Start DataMiner And SLNet.bat" from C:\Skyline DataMiner\Tools

.EXAMPLE
StartDM
#>
function StartDM {
    DisableNetAdapters
    Remove-DMANodes
    Remove-NATSServerNodes
    Invoke-Item "C:\Skyline DataMiner\Tools\DataMiner Start DataMiner And SLNet.bat"
}

<#
.SYNOPSIS
Stops DataMiner agent.

.DESCRIPTION
Stops DataMiner agent by calling "DataMiner Stop DataMiner And SLNet.bat" from C:\Skyline DataMiner\Tools.

.EXAMPLE
StopDM
#>
function StopDM {
    Invoke-Item "C:\Skyline DataMiner\Tools\DataMiner Stop DataMiner And SLNet.bat"
}

<#
.SYNOPSIS
Starts QA Device Simulator

.DESCRIPTION
Starts QA Device Simulator by calling "QADeviceSimulator.exe" from C:\Skyline DataMiner\Tools\QADeviceSimulator.

.EXAMPLE
QADeviceSimulation
#>
function QADeviceSimulation {
    Invoke-Item "C:\Skyline DataMiner\Tools\QADeviceSimulator\QADeviceSimulator.exe"
}

<#
.SYNOPSIS
Removes all of the existing DMA nodes from DMS.xml.

.DESCRIPTION
Removes all of the existing DMA nodes from DMS.xml and in turn removes all configured IPs.

.PARAMETER path
Path to the DMS.xml file. By default uses C:\Skyline DataMiner\DMS.xml.

.EXAMPLE
Remove-DMANodes
Remove-DMANodes("{path to DMS.xml}")

.NOTES
This function is primarily used by StartDM and RestartDM.
#>
function Remove-DMANodes {
    param (
        [string]$path = "C:\Skyline DataMiner\DMS.xml"
    )

    # Load the XML file
    $xml = New-Object System.Xml.XmlDocument
    $xml.Load($path) | Out-Null

    # Define the namespace manager
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $namespaceManager.AddNamespace("dms", "http://www.skyline.be/config/dms")
    
    # Find and remove the DMA node
    $dmaNodes = $xml.SelectNodes("//dms:DMA", $namespaceManager)
    foreach ($node in $dmaNodes) {
        $node.ParentNode.RemoveChild($node) | Out-Null
    }

    # Save the modified XML back to the file or to a new file
    $xml.Save($path) | Out-Null
}

<#
.SYNOPSIS
Removes all of the existing NATSServerNode nodes from SLCloud.xml.

.DESCRIPTION
Removes all of the existing NATSServerNode nodes from SLCloud.xml and in turn removes all configured IPs.

.PARAMETER path
Path to the SLCloud.xml file. By default uses C:\Skyline DataMiner\SLCloud.xml.

.EXAMPLE
Remove-NATSServerNodes
Remove-NATSServerNodes("{path to SLCloud.xml}")

.NOTES
This function is primarily used by StartDM and RestartDM.
#>
function Remove-NATSServerNodes {
    param (
        [string]$path = "C:\Skyline DataMiner\SLCloud.xml"
    )

    # Load the XML file
    $xml = New-Object System.Xml.XmlDocument
    $xml.Load($path) | Out-Null

    # Find and remove all NATSServer nodes
    $natsserverNodes = $xml.SelectNodes("//NATSServer")
    foreach ($node in $natsserverNodes) {
        $node.ParentNode.RemoveChild($node) | Out-Null
    }

    # Save the modified XML back to the file or to a new file
    $xml.Save($path) | Out-Null
}

<#
.SYNOPSIS
Signs list of scripts using the provided certificate.

.DESCRIPTION
Signs list of DM scripts with provided certificate. By default signs Failover-ARR-EnableProxy.ps1 and Failover-ARR-ClearInboundRule.ps1.

.PARAMETER CertSubject
Name of the certificate to be used for signing. Looks for certificate in Cert:\localmachine\my.

.PARAMETER scripts
List of paths to scripts to be signed.

.EXAMPLE
SignDMScripts("{cert name}")

.NOTES
This function is used to sign DM scripts that need to be signed after update, namely Filover-ARR-EnableProxy.ps1 and Failover-ARR-ClearInboundRule.ps1.
You need to have valid Code Signing certificate available to use.
#>
function SignDMScripts {
    [CmdletBinding()]
    Param (
        [string]$CertSubject,
        [string[]]$scripts = @("C:\Skyline DataMiner\Tools\Failover-ARR-EnableProxy.ps1", "C:\Skyline DataMiner\Tools\Failover-ARR-ClearInboundRule.ps1")
    )

    try {
        # Open the LocalMachine My certificate store
        $certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "LocalMachine")
        $certStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

        # Find the certificate by subject name
        $cert = $certStore.Certificates | Where-Object { $_.Subject -like "*$CertSubject*" } | Select-Object -First 1

        if ($null -ne $cert) {
            # Sign the script
            foreach ($script in $scripts) {
                $signingResult = Set-AuthenticodeSignature -FilePath $script -Certificate $cert

                if ($signingResult.Status -ne "Valid") {
                    Write-Output "Failed to sign the script. Status: $($signingResult.Status)"
                }
                else {
                    Write-Output "Script signed successfully. Status: $($signingResult.Status)"
                }
            }
        } else {
            Write-Output "Certificate with subject name containing '$CertSubject' not found."
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
    finally {
        # Close the certificate store
        if ($null -ne $certStore) {
            $certStore.Close()
        }
    }
}