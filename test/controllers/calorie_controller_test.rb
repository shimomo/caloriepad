require 'test_helper'

class CalorieControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get calorie_index_url
    assert_response :success
  end

end
