//
//  GameController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import iAd
import GameKit

var CURRENT_LEVEL:Int = 0;
enum SPEED{case SLOW, FAST};
let NUM_SPEEDS:Int = 10;

func getLocalLevel()->Int
{
    return (CURRENT_LEVEL % (NUM_SUB_LEVELS)) + 1;
}

class GameController : UIViewController, ADBannerViewDelegate
{
    var game_timer = Timer();
    var game_clock:TimeInterval = 0.0;
    var precision:TimeInterval = 0.01; // measure to nearest .01 second
    var clock_str = String();
    var achievementController = AchievementController();
    
    var map = Array<Mine_cell>();
    var NUM_ROWS:Int = 5;
    var NUM_COLS:Int = 5;
    var NUM_LOCS:Int = 25;
    var COUNT:Int = 0;
    var GAME_OVER:Bool = false;
    var START_LOC:Int = 0;
    var GAME_STARTED:Bool = false;
    var MINE_SPEED:Int = 0;
    var POLICY:MINE_POLICY = MINE_POLICY.LOCAL;
    var level_indicator:UILabel = UILabel();
    var difficulty_indicator = UILabel();
    var level_no:Int = 0;
    var bottom_text = UILabel();
    var startup_menu = UIButton();
    var prev_button = UIButton();
    var next_button = UIButton();
    var repeat_button = UIButton();
    var level_button = UIButton();
    var superview = UIView();
    var nextController = NextGameContoller();
    var bannerIsVisible = false;
    var back_button = UIButton();
    
    var pauseController = PauseGameController();
    
    func resume_game()
    {
        for i in 0..<self.map.count
        {
            map[i].resume();
        }
        resume_game_clock();
        pauseController.view.removeFromSuperview();
    }
    
    // START AD BANNER VIEW DELEGATE IMPLEMENTATION --------------------------
    func bannerViewDidLoadAd(banner: ADBannerView!)
    {
        if(!bannerIsVisible)
        {
            UIView.animate(withDuration: 0.5, delay: 2.0, options: UIViewAnimationOptions.curveLinear, animations: {banner_view.frame = banner_loadedFrame}, completion: nil);
            bannerIsVisible = true;
        }
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!)
    {
        return;
    }
    
