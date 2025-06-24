use reqwest::Client;
use serde::Deserialize;
use std::collections::HashMap;

#[derive(Deserialize, Debug)]
struct VaultSecretResponse {
    data: VaultData,
}

#[derive(Deserialize, Debug)]
struct VaultData {
    data: HashMap<String, String>,
}

#[tokio::test]
async fn test_vault_secret_fetch() {
    let vault_addr = std::env::var("VAULT_ADDR").expect("VAULT_ADDR not set");
    let vault_token = std::env::var("VAULT_TOKEN").expect("VAULT_TOKEN not set");

    let url = format!("{}/v1/secret/data/arkstream/binance_test", vault_addr);

    let client = Client::new();
    let res = client.get(&url).header("X-Vault-Token", vault_token).send().await.unwrap();
    assert!(res.status().is_success(), "Vault request failed");

    let secret: VaultSecretResponse = res.json().await.unwrap();
    println!("✅ Vault シークレット取得成功: {:#?}", secret.data.data);
}
