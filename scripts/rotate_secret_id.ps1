param(
    [string]$RoleName = "arkstream-db"
)

# Vaultアドレスとtokenを読み込む
$envFile = "..\.env\.env.vault"
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}

# VAULT_ADDRを設定
if ($env:VAULT_MODE -eq "prod") {
    $vaultAddr = $env:VAULT_ADDR_PROD
} elseif ($env:VAULT_MODE -eq "staging") {
    $vaultAddr = $env:VAULT_ADDR_STAGING
} else {
    $vaultAddr = $env:VAULT_ADDR_DEV
}
$env:VAULT_ADDR = $vaultAddr

# ログイン (AppRole)
$roleIdVar = "ARKSTREAM_" + ($RoleName -replace "-", "_").ToUpper() + "_ROLE_ID"
$secretIdVar = "ARKSTREAM_" + ($RoleName -replace "-", "_").ToUpper() + "_SECRET_ID"

$roleId = [System.Environment]::GetEnvironmentVariable($roleIdVar)
$secretId = [System.Environment]::GetEnvironmentVariable($secretIdVar)

Write-Host "🔑 Rotating SecretID for $RoleName..."

# 新しい SecretID 発行
$newSecret = vault write -format=json auth/approle/role/$RoleName/secret-id
$newId = ($newSecret | ConvertFrom-Json).data.secret_id
$newAccessor = ($newSecret | ConvertFrom-Json).data.secret_id_accessor

Write-Host "✅ New SecretID: $newId"
Write-Host "✅ SecretID Accessor: $newAccessor"

# 古い SecretIDを無効化する場合は以下を有効に
# vault write auth/approle/role/$RoleName/secret-id-accessor/destroy secret_id_accessor="$oldAccessor"

# .envファイルを更新する
(Get-Content $envFile) -replace "($secretIdVar)=(.*)", "`$1=$newId" | Set-Content $envFile

Write-Host "✅ .envファイルを更新しました。"