    private func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!)
    {
        if(bannerIsVisible) // remove add if it is visible until it can be fetched
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {banner_view.frame = banner_notLoadedFrame}, completion: nil);
        }
        bannerIsVisible = false;
        NSLog("%s", "App failed to retrive advertisement!");
        return;
    }
    
    func bannerViewActionShouldBegin(_ banner: ADBannerView, willLeaveApplication willLeave: Bool) -> Bool
    {
        if(!willLeave)    // pause game if game is active
        {
            if(!GAME_OVER && GAME_STARTED)
            {
                for i in 0..<self.map.count
                {
                    map[i].pause();
                }
                self.view.addSubview(pauseController.view);
                pause_game_clock();
            }
        }
        return true;
    }
    
    func bannerViewActionDidFinish(_ banner: ADBannerView)
    {
        return;
    }
    
    // END AD BANNER VIEW DELEGATE IMPLEMENTATION -------------------------------------
    
    func setProperties()
    {
        let delegate = UIApplication.shared.delegate as! AppDelegate;
        delegate.window?.backgroundColor = UIColor.black;
        
        self.NUM_ROWS = levels[CURRENT_LEVEL].dimension;
        self.MINE_SPEED = levels[CURRENT_LEVEL].speed;
        self.POLICY = levels[CURRENT_LEVEL].policy;
        self.difficulty_indicator.text = levels[CURRENT_LEVEL].difficulty;
        self.NUM_COLS = NUM_ROWS;
        self.NUM_LOCS = NUM_COLS * NUM_ROWS;
        level_indicator.text = String(format:"LEVEL %i", getLocalLevel());
        switch difficulty_indicator.text
        {
        case EASY: difficulty_indicator.textColor = UIColor.green;
        case MEDIUM: difficulty_indicator.textColor = UIColor.yellow;
        case HARD:  difficulty_indicator.textColor = UIColor.orange;
        case INSANE:  difficulty_indicator.textColor = UIColor.white;
        case IMPOSSIBLE:  difficulty_indicator.textColor = UIColor.red;
        default: difficulty_indicator.textColor = UIColor.white;
        }
        level_indicator.textColor = LIGHT_BLUE;
        let total = UILabel();
        total.text = level_indicator.text! + difficulty_indicator.text!;
        total.sizeToFit();
        let total_width:CGFloat = total.frame.width;  // get total width text takes up
        
        total.text = level_indicator.text!;
        total.sizeToFit();
        let level_width:CGFloat = total.frame.width;
        let dific_width:CGFloat = total_width - level_width;
        
        var padding:CGFloat = dific_width - level_width;
        let height = global_but_dim;
        
        var y_origin = ((superview.bounds.height - superview.bounds.width) * 0.5) - global_but_dim;
        if((DEVICE_VERSION == DEVICE_TYPE.IPAD) || (DEVICE_VERSION == DEVICE_TYPE.IPHONE_4))
        {
            y_origin = ((superview.bounds.height - superview.bounds.width) * 0.25) - (global_but_dim * 0.5);
        }
        
        var _:CGFloat = 25.0

        if(padding > 0) // must pad level side to center
        {
            let level_width = (superview.bounds.width / 2.0) - padding;
            let diffic_width = (superview.bounds.width / 2.0);
            let margin:CGFloat = 15.0;
            let shift:CGFloat = (padding - margin) / 2.0;
            level_indicator.frame = CGRect(x: shift, y: y_origin , width: level_width, height: height);
            difficulty_indicator.frame = CGRect(x: (superview.bounds.width / 2.0) - shift, y: y_origin, width: diffic_width, height: height);
        }
            
        else    // must pad difficulty side to center
        {
            padding *= -1;
            let level_width = (superview.bounds.width / 2.0);
            let diffic_width = (superview.bounds.width / 2.0) - padding;
            let margin:CGFloat = 15.0;
            let shift:CGFloat = (padding - margin) / 2.0;
            
            level_indicator.frame = CGRect(x: shift, y: y_origin , width: level_width, height: height);
            difficulty_indicator.frame = CGRect(x: (superview.bounds.width / 2.0) + padding - shift, y: y_origin, width: diffic_width, height: height);
        }
        
        var text_size:CGFloat;
        switch DEVICE_VERSION
        {
        case .IPHONE_4: text_size = 18.0;
            
        case .IPHONE_5: text_size = 18.0;
            
        case .IPHONE_6: text_size = 20.0;
            
        case .IPHONE_6_PLUS: text_size = 22.0;
            
        case .IPAD: text_size = 35.0;
            
        default: text_size = 20.0;
        }
        
        level_indicator.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
        difficulty_indicator.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
    }
    
    @objc func reset()
    {

        setProperties();
        map.removeAll(keepingCapacity: false);
        self.COUNT = 0;
        self.GAME_OVER = false;
        self.GAME_STARTED = false;
        generateMap();
        game_clock = 0.0;
    }
    
    @objc func increment_level()
    {
        play_sound(sound_effect: SOUND.DEFAULT);
        CURRENT_LEVEL += 1;
        if(CURRENT_LEVEL >= NUM_LEVELS)
        {
            CURRENT_LEVEL = NUM_LEVELS - 1;
        }
        reset();
    }
    @objc func decrement_level()
    {
        play_sound(sound_effect: SOUND.DEFAULT);
        CURRENT_LEVEL-=1;
        if(CURRENT_LEVEL < 0)
        {
            CURRENT_LEVEL = 0;
        }
        reset();
    }
    
    @objc func GoToLevelMenu()
    {
        let delegate = UIApplication.shared.delegate as! AppDelegate;
        delegate.window?.backgroundColor = LIGHT_BLUE;
        self.view.removeFromSuperview();
        play_sound(sound_effect: SOUND.DEFAULT);
    }
    
    @objc func GoToMainMenu()
    {
        self.view.removeFromSuperview();
        let parent:LevelController = self.parent as! LevelController;
        parent.go_to_main();
    }

    func won_game()->Bool
    {
        return (COUNT == NUM_LOCS);
    }
    
    func neighbors(index:Int)->(Array<Int>)
    {
        var neighbor_indicies:Array<Int> = Array<Int>();
        
        // add right neigbor (if it exists)
        if(((index + 1) % NUM_COLS) != 0)
        {
            neighbor_indicies.append(index + 1);
        }
        
        // left neighbor
        if(((index % NUM_COLS) != 0) && (index > 0))
        {
            neighbor_indicies.append(index - 1);
        }
        // top neighbor
        if((index - NUM_COLS) >= 0)
        {
            neighbor_indicies.append(index - NUM_COLS)
        }
        // bottom neighbor
        if((index + NUM_COLS) < map.count)
        {
            neighbor_indicies.append(index + NUM_COLS);
        }
        return neighbor_indicies;
    }
    
    func unmarked_neighbors(index:Int)->(Array<Int>)
    {
        var neighbor_indicies:Array<Int> = neighbors(index: index);
        var unexplored:Array<Int> = Array<Int>();
        for i in 0..<neighbor_indicies.count
        {
            if(!map[neighbor_indicies[i]].mine_exists && !map[neighbor_indicies[i]].explored)
            {
                unexplored.append(neighbor_indicies[i]);
            }
        }
        return unexplored;
    }
    
    func printNeighbors(index:Int)
    {
        /*
        print("--------------------------------------");
        var neighbor_indicies:Array<Int> = neighbors(index);
        print(String(format:"Neighbors of location %i", index));
        for i in 0..<neighbor_indicies.count
        {
            println(String(neighbor_indicies[i]));
        }
        print("--------------------------------------\n");
         */
    }
    
    func mark_mine(loc_id:Int)
    {
        map[loc_id].mark_mine();
        map[loc_id].mine_exists = true;
        COUNT += 1;
    }
    
    // MARKS GAME ACCORDINGLY IF WON OR LOST AND INVALIDATES ALL TIMERS
    func end_game()
    {
        let game_time = game_clock; // game clock is reset we need temp variable to hold time...
        nextController.set_time(time: String(format: "%.2f", game_time));
        stop_game_clock();
        LevelsController.loadData();
        for i in 0..<NUM_LOCS
        {
            if(map[i].mine_exists == true)
            {
                map[i].mark_mine();
                map[i].timer.invalidate();
                if(won_game())
                {
                    map[i].backgroundColor = LIGHT_BLUE;
                }
                else
                {
                    map[i].backgroundColor = UIColor.red;
                }
            }
        }
        // update progress
        var proportion:Float = Float(COUNT) / Float(NUM_LOCS);
        var prog:Int = 0;
        if(proportion == 1.0)
        {
            prog = 3;
        }
        else if(proportion >= 0.75)
        {
            prog = 2;
        }
        else if(proportion >= 0.5)
        {
            prog = 1;
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext!;
        
        var fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Level");
        var pred = NSPredicate(format: "level_no = %i", CURRENT_LEVEL);
        fetch.predicate = pred;
        
        var error:NSError?;
        do {
            var results:[NSManagedObject] = try managedContext.execute(fetch) as! [NSManagedObject];
            var beat_difficulty = false;
            var flag = false;
            var difficulty = levels[CURRENT_LEVEL].difficulty;
        } catch (let error) {
            print(error)
        }
        if(LevelsController.level_buttons[CURRENT_LEVEL].level_data == nil)
        {
            var description = NSEntityDescription.entity(forEntityName: "Level", in: managedContext);
            var managedObject = NSManagedObject(entity: description!, insertInto: managedContext);
            managedObject.setValue(CURRENT_LEVEL, forKey: "level_no");
            managedObject.setValue(prog, forKey: "progress");
            managedObject.setValue(Float(game_time), forKey: "time");
            LevelsController.level_buttons[CURRENT_LEVEL].level_data = managedObject;
            managedContext.insert(managedObject);
            var error2:NSError?;
            do {
                try managedContext.save()
            } catch (let error) {
                print(error)
            }
        }
        else
        {
            // get prev progress-> update only if current score greater than prev
            var prev_progress:Int = LevelsController.level_buttons[CURRENT_LEVEL].level_data?.value(forKey: "progress") as! Int;
            if(prog > prev_progress)
            {
                /*
                managedContext.delete(LevelsController.level_buttons[CURRENT_LEVEL].level_data!);
                var error_:NSError?;
                managedContext.save(&error);
                // delete all other references to the object
                pred = NSPredicate(format: "level_no = %i", CURRENT_LEVEL);
                fetch.predicate = pred;
                var results_:[NSManagedObject] = managedContext.executeFetchRequest(fetch, error: &error_) as! [NSManagedObject];
                for(var i = 0; i < results.count; ++i)
                {
                    managedContext.deleteObject(results[i]);
                }
                var error3:NSError?;
                managedContext.save(&error3);
                */
                LevelsController.level_buttons[CURRENT_LEVEL].level_data = nil;
                game_clock = game_time;
                end_game();
            }
            else if((prog == prev_progress) && (prog == 3)) // update best time if necessary
            {
                // get previoius time
                var previous_time:Float = LevelsController.level_buttons[CURRENT_LEVEL].level_data?.value(forKey: "time") as! Float;
                if(Float(game_time) < previous_time)
                {
                    LevelsController.level_buttons[CURRENT_LEVEL].level_data?.setValue(Float(game_time), forKey: "time");
                    // save new time update
                    /*
                    managedContext.save(&error);
                    achievementController.set_text(in_text: String(format: "New Best Time For Level %i", getLocalLevel()));
                    achievementController.animate();
                     */
                }
            }
        }
        
        if(won_game())
        {
            nextController.markWon();
        }
        else
        {
            nextController.markLost();
        }
        self.view.addSubview(nextController.view);
        LevelsController.loadData();
        //GKGameViewController.update_achievements(difficulty);
    }
    
    func unmarked_global()->(Array<Int>)
    {
        var arr = Array<Int>();
        for i in 0..<NUM_LOCS
        {
            if((!map[i].explored) && (!map[i].mine_exists))
            {
                arr.append(i);
            }
        }
        return arr;
    }
    
    // REQUIRES: SPEED IS WITHIN [0-10]
    // generates mines based on policy
    func generate_mines(policy:MINE_POLICY, loc_id:Int)
    {
        var speed_pool = Array<SPEED>();
        let num_slow = 10 - self.MINE_SPEED;
        let num_fast = self.MINE_SPEED;
        
        for i in 0..<num_slow
        {
            speed_pool.append(SPEED.SLOW);
        }
        for i in 0..<num_fast
        {
            speed_pool.append(SPEED.FAST);
        }
        // get random speed out of distribution of those generated
        var speed_index = arc4random_uniform(10);
        var mine_speed = speed_pool[Int(speed_index)];
        
        //
        var local_unmarked = unmarked_neighbors(index: loc_id);
        var global_unmarked = unmarked_global();
        
        if((policy == MINE_POLICY.LOCAL) && (local_unmarked.count > 0) )
        {
            var temp_index = Int(arc4random_uniform(UInt32(local_unmarked.count)));
            var index = local_unmarked[temp_index];
            map[index].speed = mine_speed;
            mark_mine(loc_id: index);
        }
        else if((policy == MINE_POLICY.GLOBAL) && (global_unmarked.count > 0))
        {
            var temp_index = Int(arc4random_uniform(UInt32(global_unmarked.count)));
            var index = global_unmarked[temp_index];
            map[index].speed = mine_speed;
            mark_mine(loc_id: index);
        }
        else    // MIXED policy
        {
            // generate random number from 0-1, and chose mine speed on 50/50 distribution
            var rand_num = arc4random_uniform(2); // can be either 0 or 1
            if(rand_num == 0)
            {
                generate_mines(policy: MINE_POLICY.LOCAL, loc_id: loc_id);
            }
            else
            {
                generate_mines(policy: MINE_POLICY.GLOBAL, loc_id: loc_id);
            }
        }
    }
    
    func update_game_clock()
    {
        self.game_clock += precision;
        self.clock_str = String(format: "%.2f seconds", self.game_clock);
    }
    
    func stop_game_clock()
    {
        self.game_timer.invalidate();
        self.game_clock = 0.0;  // reset game clock
    }
    
    func pause_game_clock()
    {
        self.game_timer.invalidate();
    }
    
    func resume_game_clock()
    {
        self.game_timer = Timer.scheduledTimer(timeInterval: precision, target: self, selector: "update_game_clock", userInfo: nil, repeats: true);
    }
    
    @objc func mark_location(button:UIButton)
    {
        let loc_id:Int = button.tag
        if(GAME_STARTED == false)
        {
            if(loc_id == START_LOC) // dont start game until user presses start button
            {
                GAME_STARTED = true;
                map[loc_id].setTitleColor(UIColor.clear, for: UIControlState.normal);
                mark_location(button: button);
                map[loc_id].explored = true;
                play_sound(sound_effect: SOUND.EXPLORED);
                // begin game timer
                game_timer = Timer.scheduledTimer(timeInterval: precision, target: self, selector: "update_game_clock", userInfo: nil, repeats: true);
            }
        }
        else if(!GAME_OVER)
        {
            if(map[loc_id].mine_exists)
            {
                play_sound(sound_effect: SOUND.LOST);
                
                // game is over
                GAME_OVER = true;
                end_game();
                map[loc_id].setTitleColor(UIColor.red, for: UIControlState.normal);
                map[loc_id].backgroundColor = UIColor.black;
                map[loc_id].layer.borderWidth = 1.0;
                map[loc_id].layer.borderColor = UIColor.white.cgColor;
                map[loc_id].set_image(zname: "mine_white");
            }
            else if(!map[loc_id].explored)
            {
                play_sound(sound_effect: SOUND.EXPLORED);
                map[loc_id].mark_explored();
                COUNT+=1;
                if(won_game())
                {
                    play_sound(sound_effect: SOUND.WON);
                    
                    self.bottom_text.textColor = LIGHT_BLUE;
                    GAME_OVER = true;
                    end_game();
                }
                else if((!GAME_OVER) && ((NUM_LOCS - COUNT) > 2))
                    // mine will never fill last unexplored cell
                {
                    generate_mines(policy: self.POLICY, loc_id: loc_id);
                }
            }
        }
    }
    
    func generateMap()
    {
        var margin_height = (superview.bounds.height - superview.bounds.width) / 2.0;
        var size:Float = 1.0;
        // create grid of elements
        for row in 0..<self.NUM_ROWS
        {
            for col in 0..<self.NUM_COLS
            {

                var width_const:CGFloat = CGFloat(1.0 / CGFloat(self.NUM_COLS));
                var height_const:CGFloat = CGFloat(1.0 / CGFloat(self.NUM_ROWS));
                
                var loc = (row * NUM_COLS) + col;
                var subview:Mine_cell = Mine_cell(location_identifier:loc);
                subview.translatesAutoresizingMaskIntoConstraints = false
                
                var width = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.width, multiplier: width_const, constant: 0.0);
                
                var height = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: subview, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0);
                
                var increment_centerx:CGFloat  = (CGFloat(superview.bounds.width) / CGFloat(NUM_COLS) * 0.5) + (CGFloat(superview.bounds.width) / CGFloat(NUM_COLS) * CGFloat(col));
                
                var increment_x = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: increment_centerx);
                
                var increment_centery:CGFloat  = (superview.bounds.width / CGFloat(NUM_ROWS) * 0.5) + (superview.bounds.width / CGFloat(NUM_ROWS) * CGFloat(row));
                
                var increment_y = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: increment_centery + margin_height);
                
                subview.backgroundColor = UIColor.white;
                subview.layer.borderWidth = 1.0;
                subview.tag = (row * NUM_COLS) + col;
                subview.addTarget(self, action: Selector("mark_location:"), for: UIControlEvents.touchDown);
                
                
                superview.addSubview(subview);
                superview.addConstraint(width);
                superview.addConstraint(height);
                superview.addConstraint(increment_x);
                superview.addConstraint(increment_y);
                // tag element to uniquely identify it
                subview.tag = (row * NUM_COLS) + col;
                let tag:Int = (row * NUM_COLS) + col;
                self.map.append(subview);
            }
        }
        
        
        self.map[self.START_LOC].backgroundColor = UIColor.gray;
        self.map[self.START_LOC].setTitleColor(UIColor.black, for: UIControlState.normal);
        self.map[self.START_LOC].setTitle("START", for: UIControlState.normal);
        let font_size:CGFloat = 12.0 + ((8.0 - CGFloat(NUM_ROWS)) * 2.0);
        if(NUM_ROWS >= 6)
        {
            if((DEVICE_VERSION == DEVICE_TYPE.IPHONE_6) || (DEVICE_VERSION == DEVICE_TYPE.IPHONE_6_PLUS))
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 12.0);
            }
            else if(DEVICE_VERSION == DEVICE_TYPE.IPAD)
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 20.0);
            }
            else    // IPHONE 4 OR 5
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 11.0);
            }
            
        }
        if(NUM_ROWS == 5)
        {
            if((DEVICE_VERSION == DEVICE_TYPE.IPHONE_6) || (DEVICE_VERSION == DEVICE_TYPE.IPHONE_6_PLUS))
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 15.0);
            }
            else if(DEVICE_VERSION == DEVICE_TYPE.IPAD)
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 28.0);
            }
            else    // IPHONE 4 OR 5
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 14.0);
            }
        }
        if(NUM_ROWS == 4)
        {
            if((DEVICE_VERSION == DEVICE_TYPE.IPHONE_6) || (DEVICE_VERSION == DEVICE_TYPE.IPHONE_6_PLUS))
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 18.0);
            }
            else if(DEVICE_VERSION == DEVICE_TYPE.IPAD)
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 30.0);
            }
            else    // IPHONE 4 OR 5
            {
                self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 17.0);
            }
        }
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        superview.backgroundColor = UIColor.black;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        superview.bounds = superview.frame;
        superview.layoutIfNeeded();
        superview.setNeedsLayout();
        
        // configure back button
        var back_y:CGFloat = global_but_margin;
        if((DEVICE_VERSION == DEVICE_TYPE.IPAD) || (DEVICE_VERSION == DEVICE_TYPE.IPHONE_4))
        {
            back_y = ((superview.bounds.height - superview.bounds.width) * 0.25) - (global_but_dim * 0.5);
        }
        let back_x:CGFloat = global_but_margin;
        let back_width:CGFloat = global_but_dim;
        let back_height:CGFloat = global_but_dim;
        back_button = UIButton(frame: CGRect(x: back_x, y: back_y, width: back_width, height: back_height));
        back_button.setBackgroundImage(UIImage(named: "prev_level"), for: UIControlState.normal);
        back_button.layer.borderWidth = 1.0;
        back_button.layer.borderColor = UIColor.white.cgColor;
        back_button.addTarget(self, action:"GoToLevelMenu", for: UIControlEvents.touchUpInside);
        superview.addSubview(back_button);
        back_button.layoutIfNeeded();
        back_button.setNeedsLayout();
        
        // configure level indicator
        level_indicator.textAlignment = NSTextAlignment.right;
        difficulty_indicator.textAlignment = NSTextAlignment.left;
        superview.addSubview(difficulty_indicator);
        superview.addSubview(level_indicator);
        setProperties();
        
        // add child view controller
        self.addChildViewController(nextController);
        
        self.NUM_ROWS = levels[CURRENT_LEVEL].dimension;
        self.NUM_COLS = NUM_ROWS;
        self.NUM_LOCS = NUM_COLS * NUM_ROWS;
        
        map.removeAll(keepingCapacity: true);
        setProperties();
        generateMap();  // generate map to play on
        
        let margin_height = (superview.bounds.height - superview.bounds.width) / 2.0;
        
        superview.layer.borderWidth = 2.0;
        superview.layer.borderColor = UIColor.black.cgColor
        
        self.bottom_text.translatesAutoresizingMaskIntoConstraints = false
        let center_x = NSLayoutConstraint(item: bottom_text, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0);
        
        let center_y_const = (superview.bounds.width + superview.bounds.height) / 2.0;
        let center_y = NSLayoutConstraint(item: bottom_text, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: center_y_const);
        
        var _:CGFloat = 20.0
        superview.addSubview(self.bottom_text);
        superview.addConstraint(center_x);
        superview.addConstraint(center_y);
        
        self.bottom_text.textColor = UIColor.white;
        self.bottom_text.textAlignment = NSTextAlignment.center;
        self.bottom_text.font = UIFont(name: "Arial-BoldMT" , size: 35.0);

        update_local_level();

        let repeat_image = UIImage(named: "repeat_level");
        let prev_image = UIImage(named: "prev_level");
        let next_image = UIImage(named: "next_level");
        
        
        // get y for buttons, this will be different depending on device
        var button_y:CGFloat = ((superview.bounds.height - superview.bounds.width) * 0.5) + global_but_margin + superview.bounds.width;
        if((DEVICE_VERSION == DEVICE_TYPE.IPAD) || (DEVICE_VERSION == DEVICE_TYPE.IPHONE_4))
        {
            button_y = (((superview.bounds.height - superview.bounds.width) * 0.75) + superview.bounds.width) - (global_but_dim * 0.5);
        }
        
        // configure previous button
        let prev_x:CGFloat = (superview.bounds.width - ((3.0 * global_but_dim) + (2.0 * global_but_margin))) / 2.0;
        let prev_width:CGFloat = global_but_dim;
        let prev_height:CGFloat = global_but_dim;
        prev_button = UIButton(frame: CGRect(x: prev_x, y: button_y, width: prev_width, height: prev_height));
        prev_button.setBackgroundImage(prev_image, for: UIControlState.normal);
        prev_button.layer.borderWidth = 1.0;
        prev_button.layer.borderColor = UIColor.white.cgColor;
        prev_button.layer.backgroundColor = UIColor.black.cgColor;
        prev_button.addTarget(self, action: Selector("decrement_level"), for: UIControlEvents.touchUpInside);
        
        // configure repeat button
        let repeat_x:CGFloat = prev_button.frame.origin.x + global_but_dim + global_but_margin;
        let repeat_width:CGFloat = global_but_dim;
        let repeat_height:CGFloat = global_but_dim;
        repeat_button = UIButton(frame: CGRect(x: repeat_x, y: button_y, width: repeat_width, height: repeat_height));
        repeat_button.setBackgroundImage(repeat_image, for: UIControlState.normal);
        repeat_button.layer.borderWidth = 1.0;
        repeat_button.layer.borderColor = UIColor.white.cgColor;
        repeat_button.layer.backgroundColor = UIColor.black.cgColor;
        repeat_button.addTarget(self, action: Selector("reset"), for: UIControlEvents.touchUpInside);
        
        // configure next button
        let next_x:CGFloat = repeat_button.frame.origin.x + global_but_dim + global_but_margin;
        let next_width:CGFloat = global_but_dim;
        let next_height:CGFloat = global_but_dim;
        next_button = UIButton(frame: CGRect(x: next_x, y: button_y, width: next_width, height: next_height));
        next_button.setBackgroundImage(next_image, for: UIControlState.normal);
        next_button.layer.borderWidth = 1.0;
        next_button.layer.borderColor = UIColor.white.cgColor;
        next_button.layer.backgroundColor = UIColor.black.cgColor;
        next_button.addTarget(self, action: Selector("increment_level"), for: UIControlEvents.touchUpInside);
        
        superview.addSubview(prev_button);
        superview.addSubview(repeat_button);
        superview.addSubview(next_button);
        
        // add achievement controller to hiearchy
        superview.addSubview(achievementController.view);
    }
}

