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
var levels = Array<MELevel>();
let NUM_LEVELS = 125;
let NUM_SUB_LEVELS = 25;
let NUM_MEGA_LEVELS = 5;
var VOLUME_LEVEL:Float = 1.0;

var level_data:[NSManagedObject] = [NSManagedObject]();

// LEVEL CLASS THAT HOLDS LEVEL DIM, SPEED, POLICY DATA
class MELevel:UIButton
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
        super.init(frame: CGRect.zero);
    }
    required init(coder aDecoder: NSCoder)
    {
        super.init(frame: CGRect.zero);
    }
    override init(frame: CGRect)
    {
        super.init(frame:frame);
    }
    init(in_level:Int, in_speed:Int, in_policy:MINE_POLICY, in_dimension:Int, in_difficulty:String)
    {
        super.init(frame: CGRect.zero);
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
    for mega in 0..<NUM_MEGA_LEVELS {
        for i in 0..<NUM_SUB_LEVELS
        {
            // determine mine speed
            let speed = Int(ceil((Double(i)) / Double(NUM_SUB_LEVELS) * 10.0));
            
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
            let level_no = i; // (mega * NUM_SUB_LEVELS) + i;
            levels.append(MELevel(in_level: level_no, in_speed: speed, in_policy: policy, in_dimension: 4 + mega, in_difficulty: DIFFICULTY[mega]));
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
        let width = super_view.bounds.width * 0.75;
        complete_container.layer.borderWidth = 1.0;
        complete_container.layer.borderColor = UIColor.white.cgColor;
        complete_container.backgroundColor = UIColor.black;
        complete_container.alpha = 0.85;
        
        // add constraints
        complete_container.translatesAutoresizingMaskIntoConstraints = false
        let centerx = NSLayoutConstraint(item: complete_container, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: super_view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0);
        
        let centery = NSLayoutConstraint(item: complete_container, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: super_view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0);
        
        let width_container = NSLayoutConstraint(item: complete_container, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: width);
        
        let height_container = NSLayoutConstraint(item: complete_container, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: width);
        
        super_view.addSubview(complete_container);
        super_view.addConstraint(centerx);
        super_view.addConstraint(centery);
        super_view.addConstraint(width_container);
        super_view.addConstraint(height_container);
        
        // add x button
        x_button.translatesAutoresizingMaskIntoConstraints = false;
        x_button.setTitle("X", for: UIControlState.normal);
        x_button.clipsToBounds = true;
        x_button.layer.cornerRadius = 15.0;
        x_button.layer.borderWidth = 1.0;
        x_button.backgroundColor = UIColor.black;
        x_button.alpha = 0.85;
        
        if(self.won_game)
        {
            x_button.layer.borderColor = UIColor.orange.cgColor;
            x_button.setTitleColor(UIColor.orange, for: UIControlState.highlighted);
        }
        else
        {
            x_button.layer.borderColor = UIColor.red.cgColor;
            x_button.setTitleColor(UIColor.red, for: UIControlState.highlighted);
        }
        
        // add constraints
        let x_button_centery = NSLayoutConstraint(item: x_button, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0);
        
        let x_button_centerx = NSLayoutConstraint(item: x_button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0);
        
        // conform hiearchy
        super_view.addSubview(x_button);
        super_view.addConstraint(x_button_centery);
        super_view.addConstraint(x_button_centerx);
        
        // add win or loss label
        
        let completed_label = UILabel();
        completed_label.font = UIFont(name: "Arial", size: 25.0);
        
        if(won_game)
        {
            completed_label.textColor = UIColor.orange;
            completed_label.text = String(format: "Level %i Completed", local_level);
        }
        else
        {
            completed_label.textColor = UIColor.red;
            completed_label.text = String(format: "Level %i Failed", local_level);
        }
        
        // add constraints
        completed_label.translatesAutoresizingMaskIntoConstraints = false
        let centerx_label = NSLayoutConstraint(item: completed_label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0);
        
        let centery_label = NSLayoutConstraint(item: completed_label, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: width / 3.0);
        
        complete_container.addSubview(completed_label);
        complete_container.addConstraint(centerx_label);
        complete_container.addConstraint(centery_label);
        
        // add next level button
        next_level.translatesAutoresizingMaskIntoConstraints = false;
        next_level.setTitleColor(UIColor.white, for: UIControlState.normal);
        next_level.layer.borderWidth = 1.0;
        next_level.layer.borderColor = UIColor.white.cgColor;
        next_level.setTitleColor(LIGHT_BLUE, for: UIControlState.highlighted);
        if(won_game)
        {
            next_level.setTitle("Next Level", for: UIControlState.normal);
        }
        else
        {
            next_level.setTitle("Repeat Level", for: UIControlState.normal);
        }
        
        // add constraints
        let centery_next_level = NSLayoutConstraint(item: next_level, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: width * 3.0 / 5.0);
        
        // add constraints
        let centerx_next_level = NSLayoutConstraint(item: next_level, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0);
        
        let width_next_level = NSLayoutConstraint(item: next_level, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: complete_container, attribute: NSLayoutAttribute.width, multiplier: 0.85, constant: 0.0);
        
        let height_next_level = NSLayoutConstraint(item: next_level, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: next_level, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -40.0);
        
        complete_container.addSubview(next_level);
        complete_container.addConstraint(centery_next_level);
        complete_container.addConstraint(centerx_next_level);
        complete_container.addConstraint(width_next_level);
        complete_container.addConstraint(height_next_level);
    }
    // remove the window prompt
    func bring_down_window()
    {
        for i in 0..<complete_container.subviews.count
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
    let index:Int = current_level / NUM_SUB_LEVELS;
    current_difficulty = DIFFICULTY[index];
}

