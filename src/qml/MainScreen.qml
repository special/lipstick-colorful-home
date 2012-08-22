
// This file is part of colorful-home, a nice user experience for touchscreens.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// Copyright (c) 2011, Tom Swindell <t.swindell@rubyx.co.uk>
// Copyright (c) 2012, Timur Kristóf <venemo@fedoraproject.org>

import QtQuick 1.1
import QtMobility.sensors 1.2
import org.nemomobile.lipstick 0.1
import "./components"
import "./pages"

Item {
    id: mainScreen
    width: initialSize.width
    height: initialSize.height

    OrientationSensor {
        id: orientationSensor
        active: true

        onReadingChanged: {
            if (reading.orientation === OrientationReading.TopUp && !desktop.isPortrait) {
                // The top of the device is upwards - meaning: portrait
                desktop.isPortrait = true;
            }
            if (reading.orientation === OrientationReading.RightUp && desktop.isPortrait) {
                // The right side of the device is upwards - meaning: landscape
                desktop.isPortrait = false;
            }
        }
    }

    Item {
        property bool isPortrait: false

        id: desktop
        anchors.top: parent.top
        anchors.left: parent.left
        width: isPortrait ? parent.height : parent.width
        height: isPortrait ? parent.width : parent.height
        transform: Rotation {
            id: desktopRotation
            origin.x: mainScreen.height / 2
            origin.y: mainScreen.height / 2
            angle: desktop.isPortrait ? -90 : 0
        }

        // The background image
        Image {
            id: background
            source: ':/images/background.jpg'
            fillMode: Image.PreserveAspectFit
            width: desktop.isPortrait ? undefined : parent.width
            height: desktop.isPortrait ? parent.height : undefined
            anchors.left: parent.left
            anchors.bottom: parent.bottom
        }

        // Black overlay for making white text readable
        Rectangle {
            id: overlay
            anchors.fill: parent
            opacity: 0.6
            color: 'black'
        }

        // Black background for the status bar (until it's loaded)
        Rectangle {
            color: 'black'
            anchors.fill: statusBar
            z: 10
        }

        // System status bar
        StatusBar {
            id: statusBar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            isPortrait: desktop.isPortrait
            z: 10
        }

        // Tab bar on the top for a quick way of selecting a page
        TabBar {
            id: tabBar
            anchors {
                top: statusBar.bottom
                left: parent.left
                right: parent.right
            }
            z: 10
            model: ListModel {
                ListElement { iconUrl: ":/images/icons/apps.png" }
                ListElement { iconUrl: ":/images/icons/multitask.png" }
            }

            onCurrentIndexChanged: pager.currentIndex = tabBar.currentIndex
        }

        // Pager for swiping between different pages of the home screen
        Pager {
            id: pager
            anchors {
                top: tabBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            pages: VisualItemModel {
                AppLauncher {
                    id: launcher
                    width: pager.width
                    height: pager.height
                }
                AppSwitcher {
                    id: switcher
                    width: pager.width
                    height: pager.height
                    columnNumber: 2
                }
            }
            onCurrentIndexChanged: tabBar.currentIndex = pager.currentIndex
        }
    }
}