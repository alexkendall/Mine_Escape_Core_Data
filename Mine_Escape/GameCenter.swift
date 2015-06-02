//
//  game_center.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/25/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import GameKit
import CoreData

var GKGameViewController = GKGameController();

class GKGameController: UIViewController, GKGameCenterControllerDelegate
{
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Stores the default leaderboardID
    var localPlayer = GKLocalPlayer();
    
    func authenticateLocalPlayer()
    {
        localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil)
            {
                // 1 Show login if player is not logged in
                self.presentViewController(ViewController, animated: true, completion: nil)
            }
            
            else if (self.localPlayer.authenticated)
            {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
            }
            
            else
            {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                println("Local player could not be authenticated, disabling game center")
                println(error);
            }
        }
    }
    
    func update_achievements(var difficulty:String)
    {
        var mega:Int = -1;
        for(var i = 0; i < DIFFICULTY.count; ++i)
        {
            if(difficulty == DIFFICULTY[i])
            {
                mega = i;
                break;
            }
        }
        assert(mega != -1, "Invalid difficulty entered as function argument");
        
        // 1. CHECK FOR 5 100 Point Achievements
        
        // query all levels of specified difficulty
        var min_level:Int = NUM_SUB_LEVELS * mega;
        var max_level:Int = min_level + NUM_SUB_LEVELS - 1;
        // fetch level progress
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext;
        var request = NSFetchRequest(entityName: "Level");
        var predictae = NSPredicate(format: "(progress = 3) AND (level_no > %i) AND (level_no < %i)", min_level - 1, max_level + 1);
        request.predicate = predictae;
        var error:NSError?;
        var results:[NSManagedObject] = managedContext?.executeFetchRequest(request, error: &error) as! [NSManagedObject];
        var percent = Double(results.count) / Double(NUM_SUB_LEVELS) * 100.0;
        var achievement_id = "mine.escape." + difficulty.lowercaseString;
        report_achievement(achievement_id, percent: percent);
    }
    
    func report_achievement(var achievement_id:String, var percent:Double)
    {
        var achievement = GKAchievement(identifier: achievement_id);
        achievement.showsCompletionBanner = true;
        achievement.percentComplete = percent;
        GKAchievement.reportAchievements([achievement], withCompletionHandler:
            {(NSError) in
                if(NSError != nil)
                {
                    println("Error. Unable to report achievement");
                }
            }
        );
        println("Achievement: " + achievement_id + " --- Percent Complete: " + String(stringInterpolationSegment: percent));
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        //code to dismiss your gameCenterViewController
        // for example:
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil);
    }
}