class Mine_cell:UIButton
{
    var loc_id:Int;
    var mine_exists:Bool = false;
    var insignia:String = "";
    var explored:Bool = false;
    var time_til_disappears:Int = 0;
    var timer = Timer();
    var timer_running:Bool = false;
    var speed:SPEED;
    var startup_time:TimeInterval = TimeInterval();
    
    required init(coder aDecoder: NSCoder) {
        loc_id = -1;
        mine_exists = false;
        insignia = "";
        explored = false;
        speed = SPEED.SLOW;
        super.init(frame:CGRect.zero);
    }
    init(location_identifier:Int)
    {
        loc_id = location_identifier;
        explored = false;
        mine_exists = false;
        insignia = "";
        timer_running = false;
        speed = SPEED.SLOW;
        super.init(frame:CGRect.zero);
        loc_id = location_identifier;
    }
    func pause()
    {
        if(timer.isValid)
        {
            let paused_date = NSDate();
            startup_time = timer.fireDate.timeIntervalSince(paused_date as Date)
            timer.fireDate = NSDate(timeIntervalSinceReferenceDate: Double.infinity) as Date;   // keep timer from firing
        }
    }
    func resume()
    {
        if(timer.isValid)
        {
            timer.fireDate = NSDate(timeInterval: startup_time, since: NSDate() as Date) as Date;
        }
    }
    
