<?php
require "twitteroauth/autoload.php";
use Abraham\TwitterOAuth\TwitterOAuth;

$jsonUrl = "Twitterkey.json"; //JSONファイルの場所とファイル名を記述
if(file_exists($jsonUrl)){
  $json = file_get_contents($jsonUrl);
  $json = mb_convert_encoding($json, 'UTF8', 'ASCII,JIS,UTF-8,EUC-JP,SJIS-WIN');
  $obj = json_decode($json,true);
  //var_dump($obj);
  $consumerKey = $obj["CONSUMERKEY"];
  $consumerSecret = $obj["CONSUMERSECRET"];
  $accessToken = $obj["ACCESSTOKEN"];
  $accessTokenSecret = $obj["ACCESSTOKENSECRET"];
}

//var_dump($consumerKey);

$connection = new TwitterOAuth($consumerKey, $consumerSecret, $accessToken, $accessTokenSecret);
//var_dump($connection);

$tweets_params =["geocode" => "34.694343,135.194507,1km"];

$tweets = $connection->get('search/tweets', $tweets_params);
// この時点で$tweetsはオブジェクト型らしい
//var_dump($tweets);
$arr = json_encode($tweets);
//file_put_contents("geosearch.json" , $arr);

$url = 'http://localhost:4567/edit';
$headers = ['Content-type: application/json'];

$curl = curl_init($url);
curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
curl_setopt($curl, CURLOPT_POSTFIELDS, $arr);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($curl);
curl_close($curl);

//echo $response, PHP_EOL;

//$post=[];
//foreach($tweets as $key => $value){
//    if($key == "statuses"){
//        $i=0;
//        print ("status");
//        foreach($value as $key => $value){
//            var_dump($value);
//            foreach($value as $key => $value){
//                var_dump($key);
//            }
//        }
//    }
//    var_dump($key);
//    var_dump($value);
//}

?>


