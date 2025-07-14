FROM hashicorp/vault:1.13.3

# TLS証明書と設定を配置
COPY ./vault/cert /vault/cert
COPY ./vault/config /vault/config

# vault ユーザーに権限付与
RUN chown -R vault:vault /vault/cert /vault/config && \
    chmod 600 /vault/cert/vault-key.pem && \
    chmod 644 /vault/cert/vault-cert.pem

# CAP_SETFCAP を触らせないように entrypoint を override
ENTRYPOINT ["/bin/sh", "-c", "vault server -config=/vault/config/vault.hcl"]