    func set_image(zname:String)
    {
        let image = UIImage(named: zname);
        setBackgroundImage(image, for: UIControlState.normal);
    }
    @objc func update()
    {
        if(time_til_disappears > 0)
        {
            time_til_disappears -= 1;
            if(speed == SPEED.SLOW)
            {
                switch time_til_disappears
                {
                case 3:
                    set_image(zname: "mine_red");
                case 2:
                    set_image(zname: "mine_orange");
                case 1:
                    set_image(zname: "mine_yellow");
                case 0:
                    setImage(nil, for: UIControlState.normal);
                default:
                    setImage(nil, for: UIControlState.normal);
                }
            }
            else if(speed == SPEED.FAST)
            {
                switch time_til_disappears
                {
                case 3:
                    set_image(zname: "mine_dark_blue");
                case 2:
                    set_image(zname: "mine_blue");
                case 1:
                    set_image(zname: "mine_light_blue");
                case 0:
                    setImage(nil, for: UIControlState.normal);
                default:
                    setImage(nil, for: UIControlState.normal);
                }
            }
        }
        else    // remove mine indicator
        {
            timer.invalidate();
            setTitleColor(UIColor.clear, for: UIControlState.normal);
            imageView?.image = nil;
            timer_running = false;
            setBackgroundImage(nil, for: UIControlState.normal);
        }
    }
    func mark_mine()
    {
        mine_exists = true;
        setTitle(insignia, for: UIControlState.normal);
        set_image(zname: "mine_black");
        
        if(timer_running == false)
        {
            if(speed == SPEED.SLOW)
            {
                time_til_disappears = 4;
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(UIMenuController.update), userInfo: nil, repeats: true);
                timer_running = true;
            }
            else if(speed == SPEED.FAST)
            {
                time_til_disappears = 4;
                timer = Timer.scheduledTimer(timeInterval: 0.125, target: self, selector: #selector(UIMenuController.update), userInfo: nil, repeats: true);
                timer_running = true;
            }
        }
    }
    func mark_explored()
    {
        if(!explored)
        {
            explored = true;
            backgroundColor = UIColor.gray;
        }
    }
}


