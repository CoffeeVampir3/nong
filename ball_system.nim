import raylib
import math
import gamestate
import ball
import paddle

proc updateBall(ball: var Ball, state: GameState) =
    ball.x += ball.speedX
    ball.y += ball.speedY
    let paddle = state.paddle

    # Ball collision with walls
    if ball.x <= 0:
        ball.speedX *= -1
        ball.x = 0.001
    if ball.x >= 1.0:
        ball.speedX *= -1
        ball.x = 0.999
    if ball.y <= 0:
        ball.speedY *= -1
        ball.y = 0.001

    # Ball collision with paddle
    if checkCollisionCircleRec(Vector2(x: ball.x, y: ball.y), ball.radius,
      Rectangle(x: paddle.x, y: paddle.y, width: paddle.width,
          height: paddle.height)):
        let collisionPoint = ball.x - (paddle.x + paddle.width / 2)
        let normalizedCollisionPoint = collisionPoint / (paddle.width / 2)
        let bounceAngle = normalizedCollisionPoint * (Pi / 4) # Max angle: 45 degrees
        let speed = sqrt(ball.speedX * ball.speedX + ball.speedY * ball.speedY)
        ball.speedX = speed * sin(bounceAngle)
        ball.speedY = -speed * cos(bounceAngle)

        # Increase ball speed slightly
        ball.speedX *= 1.13
        ball.speedY *= 1.13

        # Cap ball speed
        let currentSpeed = sqrt(ball.speedX * ball.speedX + ball.speedY * ball.speedY)
        if currentSpeed > state.maxBallSpeed:
            ball.speedX = (ball.speedX / currentSpeed) * state.maxBallSpeed
            ball.speedY = (ball.speedY / currentSpeed) * state.maxBallSpeed

        let absoluteBounceAngle = abs(bounceAngle)
        let maxBounceAngle = Pi / 2  # 90 degrees in radians
        let angleMultiplier = min(1.0 + (absoluteBounceAngle / maxBounceAngle) * 0.5, 1.5)  # maximal 1 + .5 bonus for extreme angles that shoot out toward the sides
        let speedMultiplier = min(1.0 + (speed / state.maxBallSpeed) * 1.5, 2.5)  # maximal 1 + 1.5 bonus for high speeds
        
        let baseScore = 7.0  # Base score for any hit
        state.score += baseScore * angleMultiplier * speedMultiplier * state.scoreMult

    # Reset ball if it goes below the paddle
    if ball.y > 1.0:
        ball.x = 0.5f
        ball.y = 0.5f
        (ball.speedX, ball.speedY) = randomVelocity()

proc updateBalls*(state: GameState) =
    for ball in state.balls.mitems:
        updateBall(ball, state)