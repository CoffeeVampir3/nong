import paddle
import ball

type
    GameState* = ref object
        paddle*: Paddle
        balls*: seq[Ball]
        score* = 0.0f
        scoreMult* = 1.0f
        maxBalls*:int = 1
        maxBallSpeed* = 0.0625
        roundDuration* = 10.0