// Window that prompts user to go to the next game if they win, or repeat if they loose
class NextGameContoller: ViewController
{
    // create view that will hold next level
    var complete_container = UIView();
    var won_game = false;
    var next_level = UIButton();
    var x_button = UIButton();
    var superview = UIView();
    var completed_label = UILabel();
    var time_label = UILabel();
    
    func exit()
    {
        self.view.removeFromSuperview();
    }
    
    func markWon()
    {
        completed_label.textColor = UIColor.orange;
        completed_label.text = String(format: "Level %i Completed", getLocalLevel());
        next_level.setTitle("Next Level", for: UIControlState.normal);
        next_level.removeTarget(gameController, action: "reset", for: UIControlEvents.touchUpInside);
        next_level.addTarget(gameController, action: "increment_level", for: UIControlEvents.touchUpInside);
        x_button.layer.borderColor = UIColor.orange.cgColor;
        x_button.setTitleColor(UIColor.orange, for: UIControlState.highlighted);
        
    }
    func markLost()
    {
        completed_label.textColor = UIColor.red;
        completed_label.text = String(format: "Level %i Failed", getLocalLevel());
        next_level.setTitle("Repeat Level", for: UIControlState.normal);
        next_level.removeTarget(gameController, action: "increment_level", for: UIControlEvents.touchUpInside);
        if #available(iOS 12.0, *) {
            next_level.addTarget(gameController, action: #selector(MTLIndirectRenderCommand.reset), for: UIControlEvents.touchUpInside)
        } else {
            // Fallback on earlier versions
        };
        x_button.layer.borderColor = UIColor.red.cgColor;
        x_button.setTitleColor(UIColor.red, for: UIControlState.highlighted);
    }
    
