require 'test_helper'
require 'json'

class GamesControllerTest < ActionController::TestCase
  test "Should create a new game" do
    assert_difference 'Game.count' do
      post :create
    end
    assert_response :success
    jdata = JSON.parse response.body
    assert_equal 0, jdata['data']['attributes']['total-score']
    assert_equal nil, jdata['data']['attributes']['is-over']
  end

  test "Should submit score" do
    game = Game.find 1
    frame = game.frames.first
    old_score = game.total_score
    assert_equal game.total_score, old_score

    get :score, params: { id: 1, submit_score: 5 }
    assert_response :success

    jdata = JSON.parse response.body
    assert_equal 10, jdata['data']['attributes']['total-score']
    assert_equal false, jdata['data']['attributes']['is-over']
    assert_equal true, jdata['included'].first['attributes']['spare']
  end

  test "Should render not found for non-existing game" do
    get :score, params: { id: 343 }
    assert_response :not_found
  end

  test "Should not submit score and render not modified" do
    game = Game.find 1
    game.is_over = true
    game.save!
    assert_raise(ArgumentError) do
      get :score, params: { id: 1, submit_score: 5 }
    end
  end

  test "Should show score" do
    get :score, params: { id: 1 }
    assert_response :success
    jdata = JSON.parse response.body
    assert_equal 5, jdata['data']['attributes']['total-score']
    assert_equal nil, jdata['data']['attributes']['is-over']
    assert_equal nil, jdata['included'].first['attributes']['spare']
    assert_equal 1, jdata['included'].first['attributes']['number']
  end
end
