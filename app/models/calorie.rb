class Calorie
  include ActiveModel::Model

  def initialize
    @fatsecret = FatsecretApi.new(ENV["FATSECRET_CONSUMER_KEY"], ENV["FATSECRET_SHARED_SECRET"])
    @translator = TranslatorApi.new(ENV["OCP_APIM_SUBSCRIPTION_KEY"])
  end

  def get_calories(food_names)
    calories = []
    food_names.each do |ja_food_name|
      ja_food_name = ja_food_name.gsub(/(\(|（).*?(\)|）)/, "")
      ja_food_name = ja_food_name.gsub(/[^ぁ-んァ-ンーa-zA-Z0-9一-龠０-９\-\r]+/u, "")
      en_food_name = translate_to_english(ja_food_name)

      if find_by_response = Food.find_by(ja_food_name: ja_food_name)
        calories.push(find_by_response)
        next
      end

      begin
        food = search_food(en_food_name)
        food_id = retrieve_food_id(food)
        food_per = retrieve_food_per(food)
        food_calorie = retrieve_food_calorie(food)
        calorie = register_food(food_id, ja_food_name, en_food_name, food_per, food_calorie)
        calories.push(calorie)
      rescue NoMethodError => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
      end
    end

    calories
  end

  private

  def translate_to_english(ja_food_name)
    @translator.to_english(ja_food_name)
  end

  def search_food(en_food_name)
    food = @fatsecret.search_food(en_food_name)
    JSON.parse(food.to_json)
  end

  def retrieve_food_id(food)
    food["foods"]["food"][0]["food_id"]
  end

  def retrieve_food_description(food)
    food["foods"]["food"][0]["food_description"].split(" | ")
  end

  def retrieve_food_per(food)
    food_description = retrieve_food_description(food)
    food_description_per = food_description[0].split(" - ")
    food_description_per[0][4, 100]
  end

  def retrieve_food_calorie(food)
    food_description = retrieve_food_description(food)
    food_description_calorie = food_description[0].split(" - ")
    food_description_calorie[1][10, 100]
  end

  def register_food(food_id, ja_food_name, en_food_name, food_per, food_calorie)
    current_time = Time.zone.now
    Food.create(
      food_id: food_id,
      ja_food_name: ja_food_name,
      en_food_name: en_food_name,
      food_per: food_per,
      food_calorie: food_calorie,
      created_at: current_time,
      updated_at: current_time
    )
  end
end
