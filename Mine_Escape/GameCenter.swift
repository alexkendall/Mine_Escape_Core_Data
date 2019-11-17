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
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            guard let vC = viewController else {
                if (self.localPlayer.isAuthenticated)
                {
                    // 2 Player is already euthenticated & logged in, load game center
                    self.gcEnabled = true
                }
                    
                else
                {
                    // 3 Game center is not enabled on the users device
                    self.gcEnabled = false
                    print("Local player could not be authenticated, disabling game center")
                }
                return
            }
            // 1 Show login if player is not logged in
            self.present(vC, animated: true, completion: nil)
        }
    }
    
    func update_achievements(difficulty:String)
    {
        var mega:Int = -1;
        for i in 0..<DIFFICULTY.count
        {
            if(difficulty == DIFFICULTY[i])
            {
                mega = i;
                break;
            }
        }
        assert(mega != -1, "Invalid difficulty entered as function argument");
        
        // 1. CHECK FOR 5 100 Point Achievements
        
        var attachment:String
        var blitz_speed:Float = 0.0;
        
        switch difficulty
        {
            case EASY: attachment = "rookie"; blitz_speed = 4.0;
            case MEDIUM: attachment = "cadet"; blitz_speed = 5.0;
            case HARD: attachment = "veteran"; blitz_speed = 9.0;
            case INSANE: attachment = "insane"; blitz_speed = 11.0;
            case IMPOSSIBLE: attachment = "impossible"; blitz_speed = 16.0;
            default: attachment = "";
        }
        
        // query all levels of specified difficulty
        let min_level:Int = NUM_SUB_LEVELS * mega;
        let max_level:Int = min_level + NUM_SUB_LEVELS - 1;
        // fetch level progress
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext;
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Level");
        var predictae = NSPredicate(format: "(progress = 3) AND (level_no > %i) AND (level_no < %i)", min_level - 1, max_level + 1);
        request.predicate = predictae;
        do {
            let results:[NSManagedObject] = try managedContext?.fetch(request) as! [NSManagedObject];
            let percent = Double(results.count) / Double(NUM_SUB_LEVELS) * 100.0;
            let achievement_id = "mine.escape." + attachment;
            report_achievement(achievement_id: achievement_id, percent: percent);
        } catch (let error) {
            print("Error retrieving achievement \(error.localizedDescription)")
        }
        
        // 2. check for under 4 Complete 10/25/100/125 achievements
        var complete_nums = [10,25,50,125];
        for i in 0..<complete_nums.count
        {
            predictae = NSPredicate(format: "progress = 3");
            request.predicate = predictae;
            do {
                let comp_results:[NSManagedObject] = try managedContext?.fetch(request) as! [NSManagedObject];
                let percent = Double(comp_results.count) / Double(complete_nums[i]) * 100.0;
                let achievement_id = "mine.escape.complete" + String(complete_nums[i]);
                report_achievement(achievement_id: achievement_id, percent: percent);
            } catch (let error) {
                print("Error retrieving achievement \(error.localizedDescription)")
            }
        }
        
        // 3. check for blitzer achievements
        predictae = NSPredicate(format: "(progress = 3) AND (level_no > %i) AND (level_no < %i) AND (time < %f)", min_level - 1, max_level + 1, blitz_speed);
        request.predicate = predictae;
        do {
            let blitz_results:[NSManagedObject] = try managedContext?.fetch(request) as! [NSManagedObject];
            if(blitz_results.count > 0)
            {
                let percent = 100.0;
                let achievement_id = "mine.escape." + difficulty.lowercased() + ".blitzer";
                report_achievement(achievement_id: achievement_id, percent: percent);
            }
        } catch (let error) {
            print("Error retrieving achievement \(error.localizedDescription)")
        }
    }
    
    func report_achievement(achievement_id:String, percent:Double)
    {
        let achievement = GKAchievement(identifier: achievement_id);
        achievement.showsCompletionBanner = true;
        achievement.percentComplete = percent;
        GKAchievement.report([achievement], withCompletionHandler:
            {(NSError) in
                if(NSError != nil)
                {
                    print("Error. Unable to report achievement");
                }
            }
        );
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
        //code to dismiss your gameCenterViewController
        // for example:
        gameCenterViewController.dismiss(animated: true, completion: nil);
    }
}
