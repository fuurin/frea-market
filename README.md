# frea-market

ユーザが商品を出品し、ユーザ同士でポイントを介して商品を売買することができるAPIです。  
Ruby on Railsで実装されており、ローカル環境ではDocker上で動作させます。

## 導入
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)などを導入し、Dockerをコマンドライン上で利用できるようにしておきます。
- 本リポジトリをクローンし、プロジェクトディレクトリに入ります。
- `.env.sample`を複製し、`.env`という名前にします。必要であれば、.envの中の環境変数の内容を編集します。
- リポジトリ管理者より、起動に必要なmaster.keyの内容を受け取り、`api/config/master.key` へ配置します
- `make init` を実行し、「`Listening on tcp://0.0.0.0:3000`」とコマンドライン上に表示されるまで5~10分ほど待ちます。
- http://localhost:3000/v1/hello にアクセスし、`{ message: 'Hello' }` というメッセージが返ってきたら起動成功です。
- `Ctrl + C`で停止します。`docker-compose up`で再び起動することができます。

### API仕様書
`docker-compose up`している状態で http://localhost:3001 へアクセスすることで、Open APIによるAPI仕様書を確認できます。  
[rspec-openapi](https://github.com/k0kubun/rspec-openapi)によって、rspecのテスト実行時にopenapi.ymlを作成・更新することができます。  
`make gs`でrequests specを実行してAPI仕様書を作り直すことができます。  
(現状、自動では同じステータスコードのAPI仕様に複数のspecを自動で反映する方法は見当たりませんでした...全てのspecを確認したい場合は実際のテストコードを御覧ください。)

## 使い方
基本的に`curl`コマンドを使って説明しますが、適宜[Advanced REST client](https://chrome.google.com/webstore/detail/advanced-rest-client/hgmloofddffdnphfgcellkdfbfbjeloo?hl=ja)のようなHTTPクライアントを利用すると便利です。

### ユーザ登録とログイン
ユーザ登録を行うには、name, email, password, password_confirmationをパラメータに渡して以下のようなリクエストを送信します。  
``` bash
curl localhost:3000/v1/auth \
      -X POST \
      -H "content-type:application/json" \
      -d '{"name":"example", "email":"example@example.com", "password":"password", "password_confirmation": "password"}' 

{
	"status": "success",
	"data": {
		"id": 4,
		"provider": "email",
		"uid": "example@example.com",
		"allow_password_change": false,
		"name": "example",
		"email": "example@example.com",
		"point": 10000,
		"created_at": "2022-04-16T07:30:09.035+09:00",
		"updated_at": "2022-04-16T07:30:09.120+09:00"
	}
}
```
登録時に、商品の購入に使える10,000ポイントが付与されています。  
  
ログインを行うには、先程設定したemailとpasswordをパラメータに渡して以下のようなリクエストを送信します。
``` bash
curl localhost:3000/v1/auth/sign_in \
      -X POST \
      -H "content-type:application/json" \
      -d '{"email":"example@example.com", "password":"password"}' \
      -i

HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
access-token: 5OHoYc-SBS8bo55dAwHw7g
token-type: Bearer
client: LaDjbrAxvz-ZFF7IVvta8g
expiry: 1651271965
uid: example@example.com
ETag: W/"1a0bc7311331210a9533b000f7d79768"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 64b40947-e4f6-4729-adc2-f6d301e588b3
X-Runtime: 0.386007
Vary: Origin
Transfer-Encoding: chunked

{
	"data": {
		"id": 4,
		"email": "example@example.com",
		"provider": "email",
		"name": "example",
		"point": 10000,
		"uid": "example@example.com",
		"allow_password_change": false
	}
}
```
レスポンスヘッダーの中で、`access-token` `client` `uid` をリクエストヘッダーにそのまま設定することで、そのリクエストは今ログインしたユーザがログイン中であるとみなされます。
``` bash
curl localhost:3000/v1/hello/1 \
      -H "content-type:application/json" \
      -H "access-token:5OHoYc-SBS8bo55dAwHw7g" \
      -H "client:LaDjbrAxvz-ZFF7IVvta8g" \
      -H "uid:example@example.com"

{
  "message": "Hello example"
}
```
ログインが必要なページにアクセスし、ログイン中ユーザのexampleという名前に対して Hello example というメッセージが返ってきています。  
(以降はログイン判定用のヘッダーには動作確認時のトークンを入れるため、ご自身の環境で取得したものに適宜読み替えてください。)

### 商品の管理
商品の作成には、商品名(name), 商品説明(description 任意), 商品価格(point) をボディパラメータに渡します。
``` bash
curl localhost:3000/v1/items \
      -X POST \
      -H "content-type:application/json" \
      -H "access-token:5OHoYc-SBS8bo55dAwHw7g" \
      -H "client:LaDjbrAxvz-ZFF7IVvta8g" \
      -H "uid:example@example.com" \
      -d '{ "name": "example item", "description": "example description", "point": 100 }'

{
	"id": 10,
	"user_id": 4,
	"name": "example item",
	"description": "example description",
	"point": 100,
	"created_at": "2022-04-16T07:46:03.271+09:00",
	"updated_at": "2022-04-16T07:46:03.271+09:00"
}
```
商品は作成した時点で即購入可能になるのでご注意ください。  

商品情報は変更することができます。  
``` bash
curl localhost:3000/v1/items/10 \
      -X PATCH \
      -H "content-type:application/json" \
      -H "access-token:5OHoYc-SBS8bo55dAwHw7g" \
      -H "client:LaDjbrAxvz-ZFF7IVvta8g" \
      -H "uid:example@example.com" \
      -d '{ "name": "my example item", "point": 150 }'

{
	"id": 10,
	"name": "my example item",
	"point": 150,
	"user_id": 4,
	"description": "example description",
	"created_at": "2022-04-16T07:46:03.271+09:00",
	"updated_at": "2022-04-16T07:48:30.087+09:00"
}
```

出品されている商品の情報を確認できます。これはログインしていなくてもアクセス可能です。
``` bash
curl localhost:3000/v1/items/10 \
      -H "content-type:application/json"

{
	"id": 10,
	"user_id": 4,
	"name": "my example item",
	"description": "example description",
	"point": 150,
	"created_at": "2022-04-16T07:46:03.271+09:00",
	"updated_at": "2022-04-16T07:48:30.087+09:00"
}
```

ログイン中ユーザの商品一覧を確認できます。
``` bash
curl localhost:3000/v1/items \
      -H "content-type:application/json" \
      -H "access-token:5OHoYc-SBS8bo55dAwHw7g" \
      -H "client:LaDjbrAxvz-ZFF7IVvta8g" \
      -H "uid:example@example.com"

[
	{
		"id": 10,
		"user_id": 4,
		"name": "my example item",
		"description": "example description",
		"point": 150,
		"created_at": "2022-04-16T07:46:03.271+09:00",
		"updated_at": "2022-04-16T07:48:30.087+09:00"
	}
]
```

出品中の商品を削除できます。
``` bash
curl localhost:3000/v1/items/10 \
      -X DELETE \
      -H "content-type:application/json" \
      -H "access-token:5OHoYc-SBS8bo55dAwHw7g" \
      -H "client:LaDjbrAxvz-ZFF7IVvta8g" \
      -H "uid:example@example.com"

curl localhost:3000/v1/items \
      -H "content-type:application/json" \
      -H "access-token:5OHoYc-SBS8bo55dAwHw7g" \
      -H "client:LaDjbrAxvz-ZFF7IVvta8g" \
      -H "uid:example@example.com"

[]
```

現在出品中の全商品の情報を出品された順に取得できます。ログイン中は、自分の商品を結果に含みません。  
一度に最大20件を取得することができ、それ以降は`page`に2以上のパラメータを設置することで次の20件を取得していくことができます。
``` bash
curl localhost:3000/v1/market \
      -H "content-type:application/json"

[
	{
		"id": 9,
		"user_id": 3,
		"name": "item_9",
		"description": "description_9",
		"point": 1,
		"created_at": "2022-04-16T05:35:33.181+09:00",
		"updated_at": "2022-04-16T05:35:33.181+09:00"
	},
  # ...
]
```

### 商品の購入
新しいユーザを作成し、商品の売買を行いましょう。
まずはユーザと商品を作成します。
``` bash
curl localhost:3000/v1/auth \
      -X POST \
      -H "content-type:application/json"
      -d '{"name":"seller", "email":"seller@example.com", "password":"password", "password_confirmation": "password"}' 

curl localhost:3000/v1/auth/sign_in \
      -H "content-type:application/json" \
      -X POST -d '{"email":"seller@example.com", "password":"password"}' \
      -i

curl localhost:3000/v1/items \
      -X POST \
      -H "content-type:application/json" \
      -H "access-token:DHJrnpla5eau_b77J5WjHg" \
      -H "client:X-L0Ywf-K4E6dpgxc4Gf_g" \
      -H "uid:seller@example.com" \
      -d '{ "name": "example item", "description": "example description", "point": 100 }'

{
	"id": 11,
	"user_id": 5,
	"name": "example item",
	"description": "example description",
	"point": 100,
	"created_at": "2022-04-16T08:02:49.803+09:00",
	"updated_at": "2022-04-16T08:02:49.803+09:00"
}
```

最初に作成したユーザでログインし直し、商品を購入します。  
(ログイン中のユーザ自身の商品を購入することはできません)
``` bash
curl localhost:3000/v1/auth/sign_in \
      -X POST \
      -H "content-type:application/json" \
      -d '{"email":"example@example.com", "password":"password"}' \
      -i

curl localhost:3000/v1/market/buy/11 \
      -X POST \
      -H "content-type:application/json" \
      -H "access-token:e_h5nkefXu4RxVMChvKLiQ" \
      -H "client:Q6TpmBk9gH9t1H8kskPC3Q" \
      -H "uid:example@example.com"

{
	"id": 1,
	"buyer_id": 4,
	"buyer_name": "example",
	"buyer_email": "example@example.com",
	"buyer_point_to": 9900,
	"seller_id": 5,
	"seller_name": "seller",
	"seller_email": "seller@example.com",
	"seller_point_to": 10100,
	"item_id": 11,
	"item_name": "example item",
	"item_description": "example description",
	"item_point": 100,
	"created_at": "2022-04-16T08:10:17.682+09:00",
	"updated_at": "2022-04-16T08:10:17.682+09:00"
}
```

商品を購入したユーザのポイント残高が少なくなったことが分かります
``` bash
curl localhost:3000/v1/auth/user \
      -H "content-type:application/json" \
      -H "access-token:e_h5nkefXu4RxVMChvKLiQ" \
      -H "client:Q6TpmBk9gH9t1H8kskPC3Q" \
      -H "uid:example@example.com"

{
	"id": 4,
	"provider": "email",
	"uid": "example@example.com",
	"allow_password_change": false,
	"name": "example",
	"email": "example@example.com",
	"point": 9900,
	"created_at": "2022-04-16T07:30:09.035+09:00",
	"updated_at": "2022-04-16T08:09:04.248+09:00"
}
```

ログイン中のユーザが購入した商品の履歴を確認することができます。20件ずつのページングになっています。
``` bash
curl localhost:3000/v1/market/buy_histories \
      -H "content-type:application/json" \
      -H "access-token:e_h5nkefXu4RxVMChvKLiQ" \
      -H "client:Q6TpmBk9gH9t1H8kskPC3Q" \
      -H "uid:example@example.com"

[
	{
		"id": 1,
		"buyer_id": 4,
		"buyer_name": "example",
		"buyer_email": "example@example.com",
		"buyer_point_to": 9900,
		"seller_id": 5,
		"seller_name": "seller",
		"seller_email": "seller@example.com",
		"seller_point_to": 10100,
		"item_id": 11,
		"item_name": "example item",
		"item_description": "example description",
		"item_point": 100,
		"created_at": "2022-04-16T08:10:17.682+09:00",
		"updated_at": "2022-04-16T08:10:17.682+09:00"
	}
]
```

商品を販売したユーザのポイント残高が多くなったことが分かります。
``` bash
curl localhost:3000/v1/auth/user \
      -H "content-type:application/json" \
      -H "access-token:m2dur4iunp1XOqySaaaXnw" \
      -H "client:-TCTVBj1Luijwew_jMUdIg" \
      -H "uid:seller@example.com"

{
	"id": 5,
	"provider": "email",
	"uid": "seller@example.com",
	"allow_password_change": false,
	"name": "seller",
	"email": "seller@example.com",
	"point": 10100,
	"created_at": "2022-04-16T08:01:13.479+09:00",
	"updated_at": "2022-04-16T08:16:59.828+09:00"
}
```

ログイン中のユーザが販売した商品の履歴を確認することができます。20件ずつのページングになっています。
``` bash
curl localhost:3000/v1/auth/sign_in \
      -X POST \
      -d '{"email":"seller@example.com", "password":"password"}' \
      -H "content-type:application/json" \
      -i

curl localhost:3000/v1/market/sell_histories \
      -H "content-type:application/json" \
      -H "access-token:m2dur4iunp1XOqySaaaXnw" \
      -H "client:-TCTVBj1Luijwew_jMUdIg" \
      -H "uid:seller@example.com"

[
	{
		"id": 1,
		"buyer_id": 4,
		"buyer_name": "example",
		"buyer_email": "example@example.com",
		"buyer_point_to": 9900,
		"seller_id": 5,
		"seller_name": "seller",
		"seller_email": "seller@example.com",
		"seller_point_to": 10100,
		"item_id": 11,
		"item_name": "example item",
		"item_description": "example description",
		"item_point": 100,
		"created_at": "2022-04-16T08:10:17.682+09:00",
		"updated_at": "2022-04-16T08:10:17.682+09:00"
	}
]
```

## 開発詳細

### パフォーマンスに気を配る
- サーバのパフォーマンス・負荷
  - 商品一覧などのリストを取得するAPIは、ページングを用いて一度に取得するデータ量を制限することで、リクエストごとのサーバへの負荷を軽減しています。
- データベースのパフォーマンス・負荷
  - 商品テーブルにuser_idとcreated_atの複合インデックスを作成し、ユーザの商品取得クエリの負荷を軽減しています。

### 同時リクエストに気を配る
本APIでは、同じ商品が同時にアクセスした複数のユーザに重複して購入されたり、購入処理中に値段が変わってしまったりように注意しなければなりません。  
この問題には、購入処理トランザクション中に対象商品レコード及び対象売買ユーザレコードに悲観的ロックをかけることで対応しています。

実際のコードは以下をご覧ください。
- api/app/models/user.rb#buy
- api/spec/models/user_spec.rb#buy
- api/spec/requests/v1/market_spec.rb#buy
