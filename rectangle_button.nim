import raylib
import std/strutils

type
    RectButton* = object
        x*, y*: float32
        width*, height*: float32
        text*: string
        textColor*: Color
        bgColor*: Color

proc wrapText(text: string, maxWidth: float32, fontSize: int32): seq[string] =
    result = @[]
    var currentLine = ""
    for word in text.split():
        let wordWidth = measureText(cstring(currentLine & " " & word),
        fontSize).float32
        if wordWidth > maxWidth:
            if currentLine != "":
                result.add(currentLine)
                currentLine = word
        else:
            if currentLine != "":
                currentLine &= " "
                currentLine &= word
        if currentLine != "":
            result.add(currentLine)

proc drawButton*(btn: RectButton, screenWidth, screenHeight: int32) =
    drawRectangle(
        int32(btn.x * float32(screenWidth)),
        int32(btn.y * float32(screenHeight)),
        int32(btn.width * float32(screenWidth)),
        int32(btn.height * float32(screenHeight)),
        btn.bgColor
    )
    const fontSize = 20
    let padding = 5.0
    let wrappedText = wrapText(
        btn.text,
        btn.width * float32(screenWidth) - padding * 2,
        fontSize
    )
    var yOffset = 0.0
    for line in wrappedText:
        drawText(
            cstring(line),
            int32(btn.x * float32(screenWidth) + padding),
            int32(btn.y * float32(screenHeight) + padding + yOffset),
            fontSize,
            btn.textColor
        )
        yOffset += fontSize.float32 * 1.2 # Add some line spacing