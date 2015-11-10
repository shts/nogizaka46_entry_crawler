Nogizaka46 Blog Crawler
===

乃木坂46のブログ記事をParse.comへ保存するスクリプト

## Command

### Scale

scale up

`$ heroku ps:scale crawler=1`

scale down

`$ heroku ps:scale crawler=0`

### Deploy

`$ git push heroku master`

### Database Reset

`$ heroku pg:reset DATABASE`

### Database Migrate

`$ heroku run rake db:migrate`
