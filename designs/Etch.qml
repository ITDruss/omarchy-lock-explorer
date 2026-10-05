import QtQuick
import qs.Commons
import "Ttfx.js" as Ttfx

// A laser etches the greeting and the time onto the screen, sparks cooling
// into the theme accent. The new minute catches a highlight; a wrong password
// scatters the words and lets them fall back into line.
DesignBase {
  id: lock
  inputItem: field.input
  flashOnFail: false

  Wallpaper { anchors.fill: parent; lock: lock; blur: 1; dim: 0.72 }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { lock.wakeRequested(); lock.forcePasswordFocus() }
    onPositionChanged: lock.wakeRequested()
  }

  Column {
    id: etchLayout
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.leftMargin: Math.round(lock.width * 0.07)
    anchors.bottomMargin: Math.round(lock.height * 0.12)
    spacing: 22

    TtfxText {
      id: words
      text: lock.greeting().toLowerCase() + ".\n" + lock.clock("HH:mm") + "  " + lock.clock("ddd d MMM").toLowerCase()
      effect: "laseretch"
      replayEffect: "highlight"
      margin: 1
      pixelSize: Math.max(24, Math.round(lock.height / 18))
      effectOptions: ({
        laseretch: ["--etch-speed", "1", "--etch-delay", "2",
                    "--laser-gradient-stops", Ttfx.hex(Qt.lighter(Color.lock.text, 1.25)), Ttfx.hex(Color.lock.borderActive),
                    "--spark-gradient-stops", Ttfx.hex(Qt.lighter(Color.lock.text, 1.25)), Ttfx.hex(Color.lock.borderActive), Ttfx.hex(Color.lock.textError),
                    "--cool-gradient-stops", Ttfx.hex(Color.lock.borderActive), Ttfx.hex(Color.muted),
                    "--final-gradient-stops", Ttfx.hex(Color.lock.text), Ttfx.hex(Color.lock.borderActive),
                    "--final-gradient-direction", "horizontal"]
      })
    }

    PasswordField {
      id: field
      lock: lock
      x: Math.round(words.cellWidth)
      width: Math.max(360, words.width * 0.45)
      height: 50
      radius: 8
      outlineThickness: 1
      showLockGlyph: false
      textAlignment: TextInput.AlignLeft
      color: lock.withAlpha(Color.lock.background, 0.5)



    }
  }

  // Keep the hint outside the field so the original Etch layout stays put.
  Item {
    x: etchLayout.x + field.x
    y: etchLayout.y + field.y + field.height + 12
    width: field.width
    height: 46
    visible: lock.faceConfigured && !lock.snapshotMode

    Text {
      id: faceMark
      anchors.left: parent.left
      anchors.leftMargin: 4
      anchors.top: parent.top
      text: lock.faceRecognized ? "✓" : "☺"
      color: lock.faceRecognized ? Color.lock.borderActive : Color.lock.text
      font.family: Style.font.family
      font.pixelSize: 22
      opacity: lock.faceRecognized ? 1 : 0.65
      SequentialAnimation on opacity {
        running: lock.faceAuthenticating && lock.screenAwake && !lock.snapshotMode && !lock.motionReduced
        loops: Animation.Infinite
        NumberAnimation { to: 0.35; duration: 650 }
        NumberAnimation { to: 0.9; duration: 650 }
        onRunningChanged: if (!running) faceMark.opacity = lock.faceRecognized ? 1 : 0.65
      }
    }

    Column {
      anchors.left: faceMark.right
      anchors.leftMargin: 12
      anchors.right: parent.right
      spacing: 4
      Text {
        width: parent.width
        text: lock.faceRecognized ? lock.tr("Face recognized")
          : lock.faceAuthenticating ? lock.tr("Recognizing face…") : lock.tr("Face recognition")
        color: lock.faceRecognized ? Color.lock.borderActive : Color.lock.text
        font.family: Style.font.family
        font.pixelSize: 13
        opacity: lock.faceRecognized ? 1 : 0.8
        elide: Text.ElideRight
      }
      Text {
        width: parent.width
        text: lock.faceRecognized ? lock.tr("Enter / Space to unlock")
          : lock.faceAuthenticating ? lock.tr("Look at the camera") : lock.tr("Enter to scan your face")
        color: Color.lock.text
        font.family: Style.font.family
        font.pixelSize: 11
        opacity: 0.55
        elide: Text.ElideRight
      }
    }
  }

  Connections {
    target: lock
    function onFailureMessageChanged() {
      if (lock.failureMessage.length > 0) words.play("scattered")
    }
  }
}
