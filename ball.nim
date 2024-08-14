import raylib
import std/math
import std/random
import paddle

const
  initialBallSpeed = 0.01
  ballSize* = 0.02
  maxBallSpeed = 0.0625

type
  Ball* = object  # Also export the Ball type
    x*, y*: float32
    speedX*, speedY*: float32
    radius*: float32
    color*: Color

proc randomlyPermuteColor(color: var Color) =
  let component = rand(2)
  let change = if rand(1) == 0: rand(15) else: -rand(15)
  case component:
  of 0: color.r = uint8((int(color.r) + change + 256) mod 256)
  of 1: color.g = uint8((int(color.g) + change + 256) mod 256)
  else: color.b = uint8((int(color.b) + change + 256) mod 256)

proc randomVelocity*(): tuple[x, y: float32] =
  let angle = rand(2.0 * PI)
  result.x = cos(angle) * initialBallSpeed
  result.y = sin(angle) * initialBallSpeed

proc updateBall(ball: var Ball, paddle: Paddle, score: var int) =
  ball.x += ball.speedX
  ball.y += ball.speedY

  # Ball collision with walls
  if ball.x <= 0 or ball.x >= 1.0:
    ball.speedX *= -1
  if ball.y <= 0:
    ball.speedY *= -1

  # Ball collision with paddle
  if checkCollisionCircleRec(Vector2(x: ball.x, y: ball.y), ball.radius,
    Rectangle(x: paddle.x, y: paddle.y, width: paddle.width, height: paddle.height)):
    let collisionPoint = ball.x - (paddle.x + paddle.width / 2)
    let normalizedCollisionPoint = collisionPoint / (paddle.width / 2)
    let bounceAngle = normalizedCollisionPoint * (Pi / 4) # Max angle: 45 degrees
    let speed = sqrt(ball.speedX * ball.speedX + ball.speedY * ball.speedY)
    ball.speedX = speed * sin(bounceAngle)
    ball.speedY = -speed * cos(bounceAngle)

    # Increase ball speed slightly
    ball.speedX *= 1.05
    ball.speedY *= 1.05

    # Cap ball speed
    let currentSpeed = sqrt(ball.speedX * ball.speedX + ball.speedY * ball.speedY)
    if currentSpeed > maxBallSpeed:
      ball.speedX = (ball.speedX / currentSpeed) * maxBallSpeed
      ball.speedY = (ball.speedY / currentSpeed) * maxBallSpeed

    score += 1

  # Reset ball if it goes below the paddle
  if ball.y > 1.0:
    ball.x = 0.5f
    ball.y = 0.5f
    (ball.speedX, ball.speedY) = randomVelocity()

proc updateBalls*(balls: var seq[Ball], paddle: Paddle, score: var int) =
  for ball in balls.mitems:
    updateBall(ball, paddle, score)
    randomlyPermuteColor(ball.color)