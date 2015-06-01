//
//  game_center.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/25/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import GameKit

var GKGameViewController = GKGameController();

class GKGameController: UIViewController, GKGameCenterControllerDelegate
{
    var gcEnabled = Bool() // Stores if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Stores the default leaderboardID
    var localPlayer = GKLocalPlayer();
    
    func authenticateLocalPlayer() {
        localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil)
            {
                // 1 Show login if player is not logged in
                self.presentViewController(ViewController, animated: true, completion: nil)
            } else if (self.localPlayer.authenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                self.localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifer: String!, error: NSError!) -> Void in
                    if error != nil {
       
                        println(error)
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifer
                    }
                })
                
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                println("Local player could not be authenticated, disabling game center")
                println(error);
                
            }
        }
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!)
    {
        //code to dismiss your gameCenterViewController
        // for example:
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil);
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        self.authenticateLocalPlayer();
        var gcViewController: GKGameCenterViewController = GKGameCenterViewController();
        gcViewController.gameCenterDelegate = self;
    }
}



