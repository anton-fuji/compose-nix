# compose-nix

```markdowon
compose-nix/
├── flake.nix                   # エントリポイント
├── flake.lock
├── devenv.nix                  # devenv 設定（ローカル開発）
├── devenv.yaml
├── .envrc                      # direnv 連携
├── .sops.yaml                  # sops 鍵設定
├── .gitignore
│
├── nix/
│   ├── environments.nix        # dev/stg/prod 環境変数
│   ├── lib.nix                 # 共通ヘルパー
│   │
│   ├── images/
│   │   ├── app.nix             # buildLayeredImage でアプリイメージ
│   │   └── migrator.nix        # goose + migration ファイル
│   │
│   └── scripts/
│       ├── dev-up.nix          # ローカル起動スクリプト
│       ├── dev-down.nix        # クリーンアップ
│       └── migrate.nix         # マイグレーション実行
│
├── secrets/
│   ├── dev.env                 # 平文（gitignore 対象）
│   ├── stg.encrypted.json      # sops 暗号化
│   └── prod.encrypted.json
│
├── src/                        # Go アプリケーション
│   ├── go.mod
│   ├── go.sum
│   ├── cmd/
│   │   └── api/
│   │       └── main.go
│   ├── internal/
│   ├── db/
│   │   └── migrations/
│   └── api/
│       └── openapi.yaml
│
└── sql/
    ├── queries/                # sqlc 用
    └── schema/                 # goose 用
```


