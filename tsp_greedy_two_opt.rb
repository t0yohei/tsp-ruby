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


# @return two_opt_result_route
# @return two_opt_total_distance
def calc_two_opt_reslt(base_route)
  # 一つの candidate は [place, place] のような配列
  # スタート・最終地点は固定なので candidate から除外
  swap_candidate_route = base_route.dup
  swap_candidate_route.shift
  swap_candidate_route.pop
  all_change_candidates = swap_candidate_route.combination(2).to_a

  # base_route を初期値としてもつ
  two_opt_result_route = base_route.dup

  improved = true
  while improved do
    improved = false
    shuffled_all_change_candidates = all_change_candidates.shuffle
    shuffled_all_change_candidates.each do |candidate|
      first_candidate_index = base_route.index(candidate[0])
      second_candidate_index = base_route.index(candidate[1])
      if improvable?(first_candidate_index, second_candidate_index, two_opt_result_route)
        improved = true
        optimize_route(first_candidate_index, second_candidate_index, two_opt_result_route)
      end
    end
  end

  two_opt_total_distance = calc_total_distance(two_opt_result_route)
  return two_opt_result_route, two_opt_total_distance
end

def improvable?(first_place_index, second_place_index, route)
  cost = calc_distance(route[first_place_index - 1], route[second_place_index - 1]) - calc_distance(route[first_place_index - 1], route[first_place_index])
  cost += calc_distance(route[first_place_index], route[second_place_index]) - calc_distance(route[second_place_index - 1], route[second_place_index])
  cost < 0
end

def optimize_route(first_candidate_index, second_candidate_index, route)
  reversed_route_part = route[first_candidate_index..second_candidate_index].reverse
  route[first_candidate_index..second_candidate_index] = reversed_route_part
  return
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
greedy_result_route, greedy_total_distance = calc_nearist_places(first_start_place, places, [first_start_place], 0)

# calc_two_opt_reslt(greedy_result_route)
two_opt_result_route, two_opt_total_distance = calc_two_opt_reslt(greedy_result_route)

# greedy + two_opt の結果表示
puts two_opt_result_route.map(&:name).join(' -> ')
puts two_opt_total_distance
