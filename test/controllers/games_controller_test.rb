require 'test_helper'
require 'json'

class GamesControllerTest < ActionController::TestCase
  test "Should create a new game" do
    assert_difference 'Game.count' do
      post :create
    end
    assert_response :success
  end

  test "Should submit score" do
    game = Game.find 1
    frame = game.frames.first
    old_score = game.total_score
    assert_equal game.total_score, old_score

    get :score, params: { id: 1, submit_score: 5 }
    assert_response :success

    game.reload
    frame.reload
    new_score = old_score + 5
    assert_equal new_score, frame.score
    assert_equal new_score, game.total_score
  end

  test "Should render not found for non-existing game" do
    get :score, params: { id: 343 }
    assert_response :not_found
  end

  test "Should not submit score and render not modified" do
    game = Game.find 1
    game.is_over = true
    game.save!
    get :score, params: { id: 1, submit_score: 5 }
    assert_response :not_modified
  end

  test "Should show score" do
    get :score, params: { id: 1 }
    assert_response :success
  end
end
