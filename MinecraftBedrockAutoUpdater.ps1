param(
    $BackupServerFolderPath = "C:\Minecraft\VersionBackup\",

    $LiveServerFolderLocation = "C:\Minecraft\Server",

    $FilesToExclude = @(
        "permissions.json",
        "server.properties",
        "whitelist.json"
    ),

    $ExeName = "Bedrock_Server.exe"
)

function Get-NewMinecraftServerVersionUrl {
    param(
        $DownloadUrl = "https://www.minecraft.net/en-us/download/server/bedrock/"
    )

    return ((Invoke-WebRequest $DownloadUrl).links | Where-Object -FilterScript { $_."data-platform" -eq 'serverBedrockWindows' }).href
}

function Get-MinecraftVersionChangeValidation {
    param(
        $NewMinecraftServerVersionUrl
    )
    $currentVersions = (Get-ChildItem $BackupServerFolderPath).Name
    $newVersionNumber = $NewMinecraftServerVersionUrl.Split("/")[-1] -replace (".zip", "")

    return $currentVersions -contains $newVersionNumber
}

function Get-MinecraftZipFromUrl {
    param(
        $DownloadUrl,
        $ZipFolderName = $DownloadUrl.Split("/")[-1]
    )

    Invoke-WebRequest -Uri $DownloadUrl -OutFile ($BackupServerFolderPath + $ZipFolderName)
    return $ZipFolderName
}

function Set-MinecraftFilesForDeployment {
    param(
        $ZippedFolderName
    )
    Expand-Archive -Path ($BackupServerFolderPath + $ZippedFolderName) -DestinationPath ($BackupServerFolderPath + ($ZippedFolderName -replace (".zip", ""))) -Force
    Remove-Item ($BackupServerFolderPath + $ZippedFolderName) -Force

    return $ZippedFolderName -replace (".zip", "")
}

function Get-ServerExection {
    Param(
        [CmdletBinding(DefaultParametersetName = 'Start')]
        
        [Parameter(ParameterSetName = 'Start', Mandatory = $true)]
        [switch]
        $Start,

        [Parameter(ParameterSetName = 'Stop', Mandatory = $true)]
        [switch]
        $Stop
    )

    if ($Start) {
        Start-Process ("$LiveServerFolderLocation" + "\" + "$ExeName") -WindowStyle Hidden
    }
    if ($Stop) {
        Stop-Process -Name ($ExeName -replace (".exe", ""))
    }
    
    Start-Sleep -Seconds 3

    if (Get-Process ($ExeName -replace (".exe", "")) -ErrorAction Ignore) {
        Write-Verbose "$($ExeName -replace ('.exe', '')) Service Is Running" -Verbose
    }
    else {
        Write-Verbose "$($ExeName -replace ('.exe', '')) Service Is Stoppped" -Verbose
    }
}

function Copy-ServerPackages {
    param(
        $StagedFolderName
    )
    $FilesToCopy = New-Object System.Collections.ArrayList
    foreach ($item in $(Get-ChildItem ($BackupServerFolderPath + $StagedFolderName))) {
        if ($FilesToExclude -notcontains $item.Name) {
            $FilesToCopy.Add($item) | Out-Null
        }
    }
    
    foreach ($item in $FilesToCopy) {
        Copy-Item $item.FullName -Destination $LiveServerFolderLocation -Recurse -Force -Verbose
    }    
}

function Main {
    $serverVersionUrl = Get-NewMinecraftServerVersionUrl
    if (Get-MinecraftVersionChangeValidation $serverVersionUrl) {
        Write-Verbose "Current Version Is Up To Date" -Verbose
        Write-Verbose "Exiting" -Verbose
        return
    }
    else {
        $zipFolderName = Get-MinecraftZipFromUrl -DownloadUrl $serverVersionUrl
        $stagingFolder = Set-MinecraftFilesForDeployment -ZippedFolderName $zipFolderName
        Get-ServerExection -Stop
        Copy-ServerPackages -StagedFolderName $stagingFolder
        Get-ServerExection -Start
    }    
}

Main