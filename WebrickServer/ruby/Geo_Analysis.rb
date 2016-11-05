
class Geo_Analysis

  attr_reader :hot_spots
  # hotspot = [{id: 1, coordinates: [34,135], tweets_coordinates: [[34,136], ...]}...]

  def initialize(geo_tags, number=1, neightborhood = 0.0005)
    # @thresh = thresh + 1  hot-spotとする下限   仕様変更でお亡くなり
    @number =number # 取得するホットスポットの数
    @geo_info =[] # geo tagの一覧と ご近所さん結果
    @hot_spots = [] # hot spotの結果
    @neigh = neightborhood ** 2 # 半径60メール
    @squear = []
    @geo_buf= []
    geo_tags.each do |row|
      @geo_info.push({:id => row[:id], :lat=> row[:lat], :lon => row[:lng], :neigh => []})
    end
    self.analyze
  end

  def analyze
    @geo_buf =@geo_info
    id =0
    self.find_neigh
    while(id < @number)
      raw = @geo_buf.max_by{|max|
        max[:neigh].size}
      id +=1
      tweets =[]
      raw[:neigh].each do |neight|
        @geo_info.each do |raw|
          if(raw[:id] == neight)
            tweets<< {tweet_id:raw[:id],tweets_coordinates:[raw[:lat], raw[:lon]]}
          end
        end
      end
      @hot_spots << {id: id, coordinates: self.avarage(raw), tweets: tweets}
      self.remove_geo(raw[:neigh])
    end
  end

  def find_neigh
    @geo_buf.each do |n|
      @geo_buf.each do |q|
        if ((n[:lat] - q[:lat]).abs <= @neigh && (n[:lon] - q[:lon]).abs <= @neigh)
          @squear << q
        end
      end
      @squear.each do |s|
        if( ((n[:lat] - s[:lat])**2 + (n[:lon] - s[:lon]) ** 2) <= @neigh )
          n[:neigh] << s[:id]
        end
      end
      # p n[:neigh]
    end
  end

  def avarage(ava)
    count = 0
    result =[0,0]
    ava[:neigh].each do |id|
      @geo_info.each do |raw|
        if(id==raw[:id])
          result[0] += raw[:lat]
          result[1] += raw[:lon]
          count += 1
        end
      end
    end
    result[0] /= count
    result[1] /= count
    return result
  end

  def remove_geo(ids)
    ids.each do |id|
      @geo_buf.delete(@geo_buf.find{|item| item[:id] == id})
    end
  end

  def thresh=(thresh)
    @thresh = thresh
    self.analyze
  end

  def neightborhood=(neightborhood)
    @neigh = neightborhood
    self.analyze
  end
end

#
# geo_tags = [{:id=>794440796107702275, :lat=>34.68833985, :lng=>135.18417953}, {:id=>794439413333950464, :lat=>34.69223973, :lng=>135.19508955}, {:id=>794435906333708288, :lat=>34.69177526, :lng=>135.19554226}, {:id=>794434275684872195, :lat=>34.69351595, :lng=>135.1930227}, {:id=>794433054764888064, :lat=>34.69179797, :lng=>135.19364}, {:id=>794432896115310592, :lat=>34.69452263, :lng=>135.19471915}, {:id=>794431167655051264, :lat=>34.69532383, :lng=>135.1875696}, {:id=>794431085367140352, :lat=>34.68818321, :lng=>135.18855093}, {:id=>794430911584448512, :lat=>34.69258492, :lng=>135.19053553}, {:id=>794430542129332224, :lat=>34.69395698, :lng=>135.19599954}, {:id=>794430455227514881, :lat=>34.69432687, :lng=>135.19581663}, {:id=>794430306778484736, :lat=>34.69423838, :lng=>135.19409269}, {:id=>794430262591582208, :lat=>34.693806, :lng=>135.19709945}, {:id=>794429827402993664, :lat=>34.69416225, :lng=>135.19027217}, {:id=>794440796107702275, :lat=>34.68833985, :lng=>135.18417953}, {:id=>794439413333950464, :lat=>34.69223973, :lng=>135.19508955}, {:id=>794435906333708288, :lat=>34.69177526, :lng=>135.19554226}, {:id=>794434275684872195, :lat=>34.69351595, :lng=>135.1930227}, {:id=>794433054764888064, :lat=>34.69179797, :lng=>135.19364}, {:id=>794432896115310592, :lat=>34.69452263, :lng=>135.19471915}, {:id=>794431167655051264, :lat=>34.69532383, :lng=>135.1875696}, {:id=>794431085367140352, :lat=>34.68818321, :lng=>135.18855093}, {:id=>794430911584448512, :lat=>34.69258492, :lng=>135.19053553}, {:id=>794430542129332224, :lat=>34.69395698, :lng=>135.19599954}, {:id=>794430455227514881, :lat=>34.69432687, :lng=>135.19581663}, {:id=>794430306778484736, :lat=>34.69423838, :lng=>135.19409269}, {:id=>794430262591582208, :lat=>34.693806, :lng=>135.19709945}, {:id=>794429827402993664, :lat=>34.69416225, :lng=>135.19027217}]
#
# geo_analysis = Geo_Analysis.new(geo_tags)
#
# p geo_analysis.hot_spots