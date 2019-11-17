//
//  AppDelegate.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import UIKit
import CoreData
import iAd

enum DEVICE_TYPE{case IPHONE_4, IPHONE_5, IPHONE_6, IPHONE_6_PLUS, IPAD, IWATCH};
var DEVICE_VERSION:DEVICE_TYPE = DEVICE_TYPE.IPHONE_6; // default device
var DEVICE_HEIGHT = CGFloat();
var DEVICE_WIDTH = CGFloat();
let MainMenuContoller = MainController();
let LevelsController = LevelController();
let AboutViewController = AboutController();
let HowController = HowToController();
let settingsController = SettingsController();
let gameController = GameController();
// colors
var LIGHT_BLUE = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0);
var DARK_BLUE = UIColor(red: 0.0, green: 0.0, blue: 0.3, alpha: 1.0);
var global_margin:CGFloat = 0.0;
var global_but_dim:CGFloat = 0.0;
var global_but_margin:CGFloat = 0.0;

var banner_loadedFrame = CGRect();
var banner_notLoadedFrame = CGRect();

var banner_view = ADBannerView();

func setDeviceInfo()
{
    DEVICE_HEIGHT = MainMenuContoller.view.bounds.height + banner_view.bounds.height;
    DEVICE_WIDTH = MainMenuContoller.view.bounds.width;
    
    if(DEVICE_HEIGHT == 480)
    {
        DEVICE_VERSION = DEVICE_TYPE.IPHONE_4;
    }
    else if(DEVICE_HEIGHT == 568)
    {
        DEVICE_VERSION = DEVICE_TYPE.IPHONE_5;
    }
    else if(DEVICE_HEIGHT == 667)
    {
        DEVICE_VERSION = DEVICE_TYPE.IPHONE_6;
    }
    else if(DEVICE_HEIGHT == 736)
    {
        DEVICE_VERSION = DEVICE_TYPE.IPHONE_6_PLUS;
    }
    else if(DEVICE_HEIGHT > 736)
    {
        DEVICE_VERSION = DEVICE_TYPE.IPAD;
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setDeviceInfo();
        gen_levels();
        settingsController.load_volume();
        window?.rootViewController = MainMenuContoller;
        window?.backgroundColor = LIGHT_BLUE;
        
        global_but_margin = MainMenuContoller.view.bounds.height * 0.025;
        global_margin = MainMenuContoller.view.bounds.height / 20.0;
        global_but_dim =  MainMenuContoller.view.bounds.width / 10.0;
        
        // configure banner-> initialize outside of view and translate into view upon sucessful fetch of ad
        banner_loadedFrame = CGRect(x: 0.0, y: window!.bounds.height - banner_view.bounds.height, width: banner_view.bounds.width, height: banner_view.bounds.height);
        banner_notLoadedFrame = CGRect(x: -banner_view.bounds.width, y: window!.bounds.height - banner_view.bounds.height, width: banner_view.bounds.width, height: banner_view.bounds.height);
        banner_view.frame = banner_notLoadedFrame;
        banner_view.delegate = gameController;
        MainMenuContoller.view.addSubview(banner_view);

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.alexkendall.Mine_Escape" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Mine_Escape", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Mine_Escape.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        /*
        if coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
         */
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

