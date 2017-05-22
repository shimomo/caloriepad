class CalorieController < ApplicationController
  def initialize
    @calorie = Calorie.new
  end

  def index
    food_names = params[:foods].split(",")
    calories = @calorie.get_calories(food_names)
    render :json => { "calories" => calories }
  end
end
