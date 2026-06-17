日本語 | [English](README.md)

# カスタム [code-server](https://github.com/coder/code-server) セットアップ

Python、`uv`、Node.js、そして可愛いターミナルプロンプトを搭載した、rootless Docker に対応した完全カスタマイズ版 [`code-server`](https://github.com/coder/code-server) (ブラウザ版 VS Code) 環境です！

> [!IMPORTANT]
> このコンテナ内の code-server サービスは、コンテナ内で **ルート権限 (UID 0)** を持って実行されます。実際の Linux ユーザーアカウントは `coder` という名前ですが、ターミナルで `whoami` を打つと `itomi` と表示されるように、ちょっとしたハックを適用しています！

## 特徴
- **Rootless Docker 対応:** コンテナのユーザーをホストのユーザーに動的にマッピングすることで、煩わしいファイル権限の問題（`sudo` の要求や南京アイコンの表示など）を解決します。
- **事前インストール済みツール:** Python 3、`uv`（超高速 Python パッケージマネージャー）、`jq`、日本語フォント、そして `nvm` を介した最新の "Current" Node.js が含まれています。
- **カスタムターミナル:** git ブランチの統合と、ランダムで表示されるツンデレ・ダジャレのモチベーションメッセージ付きの可愛いパステルカラープロンプトが特徴です。
- **データの永続化:** すべての設定、拡張機能、ツールはローカルのバインドマウントに保存されるため、コンテナの再ビルド後も消えません。

## フォルダ構成
実行すると、ディレクトリ内に以下のフォルダが作成されます:
- `workspace/` - 実際のコーディングプロジェクト用。
- `.config/` - VS Code と code-server の設定用。
- `.local/` - ローカルツールのインストール先およびバイナリ用。
- `.ssh/` - SSH キー用（git で使用）。

## クイックスタート

1. **リポジトリをクローンする:**
   ```bash
   git clone https://github.com/miyumi-aho/custom-code-server
   cd custom-code-server
   ```

2. **必要なフォルダを作成する:**
   *(重要: 事前に作成しておかないと、rootless Docker で権限エラーが発生する可能性があります！)*
   ```bash
   mkdir -p workspace .config .local
   ```

3. **コンテナをビルドして実行する:**
   ```bash
   docker compose up -d --build
   ```

4. **ブラウザで開く:**
   [`http://localhost:8443`](http://localhost:8443) または [`http://127.0.0.1:8443`](http://127.0.0.1:8443) にアクセスしてコーディングを開始しましょう！

## メンテナンスと更新
ツール（Node.js、uv、Python パッケージなど）を最新バージョンやセキュリティパッチに保つには、付属の更新スクリプトを実行するだけです:
```bash
./update.sh
```
これにより、最新のベースイメージがプルされ、コンテナが最新のツールで再ビルドされ、古い Docker キャッシュがクリーンアップされて容量が節約されます！

## 仕組み（権限の魔法!!!!）

> [!NOTE]
> 権限マッピングの参考・インスピレーションとして、以下のリポジトリを使用しました:
> https://github.com/martinussuherman/alpine-code-server

rootless Docker で `code-server` を使ったことがあるなら、ユーザー名前空間のリマッピングによってファイルがランダムな UID（`525287` など）に所有されてしまう痛みに気づいているはずです。

このセットアップでは、`gosu`（`su-exec` に似たもの）を実行するカスタム `entrypoint.sh` スクリプトを使用しています。これはコンテナ内の `coder` ユーザーの UID/GID を `0` (root) に変更します。rootless Docker が UID をマッピングする仕組みにより、コンテナ内の UID `0` はホストの UID（通常は `1000`）に直接マッピングされます。つまり、コンテナ内で作成されたすべてのファイルは、ホストマシン上の実際のユーザーに完全に所有されるのです！

## カスタマイズ
- **ターミナルプロンプト:** `custom.bashrc` を編集して、色、顔文字、またはモチベーションメッセージを変更できます！
- **ツールの追加:** `Dockerfile` の `root` ユーザーセクションにお気に入りの `apt-get` パッケージを追加してください。
- **Node バージョン:** 特定のバージョンに固定したい場合は、`Dockerfile` の `nvm install node` を変更してください（例: `nvm install 26`）。

