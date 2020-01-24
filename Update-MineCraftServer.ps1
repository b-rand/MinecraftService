param(
    [Parameter(Mandatory=$true)]
    [string]
    $NewServerFolderName,

    $BackupServerFolderPath = "C:\Minecraft\VersionBackup\",

    $LiveServerFolderLocation = "C:\Minecraft\Server",

    $FilesToExclude = @(
        "permissions.json",
        "server.properties",
        "whitelist.json"
    ),

    $ExeName = "Bedrock_Server.exe"
)

function Get-FolderValidation{
    if(!(Test-Path $($BackupServerFolderPath+$NewServerFolderName))){
        Write-Error 'New Server Folder Does Not Exist at "'+"($BackupServerFolderPath+$NewServerFolderName)"+'"'
        Exit
    }
}

function Get-ServerExection{
    Param(
        [CmdletBinding(DefaultParametersetName='Start')]
        
        [Parameter(ParameterSetName='Start',Mandatory=$true)]
        [switch]
        $Start,

        [Parameter(ParameterSetName='Stop',Mandatory=$true)]
        [switch]
        $Stop
    )

    if($Start){
        Start-Process ("$LiveServerFolderLocation"+"\"+"$ExeName") -WindowStyle Hidden
    }
    if($Stop){
        Stop-Process -Name ($ExeName -replace (".exe",""))
    }

}

function Copy-ServerPackages{
    $FilesToCopy = New-Object System.Collections.ArrayList
    foreach($item in $(Get-ChildItem $($BackupServerFolderPath+$NewServerFolderName))){
        if ($FilesToExclude -notcontains $item.Name){
            $FilesToCopy.Add($item) | Out-Null
        }
    }
    
    foreach($item in $FilesToCopy){
        Copy-Item $item.FullName -Destination $LiveServerFolderLocation -Recurse -Force -Verbose
    }    
}

function Main{
    Get-FolderValidation
    Get-ServerExection -Stop
    Copy-ServerPackages
    Get-ServerExection -Start    
}

Main