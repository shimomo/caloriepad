require "fatsecret"

class FatsecretApi
  include ActiveModel::Model

  def initialize(consumer_key, shared_secret)
    FatSecret.init(consumer_key, shared_secret)
  end

  def search_food(food_name)
    FatSecret.search_food(food_name)
  end
end
