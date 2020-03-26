//
//  AppDelegate.swift
//  ChromeCastPOC
//
//  Created by Ventuno Technologies on 24/03/20.
//  Copyright © 2020 Ventuno Technologies. All rights reserved.
//

import UIKit
import CoreData
import GoogleCast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID
    let kDebugLoggingEnabled = true

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        window?.clipsToBounds = true
        window = UIWindow(frame: UIScreen.main.bounds)
        
        setupChromeCastSDK()
        return true
    }


}

extension AppDelegate{
    
    private func setupChromeCastSDK(){

       // Set your receiver application ID.
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(options)

        // Configure widget styling.
        // Theme using UIAppearance.
        UINavigationBar.appearance().barTintColor = .lightGray
        let colorAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar().titleTextAttributes = colorAttributes
        GCKUICastButton.appearance().tintColor = .gray

        // Theme using GCKUIStyle.
        let castStyle = GCKUIStyle.sharedInstance()
        // Set the property of the desired cast widgets.
        castStyle.castViews.deviceControl.buttonTextColor = .darkGray
        // Refresh all currently visible views with the assigned styles.
        castStyle.apply()

        // Enable default expanded controller.
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true

        // Enable logger.
        GCKLogger.sharedInstance().delegate = self

        // Set logger filter.
        let filter = GCKLoggerFilter()
        filter.minimumLevel = .error
        GCKLogger.sharedInstance().filter = filter

        
        /*
        // Wrap main view in the GCKUICastContainerViewController and display the mini controller.
        let appStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let navigationController = appStoryboard.instantiateViewController(withIdentifier: "MainNavigation")
        let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
        castContainerVC.miniMediaControlsItemEnabled = true
        // Color the background to match the embedded content
        castContainerVC.view.backgroundColor = .white
         
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = castContainerVC
        window?.makeKeyAndVisible()
        */
//        let rootContainerVC = (window?.rootViewController as? ViewController)
//        rootContainerVC?.miniMediaControlsViewEnabled = true
//        if let window = UIApplication.shared.delegate?.window {}
    }
}

extension AppDelegate: GCKLoggerDelegate{
    func logMessage(_ message: String,
                     at level: GCKLoggerLevel,
                     fromFunction function: String,
                     location: String) {
       if (kDebugLoggingEnabled) {
         print(function + " - " + message)
       }
     }
}