    func set_time( time:String)
    {
        time_label.text = time + " seconds";
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        let margin:CGFloat = superview.bounds.height * 0.05;
        let super_width:CGFloat = superview.bounds.width - (2.0 * margin);
        let super_height:CGFloat = super_width;
        let super_x:CGFloat = margin;
        let super_y:CGFloat = ((superview.bounds.height - super_width) / 2.0) - (banner_view.bounds.height / 2.0);
        superview.frame = CGRect(x: super_x, y: super_y, width: super_width, height: super_height);
        
        // configure complete container
        complete_container.frame = superview.bounds;
        superview.addSubview(complete_container);
        complete_container.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8);
        complete_container.layer.borderWidth = 1.0;
        complete_container.layer.borderColor = UIColor.white.cgColor;

        // add x button
        x_button.translatesAutoresizingMaskIntoConstraints = false;
        x_button.setTitle("X", for: UIControlState.normal);
        x_button.clipsToBounds = true;
        x_button.layer.cornerRadius = 15.0;
        x_button.layer.borderWidth = 1.0;
        x_button.backgroundColor = UIColor.black;
        x_button.alpha = 0.85;
        x_button.addTarget(self, action: #selector(Thread.exit), for: UIControlEvents.touchDown);
        
        
        // add constraints
        let x_button_centery = NSLayoutConstraint(item: x_button, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0);
        
        let x_button_centerx = NSLayoutConstraint(item: x_button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0);
        
        // conform hiearchy
        superview.addSubview(x_button);
        superview.addConstraint(x_button_centery);
        superview.addConstraint(x_button_centerx);
        
        // configure fonts
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
        case .IPHONE_4: font_size = 21.0; text_size = 15.0;
            
        case .IPHONE_5: font_size = 22.0; text_size = 16.0;
            
        case .IPHONE_6: font_size = 25.0; text_size = 17.0;
            
        case .IPHONE_6_PLUS: font_size = 26.0; text_size = 18.0;
            
        case .IPAD: font_size = 33.0; text_size = 28.0;
            
        default: font_size = 30.0;
        }

        
        // confiugure label
        var label_height:CGFloat = complete_container.bounds.height / 8.0;
        completed_label.frame = CGRect(x: 0.0, y: (complete_container.bounds.height / 3.0) - (label_height / 2.0), width: complete_container.bounds.width, height: label_height);
        completed_label.textAlignment = NSTextAlignment.center;
        complete_container.addSubview(completed_label);
        completed_label.font = UIFont(name: "Galano Grotesque Alt DEMO", size: font_size);
        
