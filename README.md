# デモを実行

OAuth2認証の実験

## 必要なgemをインストール
```
$ bundle install
```

## テストアカウントを作る

```
$ rails console
> user = User.create!(:username => 'demo')
> client = OAuth::Client.create!(:name => 'demo', :redirect_uri => 'http://localhost:4567/oauth/authorize')
> puts client.identifier, client.secret
> exit
````

## キーを設定

先のコマンドで表示した二つのキーを`demo_client.rb`の`CLIENT_TOKEN`と`CLIENT_SECRET`にコピー


## 実行
ターミナルを二枚開き、それぞれで下記のコマンドを実行する

```
$ bundle exec rails server 
```

```
$ bundle ruby demo_client.rb
```

起動後、`http://localhost:4567/` をブラウザで開き、ユーザ名`demo`でログイン


## デモAPIのソース

- app/controllers/demo_controller.rb



# 既存のプロジェクトへのOAuth2 プロバイダの組み込み方

モデルとクラスを生成した後、このプロジェクトから必要な箇所をコピーする

## Gemfileに下記を追加

```
# OAuth 2.0 Provider
gem "rack-oauth2", "~> 1.0.5"
```

## o_auth/client モデル作成

```
rails g model o_auth/client identifier:string secret:string redirect_uri:text official:boolean name:string
```

### migrationファイルに追加

```
    add_index :o_auth_clients, ["identifier"], :unique => true
    add_index :o_auth_clients, ["name"], :unique => true
```


## o_auth/authorization_code モデル作成

```
rails g model o_auth/authorization_code user_id:integer o_auth_client_id:integer token:string redirect_uri:text expires_at:timestamp
```

### migrationファイルに追加
```
    add_index :o_auth_authorization_codes, ["user_id"]
    add_index :o_auth_authorization_codes, ["token"], :unique => true
    add_index :o_auth_authorization_codes, ["o_auth_client_id"]
```


## o_auth/refresh_token モデル作成

```
rails g model o_auth/refresh_token user_id:integer o_auth_client_id:integer token:string expires_at:timestamp
```

### migrationファイルに追加
```
    add_index :o_auth_refresh_tokens, ["token"], :unique => true
    add_index :o_auth_refresh_tokens, ["expires_at"]
    add_index :o_auth_refresh_tokens, ["o_auth_client_id"]
    add_index :o_auth_refresh_tokens, ["user_id"]
```


## o_auth2/access_token モデル作成

```
rails g model o_auth/access_token user_id:integer o_auth_client_id:integer o_auth_refresh_token_id:integer token:string expires_at:timestamp
```

### migrationファイルに追加

```
    add_index :o_auth_access_tokens, ["token"], :unique => true
    add_index :o_auth_access_tokens, ["user_id"]
    add_index :o_auth_access_tokens, ["o_auth_client_id"]
    add_index :o_auth_access_tokens, ["expires_at"]
```


## 上書きするファイル

- app/models/concerns/o_auth_token.rb
- app/models/o_auth/access_token.rb
- app/models/o_auth/authorization_code.rb
- app/models/o_auth/client.rb
- app/models/o_auth/refresh_token.rb


## 追記するファイル

- config/application.rb の `>>> APPEND >>> 〜 <<< APPEND <<<` をコピー
- app/models/user.rb のassocの部分


## 認証用コントローラを生成

```
rails g controller oauth2
```

## routes.rbを編集
`config/routes.rb`からoauth2の二行を消して下記を追加

```
  namespace :oauth2 do
    get 'authorize'
    get 'sign_in', action: 'new'
    post 'sign_in'
    post 'allow'
    get 'token'
    post 'token'
    get 'redirect'
  end
```

## コントローラとビューファイルを上書き
- app/controllers/oauth2_controller.rb
- app/controllers/concerns/authentication.rb
- app/views/oauth2/authorize.html.erb
- app/views/oauth2/sign_in.html.erb

