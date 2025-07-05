// vault/tests/vault_test
use reqwest::Client;
use serde::Deserialize;

#[derive(Deserialize, Debug)]
struct VaultSecretResponse {
    data: VaultData,
}

#[derive(Deserialize, Debug)]
struct VaultData {
    data: std::collections::HashMap<String, String>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let vault_addr =
        std::env::var("VAULT_ADDR").unwrap_or_else(|_| "http://127.0.0.1:8200".to_string());
    let vault_token = std::env::var("VAULT_TOKEN").unwrap_or_else(|_| "root".to_string());

    let url = format!("{}/v1/secret/data/arkstream/binance_test", vault_addr);

    let client = Client::new();
    let res = client.get(&url).header("X-Vault-Token", vault_token).send().await?;

    if !res.status().is_success() {
        eprintln!("❌ Vault API エラー: {}", res.status());
        return Ok(());
    }

    let secret: VaultSecretResponse = res.json().await?;
    println!("✅ Vault シークレット取得成功");
    for (k, v) in &secret.data.data {
        println!("🔑 {} = {}", k, v);
    }

    Ok(())
}
