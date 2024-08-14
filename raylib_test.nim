import raylib
import std/random
import ball
import paddle
import rectangle_button

# NOTE TO THE THEORETICAL COMMUNISTS READING THIS REMORSEFUL MESSAGE
# THE PATRIOTS HAVE STORMED THE GATES, ALL MEASUREMENTS ARE THEREFORE NORMALIZED TO SCREEN DIMENSIONS
# ANYONE CAUGHT READING IS GUILTY OF THOUGHT CRIMES AND HEREBY SENTENCED TO DEATH

const
    screenWidth = 1920
    screenHeight = 1080

var
    paused = false

proc normalGameLoop(balls: var seq[Ball], paddle: var Paddle, score: var int,
  screenWidth, screenHeight: int) =
    if isKeyDown(KeyboardKey.Left) and paddle.x > 0:
        paddle.x -= 0.00625
    if isKeyDown(KeyboardKey.Right) and paddle.x < 1.0 - paddle.width:
        paddle.x += 0.00625
    if isKeyPressed(KeyboardKey.Space):
        paused = true
    updateBalls(balls, paddle, score)

proc main() =
    initWindow(screenWidth, screenHeight, "Deez Nuts")
    setTargetFPS(60)

    var
        paddle = Paddle(x: 0.5, y: 0.9, width: 0.1, height: 0.0325)
        balls: seq[Ball]
        btns: seq[RectButton]
        score = 0

    btns.add(RectButton(
      x: 0.5 - 0.0625,
      y: 0.5,
      width: 0.125,
      height: 0.15625,
      text: "Ligma",
      textColor: Green,
      bgColor: Black,
      onClick: proc () =
        echo "A!"
    ))

    btns.add(RectButton(
      x: 0.5 - 0.0625,
      y: 0.5 - 0.1953125,
      width: 0.125,
      height: 0.15625,
      text: "+8 to sucking dick",
      textColor: Green,
      bgColor: Black,
      onClick: proc () =
        echo "B!"
    ))

    btns.add(RectButton(
      x: 0.5 - 0.0625,
      y: 0.5 - 0.390625,
      width: 0.125,
      height: 0.15625,
      text: "10 More balls",
      textColor: Green,
      bgColor: Black,
      onClick: proc () =
        for i in 1..10:
            var ball = Ball(
            x: rand(0.5),
            y: rand(0.5),
            radius: 0.02,
            color: Color(
                r: uint8(rand(256)), 
                g: uint8(rand(256)), 
                b: uint8(rand(256)), 
                a: 255)
            )
            (ball.speedX, ball.speedY) = randomVelocity()
            balls.add(ball)
        paused = false
    ))

    for i in 1..1:
        var ball = Ball(
          x: rand(0.5),
          y: rand(0.5),
          radius: 0.02,
          color: Color(
            r: uint8(rand(256)), 
            g: uint8(rand(256)), 
            b: uint8(rand(256)), 
            a: 255)
        )
        (ball.speedX, ball.speedY) = randomVelocity()
        balls.add(ball)

    while not windowShouldClose():
        if not paused:
            normalGameLoop(balls, paddle, score, screenWidth, screenHeight)
        else:
            if isKeyPressed(KeyboardKey.Space):
                paused = false

            # BUTTON IMPL
            if isMouseButtonPressed(MouseButton.Left):
                var mousePos = getMousePosition()
                mousePos.x /= screenWidth;
                mousePos.y /= screenHeight;
                for btn in btns:
                    var rect = Rectangle(
                        x: btn.x,
                        y: btn.y,
                        width: btn.width,
                        height: btn.height
                    )
                    if checkCollisionPointRec(mousePos, rect):
                        btn.onClick()


        beginDrawing()
        clearBackground(RayWhite)

        # Draw paddle
        drawRectangle(
          int32(paddle.x * screenWidth), int32(paddle.y * screenHeight),
          int32(paddle.width * screenWidth), int32(paddle.height *
          screenHeight), Black
        )

        # Draw balls
        for ball in balls:
            drawCircle(
              int32(ball.x * screenWidth),
              int32(ball.y * screenHeight),
              ball.radius * screenWidth,
              ball.color
            )

        drawText("Score: " & $score, 10, 10, 20, Black)

        if paused:
            for btn in btns:
                drawButton(btn, screenWidth, screenHeight)

        endDrawing()

    closeWindow()

main()