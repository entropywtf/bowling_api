# Bowling API

Ruby on Rails API that takes score of a bowling game.

## What does it basically provide:

* A way to start a new bowling game;
* A way to input the number of pins knocked down by each ball;
* A way to output the current game score (score for each frame and total score).

## Use case
Imagine that this API will be used by a bowling house. On the screen the user starts the game, then
after each throw the machine, with a sensor, counts how many pins were dropped and calls the API
sending this information. In the meantime the screen is constantly (for example: every 2 seconds)
asking the API for the current game status and displays it.

## Ruby / Rails
```
ruby -v
ruby 2.3.0p0 (2015-12-25 revision 53290) [x86_64-darwin15]
rails -v
Rails 5.0.0.1
```

## How to run
```
git clone git@gitlab.com:entropyftw/bowling_api.git
cd bowling_api
rails db:create db:migrate db:fixtures:load
rails s
```
Assuming no custom hostname and/or port were set:
Create a new game. JSON data will be rendered with basic information about newly created game. :id here is useful.
```
localhost:3000/games/start
```
The machine, that counts how many pins were dropped, calls the API sending score only using this URL and knowing game_id and currently dropped pins' score.
The logic how it'll be assigned to a frame and how total score will be calculated is hidden inside the blackbox.
The input 'game_id' && 'submitted_score' will be validated, so that it should not happen, that wrong type of input, or score greater than quantity of pins, or non-existing game etc. could be applied.
```
localhost:3000/games/1?submit_score=5
```
To get the game score in any interval of time it's necessary only to pass game's id:
```
http://localhost:3000/games/1
```
JSON data will be rendered with the information about the game (under 'data' key: id, total_score, if the game is over) and the frames (under 'include' key: frame number, if the frame is strike or spare, it's score and if this frame is over meaning there was either strike or two turns were preformed)

To run the tests:
```
rails test test/controllers/games_controller_test.rb
rails test test/models/game.rb
```
