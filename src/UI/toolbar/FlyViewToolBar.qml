/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtPositioning 5.15

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Palette
import QGroundControl.MultiVehicleManager
import QGroundControl.ScreenTools
import QGroundControl.Controllers

Rectangle {
    id:     _root
    width:  parent.width
    height: ScreenTools.toolbarHeight
    color:  qgcPal.toolbarBackground

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple

    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator();
    }

    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    Rectangle {
        anchors.fill: viewButtonRow
        
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0;                                     color: _mainStatusBGColor }
            GradientStop { position: currentButton.x + currentButton.width; color: _mainStatusBGColor }
            GradientStop { position: 1;                                     color: _root.color }
        }
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/res/QGCLogoFull.svg"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
        }

        MainStatusIndicator {
            id: mainStatusIndicator
            Layout.preferredHeight: viewButtonRow.height
        }

        QGCButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            _activeVehicle && _communicationLost
        }
    }

    QGCFlickable {
        id:                     toolsFlickable
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.rightMargin:    ScreenTools.defaultFontPixelWidth / 2
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           toolIndicators.width
        flickableDirection:     Flickable.HorizontalFlick

        FlyViewToolBarIndicators { id: toolIndicators }
    }

    //-------------------------------------------------------------------------
    //-- Branding Logo
    Image {
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    QGroundControl.settingsManager.brandImageSettings.visible && _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   QGroundControl.settingsManager.brandImageSettings.visible && _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      brandImageIndoor()
        property string _brandImageOutdoor:     brandImageOutdoor()

        function brandImageIndoor() {
            if (_userBrandingIndoor) {
                return _userBrandImageIndoor
            } else {
                if (_userBrandingOutdoor) {
                    return _userBrandImageOutdoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageIndoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
                    }
                }
            }
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) {
                return _userBrandImageOutdoor
            } else {
                if (_userBrandingIndoor) {
                    return _userBrandImageIndoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageOutdoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
                    }
                }
            }
        }
    }

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
    //custom toolbar widgets
    Button {
        id: topRightPopupButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        text: "Info"
        onClicked: {
            messageDialog.open()

        }
    }
    MessageDialog {
        id: messageDialog
        title: "Hello"
        text: "This is a popup message!"
    }

    Button {
        id: modeChangeButton
        anchors.top: parent.top
        anchors.right: topRightPopupButton.left
        anchors.topMargin: 0
        anchors.rightMargin: 8
        text: "Set Guided"
        enabled: QGroundControl.multiVehicleManager.activeVehicle !== null

        onClicked: {
            var vehicle = QGroundControl.multiVehicleManager.activeVehicle
            if (vehicle) {
                            // Change mode to "Loiter" (or any supported mode)
                            vehicle.setFlightMode("Guided")
                            modeChangeDialog.open()
                        }
         }
    }
        MessageDialog {
                    id: modeChangeDialog
                    title: "Mode Change"
                    text: "Requested mode change to Guided."
                    // icon: StandardIcon.Information
                }

        Button {
            id: armDisarmButton
            anchors.top: parent.top
            anchors.right: modeChangeButton.left
            anchors.topMargin: 0
            anchors.rightMargin: 8
            text: "Arm/Disarm"
            enabled: QGroundControl.multiVehicleManager.activeVehicle !== null

            onClicked: {
                var vehicle = QGroundControl.multiVehicleManager.activeVehicle
                if (vehicle) {
                    if (!vehicle.armed) {
                        vehicle.armed = true    // Arm the vehicle
                        armDisarmDialog.text = "Vehicle is now ARMED."
                    } else {
                        vehicle.armed = false   // Disarm the vehicle
                        armDisarmDialog.text = "Vehicle is now DISARMED."
                    }
                    armDisarmDialog.open()
                }
            }
        }

        MessageDialog {
            id: armDisarmDialog
            title: "Arm/Disarm Status"
            // text is set dynamically
        }


        Button {
            id: guidedTakeoffDialogBtn
            text: "Guided Takeoff"
            anchors.right: armDisarmButton.left
            anchors.top: controlDialog.bottom
            anchors.topMargin: 10
            onClicked: {
                guidedTakeoffDialog.open()
            }
        }

        Dialog {
            id: guidedTakeoffDialog
            title: "Guided Takeoff Input"
            modal: true
            standardButtons: Dialog.Ok

            Column {
                spacing: 12
                padding: 20

                TextField {
                    id: guidedLat
                    placeholderText: "Latitude"
                    width: 200
                }

                TextField {
                    id: guidedLon
                    placeholderText: "Longitude"
                    width: 200
                }

                TextField {
                    id: guidedAlt
                    placeholderText: "Altitude (m)"
                    width: 200
                }

                Button {
                    text: "Go to location"
                    onClicked: {
                        var lat = parseFloat(guidedLat.text.trim())
                        var lon = parseFloat(guidedLon.text.trim())
                        var alt = parseFloat(guidedAlt.text.trim())
                        var vehicle = QGroundControl.multiVehicleManager.activeVehicle

                        if (!vehicle) {
                            console.log("No active vehicle connected.")
                            return
                        }

                        if (isNaN(lat) || isNaN(lon) || isNaN(alt)) {
                            console.log("Invalid input: Enter valid Latitude, Longitude, and Altitude.")
                            return
                        }

                        console.log("Requesting Guided mode...")
                        vehicle.flightMode="Guided"

                        console.log("Requesting Arm...")
                        vehicle.armed=true
                        vehicle.guidedModeTakeoff(alt)

                        var takeoffTimer = Qt.createQmlObject(`
                            import QtQuick 2.0
                            Timer {
                                interval: 10
                                repeat: true
                                running: true
                                onTriggered: {
                                    var v = QGroundControl.multiVehicleManager.activeVehicle
                                    if (v && v.armed && v.flightMode === "Guided") {
                                        console.log("Armed and in Guided mode. Taking off to " + ${alt})

                                        v.guidedModeGotoLocation(QtPositioning.coordinate(${lat}, ${lon}, ${alt}))
                                        stop()
                                        guidedTakeoffDialog.close()
                                    } else {
                                        console.log("Waiting for vehicle to be armed and in Guided mode...")
                                    }
                                }
                            }
                        `, guidedTakeoffDialog)
                    }
                }




            }
        }


        // import QtQuick 2.15
        // import QtQuick.Controls 2.15
        // import QtPositioning 5.15











}












