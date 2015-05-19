//
//  level.swift
//  MineEscape
//
//  Created by Alex Harrison on 3/28/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import UIKit
import CoreData

enum MINE_POLICY{case LOCAL, GLOBAL, MIXED};
var levels = Array<Level>();
let NUM_LEVELS = 125;
let NUM_SUB_LEVELS = 25;
let NUM_MEGA_LEVELS = 5;
var VOLUME_LEVEL:Float = 1.0;

var level_data:[NSManagedObject] = [NSManagedObject]();

// LEVEL CLASS THAT HOLDS LEVEL DIM, SPEED, POLICY DATA
class Level:UIButton
{
    var level:Int = 0;
    var speed:Int = 0;
    var policy:MINE_POLICY = MINE_POLICY.LOCAL;
    var dimension:Int = 4;
    var best_time:String = "N/A";
    var progress:Int = 0;
    var difficulty:String = EASY;
    
    init()
    {
        super.init(frame: CGRectZero);
    }
    required init(coder aDecoder: NSCoder)
    {
        super.init(frame: CGRectZero);
    }
    override init(frame: CGRect)
    {
        super.init(frame:frame);
    }
    init(in_level:Int, in_speed:Int, in_policy:MINE_POLICY, in_dimension:Int, in_difficulty:String)
    {
        super.init(frame: CGRectZero);
        self.dimension = in_dimension;
        self.policy = in_policy;
        self.level = in_level;
        self.speed = in_speed;
        self.difficulty = in_difficulty;
    }
}

// GENERATES LEVELS OF INCREASING DIFFICULTY
func gen_levels()
{
    let NUM_SUB_LEVELS = NUM_LEVELS / NUM_MEGA_LEVELS;
    for(var mega = 0; mega < NUM_MEGA_LEVELS; ++mega)
    {
        for(var i = 0; i < NUM_SUB_LEVELS; ++i)
        {
            // determine mine speed
            var speed = Int(ceil((Double(i)) / Double(NUM_SUB_LEVELS) * 10.0));
            
            // determine mine policy
            var policy:MINE_POLICY;
            if(i < (NUM_SUB_LEVELS / 3))
            {
                // local policy
                policy = MINE_POLICY.LOCAL;
            }
            else if (i < (NUM_LEVELS * 2 / 3))
            {
                // mixed policy
                policy = MINE_POLICY.MIXED;
            }
            else
            {
                // global policy
                policy = MINE_POLICY.GLOBAL;
            }
            var level_no = i; // (mega * NUM_SUB_LEVELS) + i;
            levels.append(Level(in_level: level_no, in_speed: speed, in_policy: policy, in_dimension: 4 + mega, in_difficulty: DIFFICULTY[mega]));
        }
    }
}

// Window that prompts user to go to the next game if they win, or repeat if they loose
class NextGameWindow
{
    // create view that will hold next level
    var complete_container = UIView();
    var won_game = false;
    var next_level = UIButton();
    var x_button = UIButton();
    
    func bring_up_window()
    {
        
        // create container to hold next level buttn
        var width = super_view.bounds.width * 0.75;
        complete_container.layer.borderWidth = 1.0;
        complete_container.layer.borderColor = UIColor.whiteColor().CGColor;
        complete_container.backgroundColor = UIColor.blackColor();
        complete_container.alpha = 0.85;
        
        // add constraints
        complete_container.setTranslatesAutoresizingMaskIntoConstraints(false);
        var centerx = NSLayoutConstraint(item: complete_container, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: super_view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var centery = NSLayoutConstraint(item: complete_container, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: super_view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0);
        
        var width_container = NSLayoutConstraint(item: complete_container, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: width);
        
        var height_container = NSLayoutConstraint(item: complete_container, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: width);
        
        super_view.addSubview(complete_container);
        super_view.addConstraint(centerx);
        super_view.addConstraint(centery);
        super_view.addConstraint(width_container);
        super_view.addConstraint(height_container);
        
        // add x button
        x_button.setTranslatesAutoresizingMaskIntoConstraints(false);
        x_button.setTitle("X", forState: UIControlState.Normal);
        x_button.clipsToBounds = true;
        x_button.layer.cornerRadius = 15.0;
        x_button.layer.borderWidth = 1.0;
        x_button.backgroundColor = UIColor.blackColor();
        x_button.alpha = 0.85;
        
        if(self.won_game)
        {
            x_button.layer.borderColor = UIColor.orangeColor().CGColor;
            x_button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
        }
        else
        {
            x_button.layer.borderColor = UIColor.redColor().CGColor;
            x_button.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted);
        }
        
        // add constraints
        var x_button_centery = NSLayoutConstraint(item: x_button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0);
        
        var x_button_centerx = NSLayoutConstraint(item: x_button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0);
        
        // conform hiearchy
        super_view.addSubview(x_button);
        super_view.addConstraint(x_button_centery);
        super_view.addConstraint(x_button_centerx);
        
        // add win or loss label
        
        var completed_label = UILabel();
        completed_label.font = UIFont(name: "Arial", size: 25.0);
        
        if(won_game)
        {
            completed_label.textColor = UIColor.orangeColor();
            completed_label.text = String(format: "Level %i Completed", local_level);
        }
        else
        {
            completed_label.textColor = UIColor.redColor();
            completed_label.text = String(format: "Level %i Failed", local_level);
        }
        
        // add constraints
        completed_label.setTranslatesAutoresizingMaskIntoConstraints(false);
        var centerx_label = NSLayoutConstraint(item: completed_label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var centery_label = NSLayoutConstraint(item: completed_label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: width / 3.0);
        
        complete_container.addSubview(completed_label);
        complete_container.addConstraint(centerx_label);
        complete_container.addConstraint(centery_label);
        
        // add next level button
        next_level.setTranslatesAutoresizingMaskIntoConstraints(false);
        next_level.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        next_level.layer.borderWidth = 1.0;
        next_level.layer.borderColor = UIColor.whiteColor().CGColor;
        next_level.setTitleColor(LIGHT_BLUE, forState: UIControlState.Highlighted);
        if(won_game)
        {
            next_level.setTitle("Next Level", forState: UIControlState.Normal);
        }
        else
        {
            next_level.setTitle("Repeat Level", forState: UIControlState.Normal);
        }
        
        // add constraints
        var centery_next_level = NSLayoutConstraint(item: next_level, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: width * 3.0 / 5.0);
        
        // add constraints
        var centerx_next_level = NSLayoutConstraint(item: next_level, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var width_next_level = NSLayoutConstraint(item: next_level, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: complete_container, attribute: NSLayoutAttribute.Width, multiplier: 0.85, constant: 0.0);
        
        var height_next_level = NSLayoutConstraint(item: next_level, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: next_level, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -40.0);
        
        complete_container.addSubview(next_level);
        complete_container.addConstraint(centery_next_level);
        complete_container.addConstraint(centerx_next_level);
        complete_container.addConstraint(width_next_level);
        complete_container.addConstraint(height_next_level);
    }
    // remove the window prompt
    func bring_down_window()
    {
        for(var i = 0; i < complete_container.subviews.count; ++i)
        {
            complete_container.subviews[i].removeFromSuperview();
        }
        complete_container.removeFromSuperview();
        x_button.removeFromSuperview();
    }
}

func update_local_level()
{
    // update local level
    local_level = (current_level + 1) % NUM_SUB_LEVELS;
    if(local_level == 0)
    {
        local_level = 25; // handle case when level is multiple of 25
    }
    // update difficulty
    var index:Int = current_level / NUM_SUB_LEVELS;
    current_difficulty = DIFFICULTY[index];
}

