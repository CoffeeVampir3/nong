import raylib
import std/strutils

type
    RectButton* = object
        x*, y*: float32
        width*, height*: float32
        text*: string
        textColor*: Color
        bgColor*: Color
        onClick*: proc() {.closure.}

proc wrapText(text: string, maxWidth: int32, fontSize: int32): seq[string] =
    result = @[]
    for line in text.split('\n'):
        var currentLine = ""
        for word in line.split():
            let lineWithWord = if currentLine.len > 0: currentLine & " " & word else: word
            if measureText(lineWithWord, fontSize) <= maxWidth:
                currentLine = lineWithWord
            else:
                if currentLine.len > 0:
                    result.add(currentLine)
                    currentLine = word
                else:
                    # Word is longer than maxWidth, split it
                    result.add(word)
        if currentLine.len > 0:
            result.add(currentLine)
        elif result.len == 0 or result[^1] != "":
            # Add an empty line for consecutive newlines
            result.add("")

proc drawButton*(btn: RectButton, screenWidth, screenHeight: int32) =
    let worldX = int32(btn.x * float32(screenWidth))
    let worldY = int32(btn.y * float32(screenHeight))
    let worldWidth = int32(btn.width * float32(screenWidth))
    let worldHeight = int32(btn.height * float32(screenHeight))

    drawRectangle(worldX, worldY, worldWidth, worldHeight, btn.bgColor)

    const fontSize = 20
    let maxTextWidth = worldWidth - 10 # Leaving a 5-pixel margin on each side
    let wrappedText = wrapText(btn.text, maxTextWidth, fontSize)

    let lineHeight: int32 = fontSize + 2 # Adding 2 pixels of vertical spacing between lines
    let totalTextHeight = int32(wrappedText.len * lineHeight)
    var startY = worldY + (worldHeight - totalTextHeight) div 2 # Vertically center the text

    for line in wrappedText:
        let lineWidth = measureText(line, fontSize)
        let startX = worldX + (worldWidth - lineWidth) div 2 # Horizontally center each line
        drawText(line, startX, startY, fontSize, btn.textColor)
        startY += lineHeight