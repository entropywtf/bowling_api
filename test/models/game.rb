require 'test_helper'

class GameTest < ActiveSupport::TestCase

  def setup
    @game = Game.create
  end

  test "submit less than 10 frame scores" do
    10.times do
      [2, 3].each do |s|
        @game.update_score(s)
      end
    end
    assert_equal 50, @game.total_score
  end

  test "submit all-spare scores" do
    10.times do
      [2, 8].each do |s|
        @game.update_score(s)
      end
    end
    #submit additional throw for spare in 10th frame
    @game.update_score(5)
    assert_equal 123, @game.total_score
  end

  test "submit all-strike scores" do
    scores = []
    # 10 usual frame turns + 2 throws for the 10th-frame-strike
    12.times { @game.update_score(10) }
    assert_equal 300, @game.total_score
  end

  test "submit all-empty looser's scores" do
    10.times { @game.update_score(0) }
    assert_equal 0, @game.total_score
  end

  test "submit mixed less than 10, 0, spare & strike frame scores" do
    [2, 3, 5, 5, 6, 2, 10, 7, 2, 1, 8, 2, 6, 3, 7, 10, 8, 2, 3].each do |s|
      @game.update_score(s)
    end
    assert_equal 127, @game.total_score
  end

end
