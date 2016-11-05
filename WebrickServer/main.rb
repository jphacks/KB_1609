require 'sinatra'
require 'mysql2'
require 'json'
load 'ruby/Geo_Analysis.rb'
#
# やること
# mysql本番テーブル作る　✔
# (id　long, lat double, lng double, datetime datetime)　✔
# それに合わせてやること
# ・APIで取得した物をデータベースに入れる ✔
# ・一時間以内に取得した物をとる　✔
# ・逆に古いデータを消す（1時間とか？）×
# ・15分に1回？×
# ・・データベースが変更されたタイミングでAnalysisを再計算する
# ・getで返すものにdatetime追加？ ×
# ・Time Parseでcreate_atをTime型に, Time型をMySQLのDateTime型に ✔
#
# geo_analysisの仕様変更
# ・ホットスポットの閾値を決めるんじゃなくて ホットスポットの数を決める ✔
#
# testtwieet.phpを本番仕様に
# ・"15分に1回" "最大180件" "1時間以内"のデータをとる
# ・"15分に一回" "古いデータを消す" ×
# ・"15分に1回" "Analysisを再計算"




#### データベースの設定
json_file_path = 'mysql.json'
# 設定読み込み
json_data = open(json_file_path) do |io|
  JSON.load(io)
end
client = Mysql2::Client.new(:socket => json_data["socket"], :username=> json_data["username"], :password =>  json_data["password"], :encording => json_data["encording"], :database => json_data["database"])
# 接続
#### ~~~~~~~~~~~~~~~~~~

set :public_folder, File.dirname(__FILE__) + '/html'
set :bind, '0.0.0.0'
geo_analysis = ""

get '/geotest' do
  JSON.generate(geo_analysis.hot_spots)
end

get '/recal' do
  geo_tags=[]
  results = client.query("select * from production where subdate(now(),interval 10 hour) < create_at;")
  # interval 9 について 日本時間と, ツイッターの時間の 時差が8時間
  results.each do |raw|
    geo_tags << {
        id:raw["id"],
        lat:raw["lat"],
        lng:raw["lng"],
    }
  end
  geo_analysis= Geo_Analysis.new(geo_tags)

  p geo_tags
  geo_tags.to_json

end


get '/hotspot' do
  article=[{:id=>1, :coordinates=>[34.694141925, 135.195908085], :tweets=>[{:tweet_id=>794430542129332224, :tweets_coordinates=>[34.69395698, 135.19599954]}, {:tweet_id=>794430542129332224, :tweets_coordinates=>[34.69395698, 135.19599954]}, {:tweet_id=>794430542129332224, :tweets_coordinates=>[34.69395698, 135.19599954]}, {:tweet_id=>794430542129332224, :tweets_coordinates=>[34.69395698, 135.19599954]}, {:tweet_id=>794430455227514881, :tweets_coordinates=>[34.69432687, 135.19581663]}, {:tweet_id=>794430455227514881, :tweets_coordinates=>[34.69432687, 135.19581663]}, {:tweet_id=>794430455227514881, :tweets_coordinates=>[34.69432687, 135.19581663]}, {:tweet_id=>794430455227514881, :tweets_coordinates=>[34.69432687, 135.19581663]}, {:tweet_id=>794430542129332224, :tweets_coordinates=>[34.69395698, 135.19599954]}, {:tweet_id=>794430542129332224, :tweets_coordinates=>[34.69395698, 135.19599954]}, {:tweet_id=>794430542129332224, :tweets_coordinates=>[34.69395698, 135.19599954]}, {:tweet_id=>794430542129332224, :tweets_coordinates=>[34.69395698, 135.19599954]}, {:tweet_id=>794430455227514881, :tweets_coordinates=>[34.69432687, 135.19581663]}, {:tweet_id=>794430455227514881, :tweets_coordinates=>[34.69432687, 135.19581663]}, {:tweet_id=>794430455227514881, :tweets_coordinates=>[34.69432687, 135.19581663]}, {:tweet_id=>794430455227514881, :tweets_coordinates=>[34.69432687, 135.19581663]}]}]
  JSON.generate(article)
end

post '/edit' do
  body = JSON.parse(request.body.read)
  # この時点でstring型から HASHへ
  # p body
  if body == ''
    status 400
  else
    if(!body.keys.include?("statuses"))
      p "error message"
      return status 400
    else
      arr =[]
      body["statuses"].each do |raw|
        if(!raw["geo"].nil?)
          article ={
              id: raw["id"],
              lat: raw["geo"]["coordinates"][0],
              lng: raw["geo"]["coordinates"][1],
              create_at: (Time.parse(raw["created_at"])).strftime("%Y%m%d%H%M%S")
          }
          arr << article
        end
      end
      arr.each do |json|
        client.query("insert into production(id, lat, lng, create_at)values(#{json[:id]}, #{json[:lat]}, #{json[:lng]}, #{json[:create_at]});")
      end
      # p arr
      # JSON.pretty_generate(arr)
    end

    # p body.class
    # p body
    status 200
  end
end

post '/test' do
  body = JSON.parse request.body.read
  # query = "insert into post_test(id, lat, lng)values"

  body.each do |json|
    client.query("insert into post_test(id, lat, lng) values(#{json["id"]}, #{json["lat"]}, #{json["lng"]});")
  end
  status 200
end