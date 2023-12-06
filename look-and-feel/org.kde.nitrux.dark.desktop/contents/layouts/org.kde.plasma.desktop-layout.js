var plasma = getApiVersion(1)

var activityId = activityIds[0]

var activity = desktopById(activityId)
activity.currentConfigGroup = ["General"]
activity.writeConfig("ToolBoxButtonState", "bottomright")
activity.writeConfig("showToolbox", false)

var desktopsArray = desktopsForActivity(currentActivity());
for( var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.image';
}

// // Create top pannel
// panel = new plasma.Panel
// panel.location = "top"
// panel.alignment = "center"
// 
// // Add widgets
// var menu = panel.addWidget("org.kde.plasma.nomadmenu")
// 
// // Configure favorite apps
// menu.currentConfigGroup = ["General"]
// menu.writeConfig("favoriteApps", "systemsettings.desktop,org.kde.dolphin.desktop,org.kde.kate.desktop,chromium-browser.desktop")
//     // Configure menu shortcut
// menu.currentConfigGroup = ["Shortcuts"]
// menu.writeConfig("global", "Alt+F1")
// 
// panel.addWidget("org.nomad-shell.panel.separator")
// 
// panel.addWidget("org.kde.plasma.appmenu")
// panel.addWidget("org.kde.plasma.panelspacer")
// var systray = panel.addWidget("org.nomad.systemtray")
// 
// // Don't load widgets overwriten in nomad
// var systrayContainmentId = systray.readConfig('SystrayContainmentId')
// var systrayContainer = desktopById(systrayContainmentId)
// systrayContainer.currentConfigGroup = ['General']
// systrayContainer.writeConfig("knownItems", "org.kde.plasma.networkmanagement,org.kde.plasma.notifications,org.kde.plasma.mediacontroller,org.kde.plasma.devicenotifier,org.kde.plasma.volume")
// 
// var clock = panel.addWidget("org.nomad.clock")
//     // Configure font
// clock.currentConfigGroup = ["Appearance"]
// clock.writeConfig("fontFamily", "Homenaje")
// 
// panel.locked = true
