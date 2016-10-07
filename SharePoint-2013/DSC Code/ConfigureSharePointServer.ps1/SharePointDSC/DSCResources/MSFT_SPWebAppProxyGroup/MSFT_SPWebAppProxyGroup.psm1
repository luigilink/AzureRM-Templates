function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  
        [System.String] 
        $WebAppUrl,

        [parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAppProxyGroup,

        [parameter(Mandatory = $false)] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
    
    Write-Verbose -Message "Getting $WebAppUrl Service Proxy Group Association"
    
    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
            
        $WebApp = get-spwebapplication $params.WebAppUrl
        if (!$WebApp) 
        {
             return  @{
                WebAppUrl = $null
                ServiceAppProxyGroup = $null
                InstallAccount       = $InstallAccount
             } 
        }
         
         if ($WebApp.ServiceApplicationProxyGroup.friendlyname -eq "[default]") 
         {
             $ServiceAppProxyGroup = "Default"
         } 
         else 
         {
             $ServiceAppProxyGroup = $WebApp.ServiceApplicationProxyGroup.name
         }
         
         return @{
             WebAppUrl = $params.WebAppUrl
             ServiceAppProxyGroup = $ServiceAppProxyGroup
             InstallAccount       = $InstallAccount
         }
    }
    
    return $result 
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]  
        [System.String] 
        $WebAppUrl,

        [parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAppProxyGroup,

        [parameter(Mandatory = $false)] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
    
    Write-Verbose -Message "Setting $WebAppUrl Service Proxy Group Association"
    
    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]
     
        if ($params.ServiceAppProxyGroup -eq "Default") 
        {
                $params.ServiceAppProxyGroup = "[default]"
        }
        
        Set-SPWebApplication -Identity $params.WebAppUrl `
                             -ServiceApplicationProxyGroup $params.ServiceAppProxyGroup
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]  
        [System.String] 
        $WebAppUrl,

        [parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAppProxyGroup,

        [parameter(Mandatory = $false)] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )
    
    Write-Verbose -Message "Testing $WebAppUrl Service Proxy Group Association"
    
    $CurrentValues = Get-TargetResource @PSBoundParameters
    
    if (($null -eq $CurrentValues.WebAppUrl) -or ($null -eq $CurrentValues.ServiceAppProxyGroup)) 
    { 
        return $false 
    }
    
    if ($CurrentValues.ServiceAppProxyGroup -eq $ServiceAppProxyGroup) 
    {
        return $true 
    } 
    else 
    {
        return $false 
    }
}
