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
    var game_timer = NSTimer();
    var game_clock:NSTimeInterval = 0.0;
    var precision:NSTimeInterval = 0.01; // measure to nearest .01 second
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
        for(var i = 0; i < self.map.count; ++i)
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
            UIView.animateWithDuration(0.5, delay: 2.0, options: nil, animations: {banner_view.frame = banner_loadedFrame}, completion: nil);
            bannerIsVisible = true;
        }
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!)
    {
        return;
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!)
    {
        if(bannerIsVisible) // remove add if it is visible until it can be fetched
        {
            UIView.animateWithDuration(0.5, delay: 0.0, options: nil, animations: {banner_view.frame = banner_notLoadedFrame}, completion: nil);
        }
        bannerIsVisible = false;
        NSLog("%s", "App failed to retrive advertisement!");
        return;
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool
    {
        if(!willLeave)    // pause game if game is active
        {
            if(!GAME_OVER && GAME_STARTED)
            {
                for(var i = 0; i < self.map.count; ++i)
                {
                    map[i].pause();
                }
                self.view.addSubview(pauseController.view);
                pause_game_clock();
            }
        }
        return true;
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!)
    {
        return;
    }
    
    // END AD BANNER VIEW DELEGATE IMPLEMENTATION -------------------------------------
    
    func setProperties()
    {
        var delegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        delegate.window?.backgroundColor = UIColor.blackColor();
        
        self.NUM_ROWS = levels[CURRENT_LEVEL].dimension;
        self.MINE_SPEED = levels[CURRENT_LEVEL].speed;
        self.POLICY = levels[CURRENT_LEVEL].policy;
        self.difficulty_indicator.text = levels[CURRENT_LEVEL].difficulty;
        self.NUM_COLS = NUM_ROWS;
        self.NUM_LOCS = NUM_COLS * NUM_ROWS;
        level_indicator.text = String(format:"LEVEL %i", getLocalLevel());
        switch difficulty_indicator.text as String!
        {
            case EASY: difficulty_indicator.textColor = UIColor.greenColor();
            case MEDIUM: difficulty_indicator.textColor = UIColor.yellowColor();
            case HARD:  difficulty_indicator.textColor = UIColor.orangeColor();
            case INSANE:  difficulty_indicator.textColor = UIColor.whiteColor();
            case IMPOSSIBLE:  difficulty_indicator.textColor = UIColor.redColor();
            default: difficulty_indicator.textColor = UIColor.whiteColor();
        }
        level_indicator.textColor = LIGHT_BLUE;
        var total = UILabel();
        total.text = level_indicator.text! + difficulty_indicator.text!;
        total.sizeToFit();
        var total_width:CGFloat = total.frame.width;  // get total width text takes up
        
        total.text = level_indicator.text!;
        total.sizeToFit();
        var level_width:CGFloat = total.frame.width;
        var dific_width:CGFloat = total_width - level_width;
        
        var padding:CGFloat = dific_width - level_width;
        var height = global_but_dim;
        
        var y_origin = ((superview.bounds.height - superview.bounds.width) * 0.5) - global_but_dim;
        if((DEVICE_VERSION == DEVICE_TYPE.IPAD) || (DEVICE_VERSION == DEVICE_TYPE.IPHONE_4))
        {
            y_origin = ((superview.bounds.height - superview.bounds.width) * 0.25) - (global_but_dim * 0.5);
        }
        
        var const_margin:CGFloat = 25.0

        if(padding > 0) // must pad level side to center
        {
            var level_width = (superview.bounds.width / 2.0) - padding;
            var diffic_width = (superview.bounds.width / 2.0);
            var margin:CGFloat = 15.0;
            var shift:CGFloat = (padding - margin) / 2.0;
            level_indicator.frame = CGRect(x: shift, y: y_origin , width: level_width, height: height);
            difficulty_indicator.frame = CGRect(x: (superview.bounds.width / 2.0) - shift, y: y_origin, width: diffic_width, height: height);
        }
            
        else    // must pad difficulty side to center
        {
            padding *= -1;
            var level_width = (superview.bounds.width / 2.0);
            var diffic_width = (superview.bounds.width / 2.0) - padding;
            var margin:CGFloat = 15.0;
            var shift:CGFloat = (padding - margin) / 2.0;
            
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
    
    func reset()
    {

        setProperties();
        map.removeAll(keepCapacity: false);
        self.COUNT = 0;
        self.GAME_OVER = false;
        self.GAME_STARTED = false;
        generateMap();
        game_clock = 0.0;
    }
    
    func increment_level()
    {
        CURRENT_LEVEL += 1;
        if(CURRENT_LEVEL >= NUM_LEVELS)
        {
            CURRENT_LEVEL = NUM_LEVELS - 1;
        }
        reset();
    }
    func decrement_level()
    {
        CURRENT_LEVEL--;
        if(CURRENT_LEVEL < 0)
        {
            CURRENT_LEVEL = 0;
        }
        reset();
    }
    
    func GoToLevelMenu()
    {
        var delegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        delegate.window?.backgroundColor = LIGHT_BLUE;
        self.view.removeFromSuperview();
        play_sound(SOUND.DEFAULT);
    }
    
    func GoToMainMenu()
    {
        self.view.removeFromSuperview();
        var parent:LevelController = self.parentViewController as! LevelController;
        parent.go_to_main();
    }

    func won_game()->Bool
    {
        return (COUNT == NUM_LOCS);
    }
    
    func neighbors(var index:Int)->(Array<Int>)
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
    
    func unmarked_neighbors(var index:Int)->(Array<Int>)
    {
        var neighbor_indicies:Array<Int> = neighbors(index);
        var unexplored:Array<Int> = Array<Int>();
        for(var i = 0; i < neighbor_indicies.count; ++i)
        {
            if(!map[neighbor_indicies[i]].mine_exists && !map[neighbor_indicies[i]].explored)
            {
                unexplored.append(neighbor_indicies[i]);
            }
        }
        return unexplored;
    }
    
    func printNeighbors(var index:Int)
    {
        println("--------------------------------------");
        var neighbor_indicies:Array<Int> = neighbors(index);
        println(String(format:"Neighbors of location %i", index));
        for(var i = 0; i <  neighbor_indicies.count; ++i)
        {
            println(String(neighbor_indicies[i]));
        }
        println("--------------------------------------\n");
    }
    
    func mark_mine(var loc_id:Int)
    {
        map[loc_id].mark_mine();
        map[loc_id].mine_exists = true;
        ++COUNT;
    }
    
    // MARKS GAME ACCORDINGLY IF WON OR LOST AND INVALIDATES ALL TIMERS
    func end_game()
    {
        let game_time = game_clock; // game clock is reset we need temp variable to hold time...
        nextController.set_time(String(format: "%.2f", game_time));
        stop_game_clock();
        LevelsController.loadData();
        for(var i = 0; i < NUM_LOCS; ++i)
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
                    map[i].backgroundColor = UIColor.redColor();
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
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext!;
        
        var fetch = NSFetchRequest(entityName: "Level");
        var pred = NSPredicate(format: "level_no = %i", CURRENT_LEVEL);
        fetch.predicate = pred;
        
        var error:NSError?;
        var results:[NSManagedObject] = managedContext.executeFetchRequest(fetch, error: &error) as! [NSManagedObject];
        var beat_difficulty = false;
        var flag = false;
        var difficulty = levels[CURRENT_LEVEL].difficulty;
        if(LevelsController.level_buttons[CURRENT_LEVEL].level_data == nil)
        {
            var description = NSEntityDescription.entityForName("Level", inManagedObjectContext: managedContext);
            var managedObject = NSManagedObject(entity: description!, insertIntoManagedObjectContext: managedContext);
            managedObject.setValue(CURRENT_LEVEL, forKey: "level_no");
            managedObject.setValue(prog, forKey: "progress");
            managedObject.setValue(Float(game_time), forKey: "time");
            LevelsController.level_buttons[CURRENT_LEVEL].level_data = managedObject;
            managedContext.insertObject(managedObject);
            var error2:NSError?;
            managedContext.save(&error2);
        }
        else
        {
            // get prev progress-> update only if current score greater than prev
            var prev_progress:Int = LevelsController.level_buttons[CURRENT_LEVEL].level_data?.valueForKey("progress") as! Int;
            if(prog > prev_progress)
            {
                managedContext.deleteObject(LevelsController.level_buttons[CURRENT_LEVEL].level_data!);
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
                LevelsController.level_buttons[CURRENT_LEVEL].level_data = nil;
                game_clock = game_time;
                end_game();
            }
            else if((prog == prev_progress) && (prog == 3)) // update best time if necessary
            {
                // get previoius time
                var previous_time:Float = LevelsController.level_buttons[CURRENT_LEVEL].level_data?.valueForKey("time") as! Float;
                if(Float(game_time) < previous_time)
                {
                    LevelsController.level_buttons[CURRENT_LEVEL].level_data?.setValue(Float(game_time), forKey: "time");
                    // save new time update
                    managedContext.save(&error);
                    achievementController.set_text(String(format: "New Best Time For Level %i", getLocalLevel()));
                    achievementController.animate();
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
        GKGameViewController.update_achievements(difficulty);
    }
    
    func unmarked_global()->(Array<Int>)
    {
        var arr = Array<Int>();
        for(var i = 0; i < NUM_LOCS; ++i)
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
        
        for(var i = 0; i < num_slow; ++i)
        {
            speed_pool.append(SPEED.SLOW);
        }
        for(var i = 0; i < num_fast; ++i)
        {
            speed_pool.append(SPEED.FAST);
        }
        // get random speed out of distribution of those generated
        var speed_index = arc4random_uniform(10);
        var mine_speed = speed_pool[Int(speed_index)];
        
        //
        var local_unmarked = unmarked_neighbors(loc_id);
        var global_unmarked = unmarked_global();
        
        if((policy == MINE_POLICY.LOCAL) && (local_unmarked.count > 0) )
        {
            var temp_index = Int(arc4random_uniform(UInt32(local_unmarked.count)));
            var index = local_unmarked[temp_index];
            map[index].speed = mine_speed;
            mark_mine(index);
        }
        else if((policy == MINE_POLICY.GLOBAL) && (global_unmarked.count > 0))
        {
            var temp_index = Int(arc4random_uniform(UInt32(global_unmarked.count)));
            var index = global_unmarked[temp_index];
            map[index].speed = mine_speed;
            mark_mine(index);
        }
        else    // MIXED policy
        {
            // generate random number from 0-1, and chose mine speed on 50/50 distribution
            var rand_num = arc4random_uniform(2); // can be either 0 or 1
            if(rand_num == 0)
            {
                generate_mines(MINE_POLICY.LOCAL, loc_id: loc_id);
            }
            else
            {
                generate_mines(MINE_POLICY.GLOBAL, loc_id: loc_id);
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
        self.game_timer = NSTimer.scheduledTimerWithTimeInterval(precision, target: self, selector: "update_game_clock", userInfo: nil, repeats: true);
    }
    
    func mark_location(button:UIButton)
    {
        var loc_id:Int = button.tag
        if(GAME_STARTED == false)
        {
            if(loc_id == START_LOC) // dont start game until user presses start button
            {
                GAME_STARTED = true;
                map[loc_id].setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal);
                mark_location(button);
                map[loc_id].explored = true;
                play_sound(SOUND.EXPLORED);
                // begin game timer
                game_timer = NSTimer.scheduledTimerWithTimeInterval(precision, target: self, selector: "update_game_clock", userInfo: nil, repeats: true);
            }
        }
        else if(!GAME_OVER)
        {
            if(map[loc_id].mine_exists)
            {
                play_sound(SOUND.LOST);
                
                // game is over
                GAME_OVER = true;
                end_game();
                map[loc_id].setTitleColor(UIColor.redColor(), forState: UIControlState.Normal);
                map[loc_id].backgroundColor = UIColor.blackColor();
                map[loc_id].layer.borderWidth = 1.0;
                map[loc_id].layer.borderColor = UIColor.whiteColor().CGColor;
                map[loc_id].set_image("mine_white");
            }
            else if(!map[loc_id].explored)
            {
                play_sound(SOUND.EXPLORED);
                map[loc_id].mark_explored();
                ++COUNT;
                if(won_game())
                {
                    play_sound(SOUND.WON);
                    
                    self.bottom_text.textColor = LIGHT_BLUE;
                    GAME_OVER = true;
                    end_game();
                }
                else if((!GAME_OVER) && ((NUM_LOCS - COUNT) > 2))
                    // mine will never fill last unexplored cell
                {
                    generate_mines(self.POLICY, loc_id: loc_id);
                }
            }
        }
    }
    
    func generateMap()
    {
        var margin_height = (superview.bounds.height - superview.bounds.width) / 2.0;
        var size:Float = 1.0;
        // create grid of elements
        for(var row = 0; row < self.NUM_ROWS; ++row)
        {
            for(var col = 0; col < self.NUM_COLS; ++col)
            {

                var width_const:CGFloat = CGFloat(1.0 / CGFloat(self.NUM_COLS));
                var height_const:CGFloat = CGFloat(1.0 / CGFloat(self.NUM_ROWS));
                
                var loc = (row * NUM_COLS) + col;
                var subview:Mine_cell = Mine_cell(location_identifier:loc);
                subview.setTranslatesAutoresizingMaskIntoConstraints(false);
                
                var width = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: width_const, constant: 0.0);
                
                var height = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: subview, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0);
                
                var increment_centerx:CGFloat  = (CGFloat(superview.bounds.width) / CGFloat(NUM_COLS) * 0.5) + (CGFloat(superview.bounds.width) / CGFloat(NUM_COLS) * CGFloat(col));
                
                var increment_x = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: increment_centerx);
                
                var increment_centery:CGFloat  = (superview.bounds.width / CGFloat(NUM_ROWS) * 0.5) + (superview.bounds.width / CGFloat(NUM_ROWS) * CGFloat(row));
                
                var increment_y = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: increment_centery + margin_height);
                
                subview.backgroundColor = UIColor.whiteColor();
                subview.layer.borderWidth = 1.0;
                subview.tag = (row * NUM_COLS) + col;
                subview.addTarget(self, action: "mark_location:", forControlEvents: UIControlEvents.TouchDown);
                
                
                superview.addSubview(subview);
                superview.addConstraint(width);
                superview.addConstraint(height);
                superview.addConstraint(increment_x);
                superview.addConstraint(increment_y);
                // tag element to uniquely identify it
                subview.tag = (row * NUM_COLS) + col;
                var tag:Int = (row * NUM_COLS) + col;
                self.map.append(subview);
            }
        }
        
        
        self.map[self.START_LOC].backgroundColor = UIColor.grayColor();
        self.map[self.START_LOC].setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
        self.map[self.START_LOC].setTitle("START", forState: UIControlState.Normal);
        var font_size:CGFloat = 12.0 + ((8.0 - CGFloat(NUM_ROWS)) * 2.0);
        if(NUM_ROWS >= 6)
        {
            self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 12.0);
        }
        if(NUM_ROWS == 5)
        {
            self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 15.0);
        }
        if(NUM_ROWS == 4)
        {
            self.map[self.START_LOC].titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO" , size: 18.0);
        }
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        superview.backgroundColor = UIColor.blackColor();
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
        var back_x:CGFloat = global_but_margin;
        var back_width:CGFloat = global_but_dim;
        var back_height:CGFloat = global_but_dim;
        back_button = UIButton(frame: CGRect(x: back_x, y: back_y, width: back_width, height: back_height));
        back_button.setBackgroundImage(UIImage(named: "prev_level"), forState: UIControlState.Normal);
        back_button.layer.borderWidth = 1.0;
        back_button.layer.borderColor = UIColor.whiteColor().CGColor;
        back_button.addTarget(self, action:"GoToLevelMenu", forControlEvents: UIControlEvents.TouchUpInside);
        superview.addSubview(back_button);
        back_button.layoutIfNeeded();
        back_button.setNeedsLayout();
        
        // configure level indicator
        level_indicator.textAlignment = NSTextAlignment.Right;
        difficulty_indicator.textAlignment = NSTextAlignment.Left;
        superview.addSubview(difficulty_indicator);
        superview.addSubview(level_indicator);
        setProperties();
        
        // add child view controller
        self.addChildViewController(nextController);
        
        self.NUM_ROWS = levels[CURRENT_LEVEL].dimension;
        self.NUM_COLS = NUM_ROWS;
        self.NUM_LOCS = NUM_COLS * NUM_ROWS;
        
        map.removeAll(keepCapacity: true);
        setProperties();
        generateMap();  // generate map to play on
        
        var margin_height = (superview.bounds.height - superview.bounds.width) / 2.0;
        
        superview.layer.borderWidth = 2.0;
        superview.layer.borderColor = UIColor.blackColor().CGColor
        
        self.bottom_text.setTranslatesAutoresizingMaskIntoConstraints(false);
        var center_x = NSLayoutConstraint(item: bottom_text, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var center_y_const = (superview.bounds.width + superview.bounds.height) / 2.0;
        var center_y = NSLayoutConstraint(item: bottom_text, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: center_y_const);
        
        var menu_font_size:CGFloat = 20.0
        superview.addSubview(self.bottom_text);
        superview.addConstraint(center_x);
        superview.addConstraint(center_y);
        
        self.bottom_text.textColor = UIColor.whiteColor();
        self.bottom_text.textAlignment = NSTextAlignment.Center;
        self.bottom_text.font = UIFont(name: "Arial-BoldMT" , size: 35.0);

        update_local_level();

        var repeat_image = UIImage(named: "repeat_level");
        var prev_image = UIImage(named: "prev_level");
        var next_image = UIImage(named: "next_level");
        
        
        // get y for buttons, this will be different depending on device
        var button_y:CGFloat = ((superview.bounds.height - superview.bounds.width) * 0.5) + global_but_margin + superview.bounds.width;
        if((DEVICE_VERSION == DEVICE_TYPE.IPAD) || (DEVICE_VERSION == DEVICE_TYPE.IPHONE_4))
        {
            button_y = (((superview.bounds.height - superview.bounds.width) * 0.75) + superview.bounds.width) - (global_but_dim * 0.5);
        }
        
        // configure previous button
        var prev_x:CGFloat = (superview.bounds.width - ((3.0 * global_but_dim) + (2.0 * global_but_margin))) / 2.0;
        var prev_width:CGFloat = global_but_dim;
        var prev_height:CGFloat = global_but_dim;
        prev_button = UIButton(frame: CGRect(x: prev_x, y: button_y, width: prev_width, height: prev_height));
        prev_button.setBackgroundImage(prev_image, forState: UIControlState.Normal);
        prev_button.layer.borderWidth = 1.0;
        prev_button.layer.borderColor = UIColor.whiteColor().CGColor;
        prev_button.layer.backgroundColor = UIColor.blackColor().CGColor;
        prev_button.addTarget(self, action: "deceremenet_level", forControlEvents: UIControlEvents.TouchUpInside);
        
        // configure repeat button
        var repeat_x:CGFloat = prev_button.frame.origin.x + global_but_dim + global_but_margin;
        var repeat_width:CGFloat = global_but_dim;
        var repeat_height:CGFloat = global_but_dim;
        repeat_button = UIButton(frame: CGRect(x: repeat_x, y: button_y, width: repeat_width, height: repeat_height));
        repeat_button.setBackgroundImage(repeat_image, forState: UIControlState.Normal);
        repeat_button.layer.borderWidth = 1.0;
        repeat_button.layer.borderColor = UIColor.whiteColor().CGColor;
        repeat_button.layer.backgroundColor = UIColor.blackColor().CGColor;
        repeat_button.addTarget(self, action: "reset", forControlEvents: UIControlEvents.TouchUpInside);
        
        // configure next button
        var next_x:CGFloat = repeat_button.frame.origin.x + global_but_dim + global_but_margin;
        var next_width:CGFloat = global_but_dim;
        var next_height:CGFloat = global_but_dim;
        next_button = UIButton(frame: CGRect(x: next_x, y: button_y, width: next_width, height: next_height));
        next_button.setBackgroundImage(next_image, forState: UIControlState.Normal);
        next_button.layer.borderWidth = 1.0;
        next_button.layer.borderColor = UIColor.whiteColor().CGColor;
        next_button.layer.backgroundColor = UIColor.blackColor().CGColor;
        next_button.addTarget(self, action: "increment_level", forControlEvents: UIControlEvents.TouchUpInside);
        
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
    var timer = NSTimer();
    var timer_running:Bool = false;
    var speed:SPEED;
    var startup_time:NSTimeInterval = NSTimeInterval();
    
    required init(coder aDecoder: NSCoder) {
        loc_id = -1;
        mine_exists = false;
        insignia = "";
        explored = false;
        speed = SPEED.SLOW;
        super.init(frame:CGRectZero);
    }
    init(location_identifier:Int)
    {
        loc_id = location_identifier;
        explored = false;
        mine_exists = false;
        insignia = "";
        timer_running = false;
        speed = SPEED.SLOW;
        super.init(frame:CGRectZero);
        loc_id = location_identifier;
    }
    func pause()
    {
        if(timer.valid)
        {
            var paused_date = NSDate();
            startup_time = timer.fireDate.timeIntervalSinceDate(paused_date);
            timer.fireDate = NSDate(timeIntervalSinceReferenceDate: Double.infinity);   // keep timer from firing
        }
    }
    func resume()
    {
        if(timer.valid)
        {
            timer.fireDate = NSDate(timeInterval: startup_time, sinceDate: NSDate());
        }
    }
    
    func set_image(var name:String)
    {
        var image = UIImage(named: name);
        setBackgroundImage(image, forState: UIControlState.Normal);
    }
    func update()
    {
        if(time_til_disappears > 0)
        {
            --time_til_disappears;
            if(speed == SPEED.SLOW)
            {
                switch time_til_disappears
                {
                case 3:
                    set_image("mine_red");
                case 2:
                    set_image("mine_orange");
                case 1:
                    set_image("mine_yellow");
                case 0:
                    setImage(nil, forState: UIControlState.Normal);
                default:
                    setImage(nil, forState: UIControlState.Normal);
                }
            }
            else if(speed == SPEED.FAST)
            {
                switch time_til_disappears
                {
                case 3:
                    set_image("mine_dark_blue");
                case 2:
                    set_image("mine_blue");
                case 1:
                    set_image("mine_light_blue");
                case 0:
                    setImage(nil, forState: UIControlState.Normal);
                default:
                    setImage(nil, forState: UIControlState.Normal);
                }
            }
        }
        else    // remove mine indicator
        {
            timer.invalidate();
            setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal);
            imageView?.image = nil;
            timer_running = false;
            setBackgroundImage(nil, forState: UIControlState.Normal);
        }
    }
    func mark_mine()
    {
        mine_exists = true;
        setTitle(insignia, forState: UIControlState.Normal);
        set_image("mine_black");
        
        if(timer_running == false)
        {
            if(speed == SPEED.SLOW)
            {
                time_til_disappears = 4;
                timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "update", userInfo: nil, repeats: true);
                timer_running = true;
            }
            else if(speed == SPEED.FAST)
            {
                time_til_disappears = 4;
                timer = NSTimer.scheduledTimerWithTimeInterval(0.125, target: self, selector: "update", userInfo: nil, repeats: true);
                timer_running = true;
            }
        }
    }
    func mark_explored()
    {
        if(!explored)
        {
            explored = true;
            backgroundColor = UIColor.grayColor();
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
        completed_label.textColor = UIColor.orangeColor();
        completed_label.text = String(format: "Level %i Completed", getLocalLevel());
        next_level.setTitle("Next Level", forState: UIControlState.Normal);
        next_level.removeTarget(gameController, action: "reset", forControlEvents: UIControlEvents.TouchUpInside);
        next_level.addTarget(gameController, action: "increment_level", forControlEvents: UIControlEvents.TouchUpInside);
        x_button.layer.borderColor = UIColor.orangeColor().CGColor;
        x_button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
        
    }
    func markLost()
    {
        completed_label.textColor = UIColor.redColor();
        completed_label.text = String(format: "Level %i Failed", getLocalLevel());
        next_level.setTitle("Repeat Level", forState: UIControlState.Normal);
        next_level.removeTarget(gameController, action: "increment_level", forControlEvents: UIControlEvents.TouchUpInside);
        next_level.addTarget(gameController, action: "reset", forControlEvents: UIControlEvents.TouchUpInside);
        x_button.layer.borderColor = UIColor.redColor().CGColor;
        x_button.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted);
    }
    
    func set_time(var time:String)
    {
        time_label.text = time;
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        var margin:CGFloat = superview.bounds.height * 0.05;
        var super_width:CGFloat = superview.bounds.width - (2.0 * margin);
        var super_height:CGFloat = super_width;
        var super_x:CGFloat = margin;
        var super_y:CGFloat = ((superview.bounds.height - super_width) / 2.0) - (banner_view.bounds.height / 2.0);
        superview.frame = CGRect(x: super_x, y: super_y, width: super_width, height: super_height);
        
        // configure complete container
        complete_container.frame = superview.bounds;
        superview.addSubview(complete_container);
        complete_container.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8);
        complete_container.layer.borderWidth = 1.0;
        complete_container.layer.borderColor = UIColor.whiteColor().CGColor;

        // add x button
        x_button.setTranslatesAutoresizingMaskIntoConstraints(false);
        x_button.setTitle("X", forState: UIControlState.Normal);
        x_button.clipsToBounds = true;
        x_button.layer.cornerRadius = 15.0;
        x_button.layer.borderWidth = 1.0;
        x_button.backgroundColor = UIColor.blackColor();
        x_button.alpha = 0.85;
        x_button.addTarget(self, action: "exit", forControlEvents: UIControlEvents.TouchDown);
        
        
        // add constraints
        var x_button_centery = NSLayoutConstraint(item: x_button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0);
        
        var x_button_centerx = NSLayoutConstraint(item: x_button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0);
        
        // conform hiearchy
        superview.addSubview(x_button);
        superview.addConstraint(x_button_centery);
        superview.addConstraint(x_button_centerx);
        
        // confiugure label
        var label_height:CGFloat = complete_container.bounds.height / 8.0;
        completed_label.frame = CGRect(x: 0.0, y: (complete_container.bounds.height / 3.0) - (label_height / 2.0), width: complete_container.bounds.width, height: label_height);
        completed_label.textAlignment = NSTextAlignment.Center;
        complete_container.addSubview(completed_label);
        completed_label.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 25.0);
        
        // configure next level button
        complete_container.addSubview(next_level);
        var next_y:CGFloat = complete_container.bounds.height * 2.0 / 3.0;
        var next_x:CGFloat = margin;
        var next_width:CGFloat = complete_container.bounds.width - (2.0 * margin);
        var next_height:CGFloat = complete_container.bounds.height / 6.0;
        next_level.frame = CGRect(x: next_x, y: next_y, width: next_width, height: next_height);
        next_level.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        next_level.layer.borderWidth = 1.0;
        next_level.layer.borderColor = UIColor.whiteColor().CGColor;
        next_level.setTitleColor(LIGHT_BLUE, forState: UIControlState.Highlighted);
        next_level.titleLabel?.font = UIFont(name: "MicroFLF", size: 17.0);
        
        // configure time label
        time_label.frame = superview.bounds;
        time_label.textAlignment = NSTextAlignment.Center;
        time_label.textColor = UIColor.whiteColor();
        time_label.font = UIFont(name: "MicroFLF", size: 17.0);
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
    
    func setDifficulty(var in_difficulty:String)
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
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
       
        margin = superview.bounds.height * 0.05;
        var x:CGFloat = margin;
        var y:CGFloat = (superview.bounds.height - superview.bounds.width) / 2.0;
        var width:CGFloat = superview.bounds.width - (2.0 * margin);
        var height:CGFloat = width;
        var frame = CGRect(x: x, y: y, width: width, height: height);
        
        // configure text_view
        superview.addSubview(text_view);
        text_view.frame = frame;
        text_view.textAlignment = NSTextAlignment.Center;
        text_view.textColor = UIColor.whiteColor();
        text_view.text = text;
        text_view.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 30.0);
        text_view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5);
        text_view.layer.borderWidth = 1.0;
        text_view.layer.borderColor = UIColor.whiteColor().CGColor;
        text_view.editable = false;
        
        // configure continue button
        var cont_x:CGFloat = text_view.bounds.width * 0.25;
        var cont_y:CGFloat = (text_view.bounds.height * 0.5);
        var cont_width:CGFloat = text_view.bounds.width * 0.5;
        var cont_height:CGFloat = cont_width;
        continue_button.frame = CGRect(x: cont_x, y: cont_y, width: cont_width, height: cont_height);
        text_view.addSubview(continue_button);
        continue_button.setBackgroundImage(UIImage(named: "next_level"), forState: UIControlState.Normal);
        continue_button.addTarget(self, action: "exit", forControlEvents: UIControlEvents.TouchUpInside);
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
        
        var super_x:CGFloat = 0.0;
        var super_y:CGFloat = (superview.bounds.height - superview.bounds.width - banner_view.bounds.height) / 2.0;
        var super_width:CGFloat = superview.bounds.width;
        var super_height:CGFloat = super_width;
        superview.frame = CGRect(x: super_x, y: super_y, width: super_width, height: super_height);
        superview.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3);
        
        // configure visual attributes
        var margin:CGFloat = superview.bounds.width * 0.1;
        var x:CGFloat = margin;
        var y:CGFloat = margin;
        var width:CGFloat = superview.bounds.width - (2.0 * margin);
        var height:CGFloat = width;
        
        play_button.frame = CGRect(x: x, y: y, width: width, height: height);
        superview.addSubview(play_button);
        play_button.setBackgroundImage(UIImage(named: "play"), forState: UIControlState.Normal);
        play_button.alpha = 0.7;
        play_button.setTitle("RESUME", forState: UIControlState.Normal);
        play_button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
        play_button.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 30.0);
        play_button.addTarget(gameController, action: "resume_game", forControlEvents: UIControlEvents.TouchUpInside);
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
    var speed = NSTimeInterval(1.0);
    var pause = NSTimeInterval(5.0);
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        var height:CGFloat = back_button_size;
        var width:CGFloat = superview.bounds.width / 1.5;
        var y:CGFloat = global_but_margin;
        var x:CGFloat = superview.bounds.width + width;
        out_frame = CGRect(x: x, y: y, width: width, height: height);
        in_frame = CGRect(x: superview.bounds.width - width - global_but_margin, y: y, width: width, height: height);
        superview.frame = out_frame;
        superview.addSubview(label);
        label.font = UIFont(name: "MicroFLF", size: 14.0);
        label.textColor = UIColor.blackColor();
        label.frame = superview.bounds;
        label.textAlignment = NSTextAlignment.Center;
        superview.addSubview(label);
        superview.backgroundColor = LIGHT_BLUE;
    }
    
    func set_text(var in_text:String)
    {
        label.text = in_text;
    }

    func animate()
    {
        UIView.animateWithDuration(speed, animations: {self.superview.frame = self.in_frame});
        UIView.animateWithDuration(speed, delay: pause, options: nil, animations: {self.superview.frame = self.out_frame}, completion: nil);
    }
}



//----------------------------------------------------------------------------------------------------------------
//      END ACHIEVMENT VIEW CONTROLLER CLASS
//----------------------------------------------------------------------------------------------------------------
