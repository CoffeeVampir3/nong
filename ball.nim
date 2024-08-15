import raylib
import std/math
import std/random

const
    initialBallSpeed = 0.015

type
    Ball* = object # Also export the Ball type
        x*, y*: float32
        speedX*, speedY*: float32
        radius*: float32
        color*: Color

proc randomVelocity*(): tuple[x, y: float32] =
    let angle = rand(2.0 * PI)
    result.x = cos(angle) * initialBallSpeed
    result.y = sin(angle) * initialBallSpeed