        // configure next level button
        complete_container.addSubview(next_level);
        var next_y:CGFloat = complete_container.bounds.height * 2.0 / 3.0;
        var next_x:CGFloat = margin;
        var next_width:CGFloat = complete_container.bounds.width - (2.0 * margin);
        var next_height:CGFloat = complete_container.bounds.height / 6.0;
        next_level.frame = CGRect(x: next_x, y: next_y, width: next_width, height: next_height);
        next_level.setTitleColor(UIColor.white, for: UIControlState.normal);
        next_level.layer.borderWidth = 1.0;
        next_level.layer.borderColor = UIColor.white.cgColor;
        next_level.setTitleColor(LIGHT_BLUE, for: UIControlState.highlighted);
        next_level.titleLabel?.font = UIFont(name: "MicroFLF", size: text_size);
        
        // configure time label
        time_label.frame = superview.bounds;
        time_label.textAlignment = NSTextAlignment.center;
        time_label.textColor = UIColor.white;
        time_label.font = UIFont(name: "MicroFLF", size: text_size);
        superview.addSubview(time_label);
    }
}


//----------------------------------------------------------------------------------------------------------------
//      BEAT DIFFICULTY VIEW CONTROLLER CLASS
//----------------------------------------------------------------------------------------------------------------

class BeatDifficultyController:UIViewController
{
    // properties
    var superview:UIView  = UIView();
    var margin:CGFloat = 0.0;
    var text_view:UITextView = UITextView();
    var text:String = "Congratulations! You have defeated all levels on MEDIUM!";
    var continue_button:UIButton = UIButton();
    
