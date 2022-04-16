# frozen_string_literal: true

RSpec::OpenAPI.info = {
  title: 'frea-market-api',
  description: 'ユーザが商品を出品し、ユーザ同士でポイントを介して商品を売買することができるAPIです。'
}

RSpec::OpenAPI.server_urls = %w[http://localhost:3000]
