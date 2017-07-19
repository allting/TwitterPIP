 //
//  AppDelegate.swift
//  MiniTwitter
//
//  Created by kkr on 25/03/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa
import CoreData
 
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var contentView: NSVisualEffectView!
    
    func initValueTransformer() {
        let tweetStringTransformName = "TweetStringTransformer"
        ValueTransformer.setValueTransformer(TweetStringTransformer(), forName: NSValueTransformerName(rawValue: tweetStringTransformName))
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initValueTransformer()
        
        window = NSApplication.shared().windows.last!
        window.styleMask.insert(.fullSizeContentView)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.level = Int(CGWindowLevelForKey(.floatingWindow))
        
        WAYTheDarkSide.welcomeApplication({
            self.window.appearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
            self.contentView?.blendingMode = NSVisualEffectBlendingMode.behindWindow
            self.contentView?.material = NSVisualEffectMaterial.dark
            self.contentView?.state = NSVisualEffectState.active
        }, immediately: true)
        
        WAYTheDarkSide.outcastApplication({ 
            self.window?.appearance = NSAppearance.init(named: NSAppearanceNameVibrantLight);
            self.contentView?.blendingMode = NSVisualEffectBlendingMode.behindWindow
            self.contentView?.material = NSVisualEffectMaterial.light
            self.contentView?.state = NSVisualEffectState.active
        }, immediately: true)

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MiniTwitter")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

