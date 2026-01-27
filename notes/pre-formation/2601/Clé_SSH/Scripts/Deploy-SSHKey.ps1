#Requires -Version 5.1
<#
.SYNOPSIS
  Deploy an SSH public key to a Linux VM over SSH (Windows PowerShell).

.DESCRIPTION
  - Generates an Ed25519 keypair if missing
  - Pushes the public key to ~/.ssh/authorized_keys on the VM (idempotent)
  - Tests key-based login
  - Optionally writes a Host entry to ~/.ssh/config

.REQUIREMENTS
  - Windows OpenSSH Client installed (ssh, ssh-keygen)
  - Password-based SSH access must work at least once (for initial key copy)

.EXAMPLES
  .\Deploy-SSHKey.ps1 -HostName 127.0.0.1 -Port 2224 -User gloaguen -Alias ubuntuserver -Verbose
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$HostName,

  [Parameter()]
  [ValidateRange(1, 65535)]
  [int]$Port = 22,

  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$User,

  [Parameter()]
  [string]$Alias = "",

  [Parameter()]
  [ValidateNotNullOrEmpty()]
  [string]$KeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Command {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
  )

  if (-not (Get-Command -Name $Name -ErrorAction SilentlyContinue)) {
    throw "Command '$Name' not found. Install 'OpenSSH Client' in Windows Optional Features."
  }
}

function New-SshDirectory {
  [CmdletBinding()]
  param()

  $sshDir = Join-Path -Path $env:USERPROFILE -ChildPath ".ssh"
  if (-not (Test-Path -LiteralPath $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
  }
  return $sshDir
}

function Add-SshConfigHost {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$AliasName,
    [Parameter(Mandatory = $true)][string]$HostNameValue,
    [Parameter(Mandatory = $true)][string]$UserValue,
    [Parameter(Mandatory = $true)][int]$PortValue,
    [Parameter(Mandatory = $true)][string]$IdentityFileValue
  )

  $configDir = New-SshDirectory
  $configFile = Join-Path -Path $configDir -ChildPath "config"

  if (-not (Test-Path -LiteralPath $configFile)) {
    New-Item -ItemType File -Path $configFile | Out-Null
  }

  $existing = Get-Content -LiteralPath $configFile -Raw

  $aliasRegex = "(?m)^\s*Host\s+$([regex]::Escape($AliasName))\s*$"
  if ($existing -match $aliasRegex) {
    Write-Verbose "SSH config alias '$AliasName' already exists in $configFile"
    return
  }

  $block = @"
Host $AliasName
  HostName $HostNameValue
  User $UserValue
  Port $PortValue
  IdentityFile $IdentityFileValue
  IdentitiesOnly yes

"@

  Add-Content -LiteralPath $configFile -Value $block
  Write-Verbose "Added SSH config alias '$AliasName' to $configFile"
}

Assert-Command -Name "ssh"
Assert-Command -Name "ssh-keygen"

$null = New-SshDirectory

# Normalize key paths
$KeyPath = [System.IO.Path]::GetFullPath($KeyPath)
$PubKeyPath = "$KeyPath.pub"

# 1) Ensure local key exists
if (-not (Test-Path -LiteralPath $KeyPath)) {
  Write-Verbose "Local key not found. Generating: $KeyPath"
  & ssh-keygen -t ed25519 -a 64 -f $KeyPath -N "" | Out-Null
}

if (-not (Test-Path -LiteralPath $PubKeyPath)) {
  throw "Public key not found: $PubKeyPath"
}

$pubKey = Get-Content -LiteralPath $PubKeyPath -Raw
if ([string]::IsNullOrWhiteSpace($pubKey)) {
  throw "Public key file is empty: $PubKeyPath"
}

# 2) Push public key (requires password auth at least once)
$remoteCmd = @"
set -eu
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
KEY=\$(cat | tr -d '\r')
grep -qxF "\$KEY" ~/.ssh/authorized_keys || echo "\$KEY" >> ~/.ssh/authorized_keys
"@

Write-Verbose "Pushing public key to ${User}@${HostName}:${Port} ..."
$pubKey |
  & ssh -p $Port `
    -o PreferredAuthentications=password `
    -o PubkeyAuthentication=no `
    -o StrictHostKeyChecking=accept-new `
    "$User@$HostName" `
    "bash -lc '$remoteCmd'"

# 3) Test key-based login (non-interactive)
Write-Verbose "Testing key-based login (BatchMode) ..."
& ssh -p $Port -i $KeyPath -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$User@$HostName" "echo OK" | Out-Null

Write-Information "OK: key-based SSH works." -InformationAction Continue

# 4) Optional: write ~/.ssh/config alias
if (-not [string]::IsNullOrWhiteSpace($Alias)) {
  Add-SshConfigHost -AliasName $Alias -HostNameValue $HostName -UserValue $User -PortValue $Port -IdentityFileValue $KeyPath
}

Write-Information "Done." -InformationAction Continue
