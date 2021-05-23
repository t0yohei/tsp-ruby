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

# @return [Array<Place>] result_route 結果の道順
# @return [Array<Place>] total_distance トータル距離
def calc_nearist_places(start_place, other_places, result_route, total_distance)
  if other_places.empty? || other_places == nil
    # 出発地点に戻るための距離を計算
    total_distance = total_distance + calc_distance(result_route.last, result_route.first)
    result_route << result_route[0]
    return result_route, total_distance
  end

  nearist_distance = nil
  nearist_place = nil
  other_places.each do |other_place|
    distance_from_start = calc_distance(start_place, other_place)
    if nearist_distance.nil? || distance_from_start < nearist_distance
      nearist_place = other_place
      nearist_distance = distance_from_start
    end
  end

  result_route = result_route << nearist_place
  total_distance = total_distance + nearist_distance

  new_other_places = other_places.filter { |other_place| other_place.name != nearist_place.name }
  calc_nearist_places(nearist_place, new_other_places, result_route, total_distance)
end

places = import_places('sample_data.csv')
first_start_place = places.shift
result_route, total_distance = calc_nearist_places(first_start_place, places, [first_start_place], 0)

# 結果の表示
puts result_route.map(&:name).join(' -> ')
puts total_distance
