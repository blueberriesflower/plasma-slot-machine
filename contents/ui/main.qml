import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // Устанавливаем предпочтительный и минимальный размер
    property alias minimumWidth: root.implicitWidth
    property alias minimumHeight: root.implicitHeight
    implicitWidth: 320
    implicitHeight: 480

    // Игровые переменные
    property var symbols: ["🍒", "🍋", "🔔", "⭐", "7️⃣", "💎"]
    property var reels: ["🍒", "🍋", "🔔"]
    property int credits: 200
    property int bet: 10
    property bool spinning: false
    property string result: ""
    property bool gameOver: false

    // Таймеры
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
        }
    }

    Timer {
        id: stopTimer
        interval: 1500
        running: false
        onTriggered: {
            spinTimer.stop()
            spinning = false
            checkWin()
            if (credits <= 0) gameOver = true
        }
    }

    // Основной фон
    Rectangle {
        anchors.fill: parent
        color: "#CA8DF2"
        radius: 16

        // Акцентная полоска сверху
        Rectangle {
            width: parent.width
            height: 4
            color: "#4962F2"
            anchors.top: parent.top
            anchors.topMargin: 15
        }

        // Основной контент
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // Заголовок
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "CASINO SLOTS"
                color: "#4962F2"
                font.pixelSize: 18
                font.bold: true
                font.letterSpacing: 1
            }

            // Барабаны
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#CA8DF2"
                radius: 12
                border.width: 2
                border.color: spinning ? "#8DD5F2" : "#EEDFF2"

                Row {
                    anchors.centerIn: parent
                    spacing: 20

                    // Барабан 1
                    Rectangle {
                        width: 70
                        height: 70
                        radius: 10
                        color: "#9F79F2"
                        border.width: 3
                        border.color: spinning ? "#4962F2" : "#742BD9"

                        Text {
                            anchors.centerIn: parent
                            text: reels[0]
                            font.pixelSize: 32
                            color: "white"
                        }
                    }

                    // Барабан 2
                    Rectangle {
                        width: 70
                        height: 70
                        radius: 10
                        color: "#9F79F2"
                        border.width: 3
                        border.color: spinning ? "#4962F2" : "#742BD9"

                        Text {
                            anchors.centerIn: parent
                            text: reels[1]
                            font.pixelSize: 32
                            color: "white"
                        }
                    }

                    // Барабан 3
                    Rectangle {
                        width: 70
                        height: 70
                        radius: 10
                        color: "#9F79F2"
                        border.width: 3
                        border.color: spinning ? "#4962F2" : "#742BD9"

                        Text {
                            anchors.centerIn: parent
                            text: reels[2]
                            font.pixelSize: 32
                            color: "white"
                        }
                    }
                }
            }

            // Информация о игре
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 12

                // Кредиты
                Column {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "BALANCE"
                        color: "#4962F2"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: "$" + credits
                        color: credits > 100 ? "#80D2F2" : credits > 50 ? "#CA8DF2" : "#9F79F2"
                        font.pixelSize: 20
                        font.bold: true
                    }
                }

                // Ставка
                Column {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "CURRENT BET"
                        color: "#4962F2"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: "$" + bet
                        color: "#80D2F2"
                        font.pixelSize: 20
                        font.bold: true
                    }
                }

                // Статус
                Column {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "STATUS"
                        color: "#4962F2"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: spinning ? "SPINNING..." :
                        gameOver ? "GAME OVER" : "READY"
                        color: spinning ? "#742BD9" :
                        gameOver ? "#742BD9" : "#742BD9"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }

            // Управление ставкой
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#9F79F2"
                radius: 10

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // Уменьшить
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 6
                        color: bet > 1 && !spinning && !gameOver ? "#8b5cf6" : "#8b5cf6"

                        Text {
                            anchors.centerIn: parent
                            text: "−5"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: bet > 1 && !spinning && !gameOver
                            onClicked: {
                                if (bet > 5) {
                                    bet -= 5;
                                } else if (bet > 1) {
                                    bet = 1;
                                }
                            }
                        }
                    }

                    // Отображение ставки
                    Text {
                        text: "BET: $" + bet
                        color: "#80D2F2"
                        font.pixelSize: 15
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Увеличить
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 6
                        color: bet < credits && !spinning && !gameOver ? "#8b5cf6" : "#8b5cf6"

                        Text {
                            anchors.centerIn: parent
                            text: "+5"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: bet < credits && !spinning && !gameOver
                            onClicked: {
                                var maxBet = credits;
                                if (bet < maxBet) {
                                    bet = Math.min(maxBet, bet + 5);
                                }
                            }
                        }
                    }

                    // MAX
                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 30
                        radius: 6
                        color: credits > 0 && !spinning && !gameOver ? "#8b5cf6" : "#9F79F2"

                        Text {
                            anchors.centerIn: parent
                            text: "MAX"
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: credits > 0 && !spinning && !gameOver
                            onClicked: bet = credits
                        }
                    }
                }
            }

            // Кнопка SPIN/RESTART
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: 10
                color: {
                    if (spinning) return "#8b5cf6";
                    if (gameOver) return "#3b82f6";
                    if (credits >= bet) return "#9F79F2";
                    return "#4962F2";
                }

                Text {
                    anchors.centerIn: parent
                    text: spinning ? "🌀 SPINNING..." :
                    gameOver ? "🔄 RESTART GAME" :
                    "🎰 SPIN ($" + bet + ")"
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: (gameOver) || (!spinning && credits >= bet)
                    onClicked: {
                        if (gameOver) {
                            credits = 200
                            bet = 10
                            gameOver = false
                            result = ""
                            reels = ["🍒", "🍋", "🔔"]
                        } else {
                            startSpin()
                        }
                    }
                }
            }

            // Результат
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#9F79F2"
                radius: 8
                border.width: 2
                border.color: result.includes("JACKPOT") ? "#4962F2" :
                result.includes("WIN") ? "#4951F2" :
                result.includes("MATCH") ? "#3b82f6" :
                gameOver ? "#DC8DF2" : "#EAAEF2"

                Text {
                    anchors.centerIn: parent
                    text: result || (gameOver ? "💀 GAME OVER" : "")
                    color: {
                        if (gameOver) return "#EAAEF2";
                        if (result.includes("JACKPOT")) return "#4962F2";
                        if (result.includes("WIN")) return "#4962F2";
                        if (result.includes("MATCH")) return "#3b82f6";
                        return "#EAAEF2";
                    }
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            // Сообщение о GAME OVER
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: "#ef444420"
                radius: 6
                border.width: 1
                border.color: "#ef444460"
                visible: gameOver && credits <= 0

                Text {
                    anchors.centerIn: parent
                    text: "💸 Out of credits!"
                    color: "#9F79F2"
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }
    }

    // Функция старта вращения
    function startSpin() {
        if (spinning || credits < bet) return

            credits -= bet
            spinning = true
            result = ""

            spinTimer.start()
            stopTimer.start()
    }

    // Проверка выигрыша
    function checkWin() {
        // Джекпот
        if (reels[0] === "7️⃣" && reels[1] === "7️⃣" && reels[2] === "7️⃣") {
            var jackpot = bet * 50
            credits += jackpot
            result = "🎉 JACKPOT! +$" + jackpot
        }
        // Три одинаковых
        else if (reels[0] === reels[1] && reels[1] === reels[2]) {
            var win = bet * 10
            credits += win
            result = "💰 BIG WIN! +$" + win
        }
        // Два одинаковых
        else if (reels[0] === reels[1] || reels[1] === reels[2] || reels[0] === reels[2]) {
            var smallWin = bet * 3
            credits += smallWin
            result = "⭐ MATCH! +$" + smallWin
        }
        // Проигрыш
        else {
            result = "😢 Try again!"
        }
    }
}