    func setDifficulty( in_difficulty:String)
    {
        text = "Congratulations! You have defeated all levels on " + in_difficulty + "!";
        gameController.nextController.view.removeFromSuperview();
        
    
    }
    func exit()
    {
        self.view.removeFromSuperview();
        gameController.GoToLevelMenu();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // configure view
        superview = self.view;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.frame.width, height: superview.frame.height - banner_view.frame.height);
        addGradient(view: superview, colors: [UIColor.black.cgColor, LIGHT_BLUE.cgColor]);
       
        margin = superview.bounds.height * 0.05;
        let x:CGFloat = margin;
        let y:CGFloat = (superview.bounds.height - superview.bounds.width) / 2.0;
        let width:CGFloat = superview.bounds.width - (2.0 * margin);
        let height:CGFloat = width;
        let frame = CGRect(x: x, y: y, width: width, height: height);
        
        // configure text_view
        superview.addSubview(text_view);
        text_view.frame = frame;
        text_view.textAlignment = NSTextAlignment.center;
        text_view.textColor = UIColor.white;
        text_view.text = text;
        text_view.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 30.0);
        text_view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5);
        text_view.layer.borderWidth = 1.0;
        text_view.layer.borderColor = UIColor.white.cgColor;
        text_view.isEditable = false;
        
        // configure continue button
        let cont_x:CGFloat = text_view.bounds.width * 0.25;
        let cont_y:CGFloat = (text_view.bounds.height * 0.5);
        let cont_width:CGFloat = text_view.bounds.width * 0.5;
        let cont_height:CGFloat = cont_width;
        continue_button.frame = CGRect(x: cont_x, y: cont_y, width: cont_width, height: cont_height);
        text_view.addSubview(continue_button);
        continue_button.setBackgroundImage(UIImage(named: "next_level"), for: UIControlState.normal);
        continue_button.addTarget(self, action: #selector(Thread.exit), for: UIControlEvents.touchUpInside);
    }
}

//----------------------------------------------------------------------------------------------------------------
//      END DIFFICULTY VIEW CONTROLLER CLASS
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//      PAUSE GAME VIEW CONTROLLER CLASS
//----------------------------------------------------------------------------------------------------------------

class PauseGameController:UIViewController
{
    var superview = UIView();
    var play_button = UIButton();
    override func viewDidLoad()
    {
        // configure frame
        super.viewDidLoad();
        superview =  self.view;
        
        let super_x:CGFloat = 0.0;
        let super_y:CGFloat = (superview.bounds.height - superview.bounds.width - banner_view.bounds.height) / 2.0;
        let super_width:CGFloat = superview.bounds.width;
        let super_height:CGFloat = super_width;
        superview.frame = CGRect(x: super_x, y: super_y, width: super_width, height: super_height);
        superview.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3);
        
        // configure visual attributes
        let margin:CGFloat = superview.bounds.width * 0.1;
        let x:CGFloat = margin;
        let y:CGFloat = margin;
        let width:CGFloat = superview.bounds.width - (2.0 * margin);
        let height:CGFloat = width;
        
        play_button.frame = CGRect(x: x, y: y, width: width, height: height);
        superview.addSubview(play_button);
        play_button.setBackgroundImage(UIImage(named: "play"), for: UIControlState.normal);
        play_button.alpha = 0.7;
        play_button.setTitle("RESUME", for: UIControlState.normal);
        play_button.setTitleColor(UIColor.black, for: UIControlState.normal);
        play_button.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 30.0);
        play_button.addTarget(gameController, action: Selector("resume_game"), for: UIControlEvents.touchUpInside);
        play_button.titleLabel?.alpha = 1.0;
    }
}

//----------------------------------------------------------------------------------------------------------------
//      END PAUSE GAME VIEW CONTROLLER CLASS
//----------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------
//      ACHIVEMENT VIEW CONTROLLER CLASS
//----------------------------------------------------------------------------------------------------------------

class AchievementController:UIViewController
{
    var superview = UIView();
    var out_frame = CGRect();
    var in_frame = CGRect();
    var label = UILabel();
    var speed = TimeInterval(1.0);
    var pause = TimeInterval(5.0);
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        let height:CGFloat = back_button_size;
        let width:CGFloat = superview.bounds.width - global_but_dim - (global_but_margin * 3.0);
        let y:CGFloat = gameController.back_button.frame.origin.y;
        let x:CGFloat = superview.bounds.width + width;
        out_frame = CGRect(x: x, y: y, width: width, height: height);
        in_frame = CGRect(x: superview.bounds.width - width - global_but_margin, y: y, width: width, height: height);
        superview.frame = out_frame;
        superview.addSubview(label);
        label.font = UIFont(name: "MicroFLF", size: 14.0);
        label.textColor = UIColor.black
        label.frame = superview.bounds;
        label.textAlignment = NSTextAlignment.center
        superview.addSubview(label);
        superview.backgroundColor = LIGHT_BLUE;
    }
    
    func set_text(in_text:String)
    {
        label.text = in_text;
    }

    func animate()
    {
        UIView.animate(withDuration: speed, animations: {self.superview.frame = self.in_frame});
        UIView.animate(withDuration: speed, delay: pause, options: UIViewAnimationOptions.curveLinear, animations: {self.superview.frame = self.out_frame}, completion: nil);
    }
}

//----------------------------------------------------------------------------------------------------------------
//      END ACHIEVMENT VIEW CONTROLLER CLASS
//----------------------------------------------------------------------------------------------------------------
