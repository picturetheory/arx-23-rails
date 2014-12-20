if ENV["REDISCLOUD_URL"]
    $redis = Redis.new(:url => ENV["REDISCLOUD_URL"])
    REDIS = Redis.new(:url => ENV["REDISCLOUD_URL"])
else
	$redis = Redis.new
	REDIS = Redis.new
end