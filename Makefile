# コンテナを作り直して起動
init:
	docker-compose down
	docker-compose up -d
	docker-compose exec api rails db:migrate:reset
	docker-compose exec api rails db:seed
	docker-compose stop
	docker-compose up

# コンテナに加え、それらに結びつくボリューム(DB, registry等)も削除
clean:
	docker-compose stop
	docker-compose rm -v -f

# コンテナ、イメージ、ボリューム、noneのイメージを削除
clean_all:
	docker-compose down --rmi all --volumes
	docker system prune

##### API #####
r: # rails
	docker-compose exec api sh

c:
	docker-compose exec api rails c

gs:
	rm -f ./api/doc/openapi.yaml
	docker-compose exec api sh -c 'OPENAPI=1 rspec spec/requests/'

# migrationファイルを読み込んでschemaを更新しつつseedする
db_init:
	docker-compose restart db
	docker-compose exec api rails db:environment:set RAILS_ENV=development
	docker-compose exec api rails db:migrate:reset
	docker-compose exec api rails db:seed

# migrationを最新まで進める
db_migrate:
	docker-compose exec api rails db:migrate

# 今あるschemaをそのまま使ってDBをリセットする
# db:resetはseedも実行してくれる
db_reset:
	docker-compose exec api rails db:reset

ce:
	docker-compose exec api rails credentials:edit

cs:
	docker-compose exec api rails credentials:show