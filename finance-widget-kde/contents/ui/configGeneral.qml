import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configRoot
    
    property alias cfg_tickers: tickersField.text
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    
    Kirigami.FormLayout {
        QQC2.TextField {
            id: tickersField
            Kirigami.FormData.label: "Tickers"
            placeholderText: "i.e: BTC-USD,ETH-USD,AAPL,PETR4.SA"
        }
        
        QQC2.Label {
            text: "Write the tickers and separate by commas"
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.7
            Layout.fillWidth: true
        }
        
        Item {
            Kirigami.FormData.isSection: true
        }
        
        QQC2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: "Refresh (minutes):"
            from: 1
            to: 60
            value: 5
        }
        
        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Ticker Examples"
        }
        
        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            
            QQC2.Label {
                text: "<b>Brazillian Stocks</b>"
                textFormat: Text.RichText
            }

            QQC2.Label {
                text: "^BVSP, PETR4.SA, VALE3.SA, ITUB4.SA, BBDC4.SA, MGLU3.SA"
                opacity: 0.7
                wrapMode: Text.WordWrap
            }

            QQC2.Label {
				text: "<b>Indian stocks</b>"
				textFormat: Text.RichText
			}

            QQC2.Label {
				text: "^BSESN, RELIANCE.NS, TCS.NS, HDFCBANK.NS, SBIN.NS"
				opacity: 0.7
				wrapMode: Text.WordWrap
			}

            QQC2.Label {
                text: "<b>Wall Street stocks</b>"
                textFormat: Text.RichText
            }

            QQC2.Label {
                text: "AAPL, GOOGL, MSFT, TSLA, NVDA, AMZN"
                opacity: 0.7
                wrapMode: Text.WordWrap
            }
            
            QQC2.Label {
                text: "<b>Crypto</b>"
                textFormat: Text.RichText
            }

            QQC2.Label {
                text: "BTC-USD, ETH-USD, ADA-USD, SOL-USD, DOGE-USD"
                opacity: 0.7
                wrapMode: Text.WordWrap
            }
        }
    }
}
