import raylib
import math
import std/random
import ball
import paddle
import rectangle_button
import strformat
import gamestate
import ball_system

# NOTE TO THE THEORETICAL COMMUNISTS READING THIS REMORSEFUL MESSAGE
# THE PATRIOTS HAVE STORMED THE GATES, ALL MEASUREMENTS ARE THEREFORE NORMALIZED TO SCREEN DIMENSIONS
# ANYONE CAUGHT READING IS GUILTY OF THOUGHT CRIMES AND HEREBY SENTENCED TO DEATH

const
    screenWidth = 1920
    screenHeight = 1080

var
    paused = false
    timer = 0.0

type
    Ability = tuple[text: string, ability: proc(state: GameState) {.closure.}]

proc lerp[T: SomeNumber](a, b: T, t: float): T =
    return a + (b - a) * T(t)

proc weightedRandomSelection(abilities: seq[Ability], maxSelect: int = 3): seq[Ability] =
    var availableAbilities = abilities
    let numToSelect = rand(1.0)
    let selectCount = if numToSelect < 0.7: 1
                        elif numToSelect < 0.9: 2
                        else: 3

    result = @[]
    let actualSelectCount = min(min(selectCount, maxSelect), availableAbilities.len)
    for i in 1..actualSelectCount:
        let idx = rand(availableAbilities.len - 1)
        result.add(availableAbilities[idx])
        availableAbilities.del(idx)

proc initializeButtons(state: GameState): seq[RectButton] =
    result = @[]

    let ability_list: seq[Ability] = @[
        ("Zoomier Balls", proc(state: GameState) {.closure.} = state.maxBallSpeed += 0.00625 * 0.5),
        ("Score is all that matters.", proc(state: GameState) {.closure.} = state.scoreMult += 0.17),
        ("Paddle fast as fuck boiiii", proc(state: GameState) {.closure.} = state.paddle.speed += 0.00625),
        ("Paddle got dat dumpy tho", proc(state: GameState) {.closure.} = state.paddle.width += 0.025),
        ("We ball.", proc(state: GameState) {.closure.} = state.maxBalls += 1)
    ]

    proc makeBtn(state: GameState, yoffset: float): RectButton =
        let selected = weightedRandomSelection(ability_list)
        var finalText = ""
        for i, ability in selected:
            if i > 0:
                finalText.add(" \n AND \n ")
            finalText.add(ability.text)

        result = RectButton(
            x: 0.5 - 0.0625,
            y: 0.5 - yoffset,
            width: 0.25,
            height: 0.15625,
            text: finalText,
            textColor: Green,
            bgColor: Black,
            onClick: proc() =
                for ability in selected:
                    ability.ability(state)
        )

    result = @[]
    for i in 0..2:
        result.add(makeBtn(state, float(i) * 0.1953125))

proc normalGameLoop(state: GameState, btns: var seq[RectButton], screenWidth, screenHeight: int) =
    if isKeyDown(KeyboardKey.Left) and state.paddle.x > 0:
        state.paddle.x -= state.paddle.speed
    if isKeyDown(KeyboardKey.Right) and state.paddle.x < 1.0 - state.paddle.width:
        state.paddle.x += state.paddle.speed
    if isKeyPressed(KeyboardKey.Space):
        btns = initializeButtons(state)
        paused = true
    updateBalls(state)

proc main() =
    initWindow(screenWidth, screenHeight, "Deez Nuts")
    setTargetFPS(60)

    var state = GameState(
        paddle: Paddle(x: 0.5, y: 0.9, width: 0.1, height: 0.0325, speed: 0.00975),
        balls: @[],
    )
    var
        btns: seq[RectButton]
        displayScore: float = 0.0

    initAudioDevice()
    var music = loadMusicStream("Game music or something.mp3")
    playMusicStream(music)
    while not windowShouldClose():
        updateMusicStream(music)

        #let currentTime = getFrameTime()
        let deltaTime = getFrameTime()
        timer = max(timer - deltaTime, 0.0)

        if timer <= 0.0:
            timer = state.roundDuration
            btns = initializeButtons(state)
            paused = true
            while state.balls.len > 0:
                state.balls.delete(state.balls.len - 1)
            state.balls.setLen(0)
            for i in 1..state.maxBalls:
                var ball = Ball(
                x: rand(0.5),
                y: rand(0.5),
                radius: state.ballSize,
                color: Color(
                    r: uint8(rand(256)), 
                    g: uint8(rand(256)), 
                    b: uint8(rand(256)), 
                    a: 255)
                )
                (ball.speedX, ball.speedY) = randomVelocity()
                state.balls.add(ball)
            

        if not paused:
            normalGameLoop(state, btns, screenWidth, screenHeight)
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
                        paused = false


        beginDrawing()
        clearBackground(Color(
                    r: uint8(200), 
                    g: uint8(200), 
                    b: uint8(200), 
                    a: 255))

        # Draw paddle
        drawRectangle(
          int32(state.paddle.x * screenWidth), int32(state.paddle.y * screenHeight),
          int32(state.paddle.width * screenWidth), int32(state.paddle.height *
          screenHeight), Black
        )

        # Draw balls
        for ball in state.balls:
            drawCircle(
                int32(ball.x * screenWidth),
                int32(ball.y * screenHeight),
                ball.radius * screenWidth,
                Black
            )


        # Do score stuff

        if not paused:
            proc calcTextDiff(state: GameState, displayScore: float): (float, int32) =
                let minSize = 30.0
                let maxSize = 400.0
                let maxDifference = 200.0
                
                let scoreDifference = state.score - displayScore
                let t = clamp(scoreDifference / maxDifference, 0.0, 1.0)
                
                result = (t, int32(lerp(minSize, maxSize, t)))
            
            let (t, diff) = calcTextDiff(state, displayScore)
            if displayScore < state.score:
                if state.score - displayScore < 0.1:
                    displayScore = state.score
                else:
                    displayScore += (t * 0.365)

            drawText(fmt"Score: {int(round(displayScore))}", 25, 25, diff, Black)

            # Time stuff
            let timerText = fmt"{int(ceil(timer))}"
            let timerFontSize:int32 = 40
            let timerTextWidth = measureText(cstring(timerText), timerFontSize)
            drawText(timerText, (screenWidth div 2) - timerTextWidth, int32(0.95 * screenHeight), timerFontSize, Black)

        if paused:
            for btn in btns:
                drawButton(btn, screenWidth, screenHeight)

        endDrawing()

    closeAudioDevice()
    closeWindow()

main()