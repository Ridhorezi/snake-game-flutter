import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_game_flutter/blank_pixel.dart';
import 'package:snake_game_flutter/food_pixel.dart';
import 'package:snake_game_flutter/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ignore: camel_case_types, constant_identifier_names
enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  /* grid dimensions */
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  /* set if button play game started*/
  bool gameHasStarted = false;

  /* snake position */
  int currentScore = 0;

  /* snake position */
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  /* snake direction is initially to the right */
  var currentDirection = snake_Direction.RIGHT;

  /* snake position */
  int foodPos = 55;

  /* start game */
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 260), (timer) {
      setState(() {
        /* keep the snake moving ! */
        moveSnake();

        /* check if game is over */
        if (gameOver()) {
          /* display a message to the user */
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Game Over'),
                // Text('Your Score is: ' + currentScore.toString(),
                // content: Column(
                //   children: [
                //     const Text('Game Over'),
                //     Text('Your Score is: ' + currentScore.toString()),
                //   ],
                // ),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      submitScore();
                      Navigator.pop(context);
                      newGame();
                    },
                    // ignore: sort_child_properties_last
                    child: const Text('New Game'),
                    color: Colors.pink,
                  ),
                ],
              );
            },
          );

          /* display a message to the user */
          timer.cancel();
        }
      });
    });
  }

  void submitScore() {}

  void newGame() {
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];

      foodPos == 55;
      currentScore = 0;
      currentDirection = snake_Direction.RIGHT;
      gameHasStarted = false;
    });
  }

  void eatFood() {
    currentScore++;
    /* making sure the new food is not where the snake is */
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          /* add a head */
          // if snake is at the right wall, need to re-adjust
          if (snakePos.last % rowSize == 9) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }

        break;

      case snake_Direction.LEFT:
        {
          /* add a head */
          // if snake is at the left wall, need to re-adjust
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;

      case snake_Direction.UP:
        {
          /* add a head */
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
        }

        break;

      case snake_Direction.DOWN:
        {
          /* add a head */
          if (snakePos.last + rowSize > totalNumberOfSquares) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquares);
          } else {
            snakePos.add(snakePos.last + rowSize);
          }
        }

        break;
      default:
    }

    /* snake is eating food */
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      /* remove tail */
      snakePos.removeAt(0);
    }
  }

  /* game over */
  bool gameOver() {
    /* the game is over when the snake runs into itself,
       this occurs when there is a duplicate posititon in the snakePos list */

    /* this list is the body of the snake (no head) */
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodySnake.contains(snakePos.last)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          /* high scores */
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /* user current score */
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Current Score'),
                    Text(
                      currentScore.toString(),
                      style: const TextStyle(fontSize: 36, color: Colors.orange),
                    ),
                  ],
                ),

                // /* high scores, top 5 or 10*/
                // const Text('highscores..')
              ],
            ),
          ),

          /* game grid */
          Expanded(
            flex: 3,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 &&
                    currentDirection != snake_Direction.UP) {
                  currentDirection = snake_Direction.DOWN;
                } else if (details.delta.dy < 0 &&
                    currentDirection != snake_Direction.DOWN) {
                  currentDirection = snake_Direction.UP;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 &&
                    currentDirection != snake_Direction.LEFT) {
                  currentDirection = snake_Direction.RIGHT;
                } else if (details.delta.dx < 0 &&
                    currentDirection != snake_Direction.RIGHT) {
                  currentDirection = snake_Direction.LEFT;
                }
              },
              child: GridView.builder(
                itemCount: totalNumberOfSquares,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowSize,
                ),
                itemBuilder: (context, index) {
                  if (snakePos.contains(index)) {
                    return const SnakePixel();
                  } else if (foodPos == index) {
                    return const FoodPixel();
                  } else {
                    return const BlankPixel();
                  }
                },
              ),
            ),
          ),

          /* play button */
          Expanded(
            // ignore: avoid_unnecessary_containers
            child: Container(
              child: Center(
                child: MaterialButton(
                  // ignore: sort_child_properties_last
                  child: const Text('PLAY'),
                  color: gameHasStarted ? Colors.grey : Colors.pink,
                  onPressed: gameHasStarted ? () {} : startGame,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
