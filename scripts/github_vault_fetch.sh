jobs:
  build:
    runs-on: ubuntu-latest
    env:
      VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
      VAULT_TOKEN: ${{ secrets.VAULT_GITHUB_CI_TOKEN }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Get Binance credentials from Vault
        run: |
          curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
            $VAULT_ADDR/v1/secret/data/arkstream/binance_test \
          | jq -r '.data.data | to_entries[] | "\(.key)=\(.value)"' >> $GITHUB_ENV
