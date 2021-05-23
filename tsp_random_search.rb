# frozen_string_literal: true

#
# 下記のような 地点名,x座標,y座標 となっているような CSV が投入されることを想定
#
# start,20,111
# a,47,45
# b,34,231
# c,45,47
#

require 'csv'

class Place
  def initialize(attribute)
    @name = attribute[0]
    @x = attribute[1].to_i
    @y = attribute[2].to_i
  end

  attr_reader :name, :x, :y
end

# @return [Array<Place>] Place クラスのインスタンスオブジェクトの配列
def import_places(filename)
  reader = CSV.open(filename, 'r:UTF-8')

  return reader.inject([]) do |places, row|
    places.push(Place.new(row))
  end
end

def calc_distance(start_place, target_place)
  width = (start_place.x - target_place.x).abs
  heigth = (start_place.y - target_place.y).abs
  return (width ** 2 + heigth ** 2) ** 0.5
end

# @return [string] best_route 最善のルート
# @return [string] best_distance 最善のルートを辿った時の距離
def calc_random_places(start_place, other_places, search_limit)
  best_route = nil
  best_distance = nil

  search_limit.times do
    random_route = decide_random_route(other_places, [start_place])
    random_route_total_distance = calc_total_distance(random_route)
    if best_distance.nil? || random_route_total_distance < best_distance
      best_route = random_route
      best_distance = random_route_total_distance
    end
  end

  # 出発地点に戻るための距離を計算
  best_distance = best_distance + calc_distance(best_route.last, best_route.first)
  best_route << best_route[0]

  return best_route, best_distance
end

def decide_random_route(other_places, random_route)
  if other_places.count == 0
    return random_route
  end

  # ランダムに抽出
  shuffled_othre_places = other_places.shuffle
  random_route = random_route << shuffled_othre_places.shift

  decide_random_route(shuffled_othre_places, random_route)
end

def calc_total_distance(route)
  total_distance = 0
  route.each_with_index do |place, index|
    total_distance += calc_distance(route[index - 1], place) if index > 0
  end
  return total_distance
end

places = import_places('sample_data.csv')
first_start_place = places.shift
best_route, best_distance = calc_random_places(first_start_place, places, 1_000_000)

# 結果の表示
puts best_route.map(&:name).join(' -> ')
puts best_distance
