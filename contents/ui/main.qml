import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    property alias minimumWidth: root.implicitWidth
    property alias minimumHeight: root.implicitHeight
    implicitWidth: 500
    implicitHeight: 700

    // Game variables
    property var symbols: ["🍒", "🍋", "🔔", "⭐", "7️⃣", "🫐", "🎰", "🍓"]
    property var reels: ["🍒", "🍋", "🔔"]
    property int credits: 200
    property int bet: 10
    property bool spinning: false
    property string result: ""
    property bool gameOver: false

    // Bonus variables
    property int freeSpins: 0
    property bool bonusGameActive: false
    property int bonusMultiplier: 1
    property bool showBerryBonus: false
    property int berriesCollected: 0
    property int currentWin: 0
    property int berriesLeft: 8
    property int bombsLeft: 3
    property bool bonusGameOver: false
    property string bonusMessage: ""
    property var berryStates: [false, false, false, false, false, false, false, false]
    property var berryWasBomb: [false, false, false, false, false, false, false, false]

    // Animation
    property real glowIntensity: 0
    property real reelPulse: 1.0
    property real titleWave: 0
    property int explodingBerry: -1

    // Settings
    property real uiScale: 1.0
    property string colorTheme: "standard"
    property string customBaseColor: "#4B53F2"
    property bool enableBonusGame: false

    // Timers
    Timer {
        id: spinTimer
        interval: 100
        repeat: true
        running: false
        onTriggered: {
            reels = [
                symbols[Math.floor(Math.random() * symbols.length)],
                symbols[Math.floor(Math.random() * symbols.length)],
                symbols[Math.floor(Math.random() * symbols.length)]
            ]
            reelPulse = 1.1
            pulseAnim.start()
        }
    }

    Timer {
        id: stopTimer
        interval: 1500
        running: false
        onTriggered: {
            spinTimer.stop()
            spinning = false
            reelPulse = 1.0
            checkWin()
            if (credits <= 0 && freeSpins <= 0 && !bonusGameActive) gameOver = true
        }
    }

    Timer {
        id: glowTimer
        interval: 50
        running: spinning || bonusGameActive
        repeat: true
        onTriggered: {
            glowIntensity = Math.sin(Date.now() / 300) * 0.3 + 0.7
        }
    }

    Timer {
        id: waveTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            titleWave = Math.sin(Date.now() / 500) * 5
        }
    }

    Timer {
        id: bombTimer
        interval: 500
        onTriggered: {
            bonusGameOver = true
            bonusMessage = "💥 ROTTEN BERRY! You lost everything!"
            result = "💥 Rotten berry exploded! Lost $" + currentWin
            closeTimer.start()
        }
    }

    Timer {
        id: winTimer
        interval: 1000
        onTriggered: {
            showBerryBonus = false
            berryBonusWindow.visible = false
            bonusGameActive = false
            resetBonusGame()
        }
    }

    Timer {
        id: closeTimer
        interval: 1000
        onTriggered: {
            showBerryBonus = false
            berryBonusWindow.visible = false
            bonusGameActive = false
            resetBonusGame()
        }
    }

    // Pulse animation
    PropertyAnimation {
        id: pulseAnim
        target: root
        property: "reelPulse"
        to: 1.0
        duration: 200
        easing.type: Easing.OutQuad
    }

    // Scale animation
    PropertyAnimation {
        id: scaleAnim
        property: "scale"
        duration: 100
        onFinished: {
            target.scale = 1.0
        }
    }

    // Функция для определения яркости цвета
    function getBrightness(color) {
        var r = parseInt(color.substring(1,3), 16)
        var g = parseInt(color.substring(3,5), 16)
        var b = parseInt(color.substring(5,7), 16)
        return (r * 299 + g * 587 + b * 114) / 1000
    }

    // Функция для получения гармоничного контрастного цвета
    function getHarmoniousContrast(baseColor, isDark) {
        var r = parseInt(baseColor.substring(1,3), 16)
        var g = parseInt(baseColor.substring(3,5), 16)
        var b = parseInt(baseColor.substring(5,7), 16)

        if (isDark) {
            // Для темных фонов - светлые, но с оттенком базового цвета
            return "#" +
            ((Math.min(255, r + 100))).toString(16).padStart(2, '0') +
            ((Math.min(255, g + 100))).toString(16).padStart(2, '0') +
            ((Math.min(255, b + 100))).toString(16).padStart(2, '0')
        } else {
            // Для светлых фонов - темные, но с оттенком базового цвета
            return "#" +
            ((Math.max(0, r - 100))).toString(16).padStart(2, '0') +
            ((Math.max(0, g - 100))).toString(16).padStart(2, '0') +
            ((Math.max(0, b - 100))).toString(16).padStart(2, '0')
        }
    }

    // Color themes
    function getColors(theme, customColor) {
        if (theme === "pastel") {
            var pastelColors = {
                bgStart: "#CA8DF2",
                bgEnd: "#9F79F2",
                accent: "#4B53F2",
                light: "#EEDFF2",
                primary: "#4B53F2",
                highlight: "#AEF2F2",
                text: "#2D1B3C",
                button: "#742BD9",
                buttonText: getHarmoniousContrast("#742BD9", true)
            }

            pastelColors.onAccent = getHarmoniousContrast(pastelColors.accent, getBrightness(pastelColors.accent) < 128)
            pastelColors.onPrimary = getHarmoniousContrast(pastelColors.primary, getBrightness(pastelColors.primary) < 128)
            pastelColors.onHighlight = getHarmoniousContrast(pastelColors.highlight, getBrightness(pastelColors.highlight) < 128)
            pastelColors.onLight = getHarmoniousContrast(pastelColors.light, getBrightness(pastelColors.light) < 128)
            pastelColors.onButton = getHarmoniousContrast(pastelColors.button, getBrightness(pastelColors.button) < 128)

            return pastelColors
        } else if (theme === "standard") {
            var standardColors = {
                bgStart: "#2C3E50",
                bgEnd: "#3498DB",
                accent: "#F1C40F",
                light: "#ECF0F1",
                primary: "#E74C3C",
                highlight: "#2ECC71",
                text: "#FFFFFF",
                button: "#34495E",
                buttonText: getHarmoniousContrast("#34495E", true)
            }

            standardColors.onAccent = getHarmoniousContrast(standardColors.accent, getBrightness(standardColors.accent) < 128)
            standardColors.onPrimary = getHarmoniousContrast(standardColors.primary, getBrightness(standardColors.primary) < 128)
            standardColors.onHighlight = getHarmoniousContrast(standardColors.highlight, getBrightness(standardColors.highlight) < 128)
            standardColors.onLight = getHarmoniousContrast(standardColors.light, getBrightness(standardColors.light) < 128)
            standardColors.onButton = getHarmoniousContrast(standardColors.button, getBrightness(standardColors.button) < 128)

            return standardColors
        } else {
            var color = customColor
            var brightness = getBrightness(color)
            var isDark = brightness < 128

            var customColors

            if (isDark) {
                customColors = {
                    bgStart: adjustBrightness(color, 0.8),
                    bgEnd: adjustBrightness(color, 1.0),
                    accent: adjustBrightness(color, 1.3),
                    light: adjustBrightness(color, 1.5),
                    primary: color,
                    highlight: adjustBrightness(color, 1.8),
                    text: getHarmoniousContrast(color, true),
                    button: adjustBrightness(color, 0.9),
                    buttonText: getHarmoniousContrast(adjustBrightness(color, 0.9), true)
                }
            } else {
                customColors = {
                    bgStart: adjustBrightness(color, 0.7),
                    bgEnd: adjustBrightness(color, 0.9),
                    accent: adjustBrightness(color, 0.5),
                    light: color,
                    primary: adjustBrightness(color, 0.4),
                    highlight: adjustBrightness(color, 0.3),
                    text: getHarmoniousContrast(color, false),
                    button: adjustBrightness(color, 0.6),
                    buttonText: getHarmoniousContrast(adjustBrightness(color, 0.6), true)
                }
            }

            customColors.onAccent = getHarmoniousContrast(customColors.accent, getBrightness(customColors.accent) < 128)
            customColors.onPrimary = getHarmoniousContrast(customColors.primary, getBrightness(customColors.primary) < 128)
            customColors.onHighlight = getHarmoniousContrast(customColors.highlight, getBrightness(customColors.highlight) < 128)
            customColors.onLight = getHarmoniousContrast(customColors.light, getBrightness(customColors.light) < 128)
            customColors.onButton = getHarmoniousContrast(customColors.button, getBrightness(customColors.button) < 128)

            return customColors
        }
    }

    function adjustBrightness(color, factor) {
        var r = parseInt(color.substring(1,3), 16)
        var g = parseInt(color.substring(3,5), 16)
        var b = parseInt(color.substring(5,7), 16)

        r = Math.min(255, Math.max(0, Math.round(r * factor)))
        g = Math.min(255, Math.max(0, Math.round(g * factor)))
        b = Math.min(255, Math.max(0, Math.round(b * factor)))

        return "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)
    }

    property var colors: getColors(colorTheme, customBaseColor)

    // Main background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: colors.bgStart }
            GradientStop { position: 1.0; color: colors.bgEnd }
        }
        radius: Math.min(20, parent.width * 0.05)

        // Stars
        Repeater {
            model: 30
            Rectangle {
                x: Math.random() * parent.width
                y: Math.random() * parent.height
                width: Math.random() * 3 + 1
                height: width
                radius: width / 2
                color: "white"
                opacity: Math.random() * 0.5 + 0.3

                PropertyAnimation on y {
                    from: parent.height
                    to: -10
                    duration: Math.random() * 5000 + 3000
                    loops: Animation.Infinite
                }
            }
        }

        // Settings button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            width: 36
            height: 36
            radius: 18
            color: colors.button
            border.width: 2
            border.color: colors.highlight
            z: 100

            Text {
                anchors.centerIn: parent
                text: "⚙️"
                color: colors.buttonText
                font.pixelSize: 20
            }

            MouseArea {
                anchors.fill: parent
                onClicked: settingsWindow.visible = !settingsWindow.visible
            }
        }

        // Main content
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 44
            anchors.margins: 20
            spacing: 10

            // Animated title
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 5

                Text {
                    text: "🍓"
                    color: colors.text
                    font.pixelSize: 28 * uiScale
                    rotation: -titleWave
                }

                Text {
                    text: "BERRY"
                    color: colors.text
                    font.pixelSize: 24 * uiScale
                    font.bold: true
                    font.letterSpacing: 2
                    opacity: glowIntensity * 0.5 + 0.5
                    rotation: titleWave * 0.5
                }

                Text {
                    text: "SLOTS"
                    color: colors.highlight
                    font.pixelSize: 24 * uiScale
                    font.bold: true
                    font.letterSpacing: 2
                    opacity: glowIntensity * 0.5 + 0.5
                    rotation: -titleWave * 0.5
                }

                Text {
                    text: "🍒"
                    color: colors.text
                    font.pixelSize: 28 * uiScale
                    rotation: titleWave
                }
            }

            // Reels
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120 * uiScale
                color: colors.light
                radius: 20
                border.width: 3
                border.color: spinning ? colors.highlight : colors.accent

                Row {
                    anchors.centerIn: parent
                    spacing: 25 * uiScale

                    Repeater {
                        model: 3
                        Rectangle {
                            width: 80 * uiScale
                            height: width
                            radius: 12
                            color: colors.button
                            border.width: 3
                            border.color: spinning ? colors.highlight : colors.primary

                            scale: spinning ? (reelPulse - (index * 0.03)) : 1.0

                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: reels[index]
                                font.pixelSize: 40 * uiScale
                                color: colors.buttonText
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                border.width: spinning ? 2 : 0
                                border.color: colors.highlight
                                opacity: spinning ? glowIntensity * 0.5 : 0
                            }
                        }
                    }
                }
            }

            // Info panel
            GridLayout {
                Layout.fillWidth: true
                columns: freeSpins > 0 ? 3 : 2
                columnSpacing: 5 * uiScale

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    spacing: 2 * uiScale

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "💰 BALANCE"
                        color: colors.accent
                        font.pixelSize: 14 * uiScale
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "$" + credits
                        color: colors.text
                        font.pixelSize: 22 * uiScale
                        font.bold: true
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    spacing: 2 * uiScale

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "🎲 BET"
                        color: colors.accent
                        font.pixelSize: 14 * uiScale
                        font.bold: true
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 100 * uiScale
                        height: 40 * uiScale
                        color: colors.light
                        radius: 8
                        border.width: 2
                        border.color: colors.accent

                        Text {
                            anchors.centerIn: parent
                            text: "$" + bet
                            color: colors.primary
                            font.pixelSize: 18 * uiScale
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (!spinning && !gameOver && !bonusGameActive) betWindow.visible = true
                        }
                    }
                }

                Column {
                    Layout.fillWidth: true
                    visible: freeSpins > 0
                    Layout.alignment: Qt.AlignCenter
                    spacing: 2 * uiScale

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "🎁 FREE"
                        color: colors.highlight
                        font.pixelSize: 14 * uiScale
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: freeSpins
                        color: colors.highlight
                        font.pixelSize: 22 * uiScale
                        font.bold: true
                    }
                }
            }

            // Bet controls
            Flow {
                Layout.fillWidth: true
                spacing: 5 * uiScale

                Repeater {
                    model: ["-10", "½", "2x", "+10", "MAX"]

                    Rectangle {
                        width: (parent.width - 20 * uiScale) / 5
                        height: 35 * uiScale
                        border.width: 2
                        border.color: colors.light
                        color: colors.button
                        radius: 8
                        opacity: enabled ? 1 : 0.5

                        property bool enabled: {
                            if (spinning || gameOver || bonusGameActive) return false
                                if (modelData === "MAX") return credits > 0
                                    if (modelData === "2x") return bet * 2 <= credits
                                        if (modelData.startsWith("+")) return bet + parseInt(modelData) <= credits
                                            if (modelData.startsWith("-")) return bet - parseInt(modelData) >= 1
                                                if (modelData === "½") return credits > 0
                                                    return true
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: colors.buttonText
                            font.pixelSize: 14 * uiScale
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: parent.enabled
                            onClicked: {
                                if (modelData === "-10") bet = Math.max(1, bet - 10)
                                    else if (modelData === "½") bet = Math.max(1, Math.floor(credits / 2))
                                        else if (modelData === "2x") bet = Math.min(credits, bet * 2)
                                            else if (modelData === "+10") bet = Math.min(credits, bet + 10)
                                                else if (modelData === "MAX") bet = credits
                            }
                        }
                    }
                }
            }

            // SPIN button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50 * uiScale
                color: !spinning && (credits >= bet || freeSpins > 0) ? colors.primary : colors.light
                radius: 12
                border.width: 2
                border.color: colors.highlight

                Text {
                    anchors.centerIn: parent
                    text: spinning ? "🌀 SPINNING..." :
                    gameOver ? "🔄 NEW GAME" :
                    freeSpins > 0 ? "🎁 FREE SPIN (" + freeSpins + ")" :
                    "🍓 SPIN $" + bet
                    color: !spinning && (credits >= bet || freeSpins > 0) ? colors.onPrimary : colors.primary
                    font.pixelSize: 18 * uiScale
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: gameOver || (!spinning && !bonusGameActive && (credits >= bet || freeSpins > 0))
                    onClicked: {
                        if (gameOver) {
                            credits = 200
                            bet = 10
                            gameOver = false
                            freeSpins = 0
                            bonusGameActive = false
                            bonusMultiplier = 1
                            result = ""
                            reels = ["🍒", "🍋", "🔔"]
                        } else {
                            startSpin()
                        }
                    }
                }
            }

            // Result display
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45 * uiScale
                property color bgColor: {
                    if (result.includes("🎉")) return colors.highlight
                        if (result.includes("💰")) return colors.primary
                            if (result.includes("💀") || gameOver) return "#FF4444"
                                return colors.light
                }
                color: bgColor

                radius: 10
                border.width: 2
                border.color: colors.accent

                Text {
                    anchors.centerIn: parent
                    anchors.margins: 5
                    width: parent.width - 10
                    text: {
                        if (gameOver) return "💀 GAME OVER"
                            if (bonusGameActive) return "🍓 STRAWBERRY BOMB BONUS!"
                                if (freeSpins > 0) return "🎁 FREE SPINS: " + freeSpins
                                    if (result) return result
                                        return "🍒 PLACE YOUR BET"
                    }
                    color: {
                        if (parent.bgColor === "#FF4444") return getHarmoniousContrast("#FF4444", true)
                            if (parent.bgColor === colors.highlight) return colors.onHighlight
                                if (parent.bgColor === colors.primary) return colors.onPrimary
                                    return colors.onLight
                    }
                    font.pixelSize: 14 * uiScale
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }
    }

    // Settings Window
    Window {
        id: settingsWindow
        width: 370
        height: 500
        visible: false
        flags: Qt.Dialog
        title: "⚙️ Settings"
        color: colors.light

        Flickable {
            anchors.fill: parent
            anchors.margins: 10
            contentWidth: parent.width - 20
            contentHeight: settingsColumn.height + 20
            clip: true

            ColumnLayout {
                id: settingsColumn
                width: parent.width - 20
                spacing: 12

                Text {
                    text: "UI SCALE"
                    color: colors.onLight
                    font.bold: true
                    font.pixelSize: 13
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 30
                        color: colors.button
                        radius: 5
                        Text {
                            anchors.centerIn: parent
                            text: "−"
                            color: colors.buttonText
                            font.pixelSize: 18
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: uiScale = Math.max(0.7, uiScale - 0.1)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: colors.accent
                        radius: 5
                        Text {
                            anchors.centerIn: parent
                            text: Math.round(uiScale * 100) + "%"
                            color: colors.onAccent
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 30
                        color: colors.button
                        radius: 5
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: colors.buttonText
                            font.pixelSize: 18
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: uiScale = Math.min(1.5, uiScale + 0.1)
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 30
                        color: colors.light
                        radius: 5
                        border.width: 1
                        border.color: colors.primary
                        Text {
                            anchors.centerIn: parent
                            text: "RESET"
                            color: colors.onLight
                            font.pixelSize: 10
                            font.bold: true
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: uiScale = 1.0
                        }
                    }
                }

                Text {
                    text: "BONUS GAME"
                    color: colors.onLight
                    font.bold: true
                    font.pixelSize: 13
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        color: !enableBonusGame ? colors.button : colors.light
                        radius: 6
                        border.width: 1
                        border.color: colors.accent

                        Text {
                            anchors.centerIn: parent
                            text: "🚫 OFF"
                            color: !enableBonusGame ? colors.buttonText : colors.onLight
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: enableBonusGame = false
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 35
                        color: enableBonusGame ? colors.highlight : colors.light
                        radius: 6
                        border.width: 1
                        border.color: colors.accent

                        Text {
                            anchors.centerIn: parent
                            text: "🍓 ON"
                            color: enableBonusGame ? colors.onHighlight : colors.onLight
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: enableBonusGame = true
                        }
                    }
                }

                Text {
                    text: "When OFF: 🍓 becomes regular symbol"
                    color: colors.onLight
                    font.pixelSize: 10
                    font.italic: true
                }

                Text {
                    text: "COLOR THEME"
                    color: colors.onLight
                    font.bold: true
                    font.pixelSize: 13
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        width: (parent.width - 16) / 2
                        height: 40
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#CA8DF2" }
                            GradientStop { position: 1.0; color: "#9F79F2" }
                        }
                        radius: 6
                        border.width: colorTheme === "pastel" ? 3 : 1
                        border.color: colorTheme === "pastel" ? "white" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🌸 PASTEL"
                            color: getHarmoniousContrast("#9F79F2", getBrightness("#9F79F2") < 128)
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: colorTheme = "pastel"
                        }
                    }

                    Rectangle {
                        width: (parent.width - 16) / 2
                        height: 40
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#2C3E50" }
                            GradientStop { position: 1.0; color: "#3498DB" }
                        }
                        radius: 6
                        border.width: colorTheme === "standard" ? 3 : 1
                        border.color: colorTheme === "standard" ? "white" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🌊 STANDARD"
                            color: getHarmoniousContrast("#3498DB", getBrightness("#3498DB") < 128)
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: colorTheme = "standard"
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 40
                        color: customBaseColor
                        radius: 6
                        border.width: colorTheme === "custom" ? 3 : 1
                        border.color: colorTheme === "custom" ? colors.accent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "🎨 CUSTOM"
                            color: getHarmoniousContrast(customBaseColor, getBrightness(customBaseColor) < 128)
                            font.pixelSize: 11
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: colorTheme = "custom"
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    visible: colorTheme === "custom"
                    spacing: 8

                    Text {
                        text: "CHOOSE COLOR"
                        color: colors.onLight
                        font.bold: true
                        font.pixelSize: 11
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
                            "#FFEAA7", "#D4A5A5", "#9B59B6", "#3498DB",
                            "#E67E22", "#2ECC71", "#E74C3C", "#F1C40F"]

                            Rectangle {
                                width: 30
                                height: 30
                                radius: 15
                                color: modelData
                                border.width: customBaseColor === modelData ? 3 : 1
                                border.color: customBaseColor === modelData ? "white" : "transparent"

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        customBaseColor = modelData
                                        colorTheme = "custom"
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        QQC2.TextField {
                            id: colorInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            placeholderText: "#RRGGBB"
                            text: customBaseColor
                            background: Rectangle {
                                color: "white"
                                radius: 4
                            }
                            font.pixelSize: 11
                        }

                        Rectangle {
                            width: 30
                            height: 30
                            radius: 4
                            color: colorInput.text

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var colorText = colorInput.text
                                    if (/^#[0-9A-F]{6}$/i.test(colorText)) {
                                        customBaseColor = colorText
                                        colorTheme = "custom"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 45
                            height: 30
                            color: colors.button
                            radius: 4
                            Text {
                                anchors.centerIn: parent
                                text: "SET"
                                color: colors.buttonText
                                font.pixelSize: 10
                                font.bold: true
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var colorText = colorInput.text
                                    if (/^#[0-9A-F]{6}$/i.test(colorText)) {
                                        customBaseColor = colorText
                                        colorTheme = "custom"
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.topMargin: 10
                    color: colors.primary
                    radius: 6
                    Text {
                        anchors.centerIn: parent
                        text: "CLOSE"
                        color: colors.onPrimary
                        font.pixelSize: 13
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: settingsWindow.visible = false
                    }
                }
            }
        }
    }

    // Bet Window
    Window {
        id: betWindow
        width: 300
        height: 200
        visible: false
        flags: Qt.Dialog
        title: "Enter bet amount"
        color: colors.light

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 30

            QQC2.TextField {
                id: betInput
                Layout.fillWidth: true
                placeholderText: "1 - " + credits
                validator: IntValidator { bottom: 1; top: credits }
                text: bet
                background: Rectangle {
                    color: "white"
                    radius: 5
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    height: 35
                    color: colors.primary
                    radius: 5
                    Text {
                        anchors.centerIn: parent
                        text: "OK"
                        color: colors.onPrimary
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var newBet = parseInt(betInput.text)
                            if (!isNaN(newBet) && newBet >= 1 && newBet <= credits) {
                                bet = newBet
                                betWindow.visible = false
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 35
                    color: colors.button
                    radius: 5
                    Text {
                        anchors.centerIn: parent
                        text: "CANCEL"
                        color: colors.buttonText
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: betWindow.visible = false
                    }
                }
            }
        }
    }

    // Berry Bonus Game Window
    Window {
        id: berryBonusWindow
        width: Math.min(650, screen.width * 0.8)
        height: Math.min(750, screen.height * 0.8)
        visible: showBerryBonus
        flags: Qt.Dialog
        title: "🍓 STRAWBERRY BOMB BONUS"
        color: colors.bgStart

        property real scaleFactor: Math.min(width / 650, height / 750, 1.0)

        // Обработка закрытия крестиком
        onClosing: {
            winTimer.stop()
            closeTimer.stop()
            var win = currentWin
            var collected = berriesCollected
            var gameOverFlag = bonusGameOver
            if (collected > 0 && !gameOverFlag) {
                credits += win
                result = "🍓 Cashed out $" + win
            } else if (!gameOverFlag) {
                result = "😢 Bonus game skipped"
            }
            showBerryBonus = false
            bonusGameActive = false
            resetBonusGame()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15 * berryBonusWindow.scaleFactor
            spacing: 10 * berryBonusWindow.scaleFactor

            // Header (без изменений)
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 15 * berryBonusWindow.scaleFactor
                Text { text: "🍓"; color: colors.text; font.pixelSize: 50 * berryBonusWindow.scaleFactor }
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    Text { text: "STRAWBERRY BOMB"; color: colors.highlight; font.pixelSize: 22 * berryBonusWindow.scaleFactor; font.bold: true }
                    Text { text: "5 sweet 🍓 | 3 rotten 💣"; color: colors.accent; font.pixelSize: 12 * berryBonusWindow.scaleFactor }
                }
                Text { text: "💣"; color: colors.text; font.pixelSize: 50 * berryBonusWindow.scaleFactor }
            }

            // Status panel (без изменений)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60 * berryBonusWindow.scaleFactor
                color: colors.button
                radius: 10 * berryBonusWindow.scaleFactor
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8 * berryBonusWindow.scaleFactor
                    spacing: 10 * berryBonusWindow.scaleFactor
                    Column {
                        Layout.fillWidth: true
                        Text { text: "🍓 " + berriesCollected + "/5"; color: colors.buttonText; font.pixelSize: 18 * berryBonusWindow.scaleFactor; font.bold: true }
                        Text { text: "COLLECTED"; color: colors.buttonText; opacity: 0.7; font.pixelSize: 9 * berryBonusWindow.scaleFactor }
                    }
                    Column {
                        Layout.fillWidth: true
                        Text { text: "💣 " + bombsLeft; color: getHarmoniousContrast("#FF4444", true); font.pixelSize: 18 * berryBonusWindow.scaleFactor; font.bold: true }
                        Text { text: "ROTTEN LEFT"; color: colors.buttonText; opacity: 0.7; font.pixelSize: 9 * berryBonusWindow.scaleFactor }
                    }
                    Column {
                        Layout.fillWidth: true
                        Text { text: "$" + currentWin; color: colors.accent; font.pixelSize: 18 * berryBonusWindow.scaleFactor; font.bold: true }
                        Text { text: "CURRENT"; color: colors.buttonText; opacity: 0.7; font.pixelSize: 9 * berryBonusWindow.scaleFactor }
                    }
                }
            }

            // Game area — используем состояния
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.55
                color: colors.button
                radius: 15 * berryBonusWindow.scaleFactor
                border.width: 2; border.color: colors.accent

                Text {
                    x: 10 * berryBonusWindow.scaleFactor; y: 10 * berryBonusWindow.scaleFactor
                    text: "🍓"; color: colors.buttonText; opacity: 0.3; font.pixelSize: 40 * berryBonusWindow.scaleFactor
                }

                Grid {
                    anchors.centerIn: parent
                    columns: 4
                    spacing: 15 * berryBonusWindow.scaleFactor

                    Repeater {
                        model: 8

                        // Элемент ягоды с состояниями
                        Item {
                            id: berryItem
                            width: 70 * berryBonusWindow.scaleFactor
                            height: 70 * berryBonusWindow.scaleFactor

                            // Вычисляем состояние на основе массивов
                            state: {
                                if (!root.berryStates[index]) return "hidden"
                                    return root.berryWasBomb[index] ? "bomb" : "sweet"
                            }

                            Rectangle {
                                id: berryRect
                                anchors.fill: parent
                                radius: width / 2
                                border.width: 3
                            }

                            Text {
                                id: berryText
                                anchors.centerIn: parent
                                font.pixelSize: 40 * berryBonusWindow.scaleFactor
                            }

                            states: [
                                State {
                                    name: "hidden"
                                    PropertyChanges {
                                        target: berryRect
                                        color: colors.light
                                        border.color: colors.accent
                                        opacity: 1.0
                                        rotation: 0
                                    }
                                    PropertyChanges {
                                        target: berryText
                                        text: "🍓"
                                        color: colors.onLight
                                    }
                                },
                                State {
                                    name: "sweet"
                                    PropertyChanges {
                                        target: berryRect
                                        color: "#FF69B4"
                                        border.color: "#FF1493"
                                    }
                                    PropertyChanges {
                                        target: berryText
                                        text: "✓"
                                        color: "white"
                                    }
                                },
                                State {
                                    name: "bomb"
                                    PropertyChanges {
                                        target: berryRect
                                        color: "#FF4444"
                                        border.color: "#FF0000"
                                    }
                                    PropertyChanges {
                                        target: berryText
                                        text: "💥"
                                        color: "white"
                                    }
                                }
                            ]

                            transitions: [
                                Transition {
                                    from: "hidden"; to: "sweet"
                                    SequentialAnimation {
                                        PropertyAnimation { target: berryRect; property: "scale"; from: 1.0; to: 1.3; duration: 150 }
                                        PropertyAnimation { target: berryRect; property: "scale"; from: 1.3; to: 1.0; duration: 150 }
                                        ColorAnimation { target: berryRect; property: "color"; duration: 100 }
                                    }
                                },
                                Transition {
                                    from: "hidden"; to: "bomb"
                                    ParallelAnimation {
                                        PropertyAnimation { target: berryRect; property: "scale"; from: 1.0; to: 1.8; duration: 200 }
                                        PropertyAnimation { target: berryRect; property: "rotation"; from: 0; to: 360; duration: 200 }
                                        ColorAnimation { target: berryRect; property: "color"; duration: 100 }
                                    }
                                    PropertyAnimation { target: berryRect; property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
                                }
                            ]

                            MouseArea {
                                anchors.fill: parent
                                enabled: !root.berryStates[index] && !bonusGameOver
                                onClicked: {
                                    if (bonusGameOver || root.berryStates[index]) return

                                        var isRotten = Math.random() < (bombsLeft / berriesLeft)

                                        // Обновляем массивы с созданием новых копий для реактивности
                                        var newStates = root.berryStates.slice()
                                        newStates[index] = true
                                        root.berryStates = newStates

                                        var newBombStates = root.berryWasBomb.slice()
                                        newBombStates[index] = isRotten
                                        root.berryWasBomb = newBombStates

                                        // Уменьшаем общее количество оставшихся ягод
                                        berriesLeft--

                                        if (isRotten) {
                                            bombsLeft--
                                            // Сразу завершаем игру, блокируем клики
                                            bonusGameOver = true
                                            result = "💥 ROTTEN BERRY! You lost everything!"
                                            closeTimer.start()
                                        } else {
                                            berriesCollected++
                                            currentWin = bet * berriesCollected

                                            if (berriesCollected === 5) {
                                                bonusGameOver = true
                                                credits += currentWin
                                                bonusMultiplier = berriesCollected
                                                result = "🎉 YOU WON! +$" + currentWin + " (x" + berriesCollected + ")"
                                                winTimer.start()
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }

            // Control buttons (без изменений, но убраны лишние анимации)
            RowLayout {
                Layout.fillWidth: true
                spacing: 10 * berryBonusWindow.scaleFactor

                Rectangle {
                    Layout.fillWidth: true
                    height: 40 * berryBonusWindow.scaleFactor
                    color: colors.highlight
                    radius: 8 * berryBonusWindow.scaleFactor
                    enabled: berriesCollected > 0 && !bonusGameOver
                    opacity: enabled ? 1.0 : 0.5

                    Text {
                        anchors.centerIn: parent
                        text: "🍓 TAKE $" + currentWin
                        color: colors.onHighlight
                        font.pixelSize: 14 * berryBonusWindow.scaleFactor
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: berriesCollected > 0 && !bonusGameOver
                        onClicked: {
                            credits += currentWin
                            bonusMultiplier = berriesCollected
                            result = "🎉 Won $" + currentWin + " (x" + berriesCollected + ")"
                            showBerryBonus = false
                            berryBonusWindow.visible = false
                            bonusGameActive = false
                            resetBonusGame()
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 80 * berryBonusWindow.scaleFactor
                    height: 40 * berryBonusWindow.scaleFactor
                    color: colors.button
                    radius: 8 * berryBonusWindow.scaleFactor

                    Text {
                        anchors.centerIn: parent
                        text: "❌ EXIT"
                        color: colors.buttonText
                        font.pixelSize: 12 * berryBonusWindow.scaleFactor
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (berriesCollected > 0 && !bonusGameOver) {
                                credits += currentWin
                                result = "🍓 Cashed out $" + currentWin
                            } else {
                                result = "😢 Bonus game skipped"
                            }
                            showBerryBonus = false
                            berryBonusWindow.visible = false
                            bonusGameActive = false
                            resetBonusGame()
                        }
                    }
                }
            }
        }
    }

    // Game functions
    function startSpin() {
        if (spinning) return

            if (freeSpins > 0) {
                freeSpins--
            } else {
                if (credits < bet) return
                    credits -= bet
            }

            spinning = true
            result = ""
            spinTimer.start()
            stopTimer.start()
    }

    function resetBonusGame() {
        console.log("Resetting bonus game")
        berriesCollected = 0
        berriesLeft = 8
        bombsLeft = 3
        currentWin = 0
        bonusGameOver = false
        bonusMessage = ""
        berryStates = [false, false, false, false, false, false, false, false]
        berryWasBomb = [false, false, false, false, false, false, false, false]
        bonusMultiplier = 1
    }

    function checkWin() {
        var winAmount = 0

        if (enableBonusGame) {
            if (reels[0] === "🍓" || reels[1] === "🍓" || reels[2] === "🍓") {
                if (reels.filter(s => s === "🍓").length >= 2) {
                    resetBonusGame()
                    bonusGameActive = true
                    showBerryBonus = true
                    berryBonusWindow.visible = true
                    result = "🍓 STRAWBERRY BOMB BONUS!"
                    return
                }
            }
        } else {
            if (reels[0] === "🍒" || reels[1] === "🍒" || reels[2] === "🍒") {
                var cherryCount = reels.filter(s => s === "🍒").length
                if (cherryCount === 3) {
                    winAmount = bet * 15
                    result = "🍒 CHERRY JACKPOT! +$" + winAmount
                } else if (cherryCount === 2) {
                    winAmount = bet * 5
                    result = "🍒 CHERRY MATCH! +$" + winAmount
                }
            }
        }

        if (reels.filter(s => s === "🎰").length >= 2) {
            freeSpins += 3
            result = "🎁 +3 FREE SPINS!"
        }

        if (reels.includes("🍓")) {
            var strawberryCount = reels.filter(s => s === "🍓").length
            winAmount = bet * strawberryCount * 2
            result = "🍓 STRAWBERRIES! x" + strawberryCount + " = $" + winAmount
        } else if (reels.includes("🫐")) {
            var blueberryCount = reels.filter(s => s === "🫐").length
            winAmount = bet * blueberryCount * bonusMultiplier
            result = "🫐 BLUEBERRIES! x" + blueberryCount + " = $" + winAmount
        } else if (reels[0] === reels[1] && reels[1] === reels[2]) {
            winAmount = bet * (reels[0] === "7️⃣" ? 50 : 10) * bonusMultiplier
            result = "💰 JACKPOT! x" + bonusMultiplier + " = $" + winAmount
        } else if (reels[0] === reels[1] || reels[1] === reels[2] || reels[0] === reels[2]) {
            winAmount = bet * 3 * bonusMultiplier
            result = "⭐ MATCH! x" + bonusMultiplier + " = $" + winAmount
        } else {
            result = "😢 Try again!" + (bonusMultiplier > 1 ? " (x" + bonusMultiplier + ")" : "")
        }

        if (winAmount > 0) {
            credits += winAmount
        }
    }
}
