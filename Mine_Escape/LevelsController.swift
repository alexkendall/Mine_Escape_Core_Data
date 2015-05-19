//
//  LevelsController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit

var EASY = "EASY", MEDIUM = "MEDIUM", HARD = "HARD", INSANE = "INSANE", IMPOSSIBLE = "IMPOSSIBLE";
var DIFFICULTY:[String] = [EASY, MEDIUM, HARD, INSANE, IMPOSSIBLE];


class level_view:UIButton
{
    var difficulty:String;
    var level:Int;
    var progress:Int;
    var level_status_indicator = Array<UIView>();
    init()
    {
        self.level = 0;
        self.progress = 0;
        self.difficulty = EASY;
        super.init(frame:CGRectZero);
    }
    required init(coder aDecoder: NSCoder) {
        self.level = 0;
        self.progress = 0;
        self.difficulty = EASY;
        super.init(frame:CGRectZero);
    }
    override init(frame: CGRect) {
        self.level = 0;
        self.progress = 0;
        self.difficulty = EASY;
        super.init(frame: frame);
    }
    init(in_level:Int, in_progress:Int, in_difficulty:String)
    {
        self.difficulty = in_difficulty;
        self.level = in_level;
        self.progress = in_progress;
        super.init(frame:CGRectZero);
        self.level = in_level;
    }
    func update_progress()
    {
        var color = UIColor.clearColor();
        if(progress == 3)
        {
            color = UIColor.greenColor();
        }
        else if(progress == 2)
        {
            color = UIColor.yellowColor();
        }
        else if(progress == 1)
        {
            color = UIColor.redColor();
        }
        for(var i = 0; i < progress; ++i)
        {
            level_status_indicator[i].backgroundColor = color;
            level_status_indicator[i].layer.borderWidth = 0.5;
        }
    }
}


class LevelController : ViewController
{
    var scroll_view = UIScrollView();
    var superview = UIView();
    var tabs = Array<UILabel>();
    var level_buttons = Array<UIButton>();
    var back_button = UIButton();
    var title_label = UILabel();
    
    func selected_level(level_button:UIButton)
    {
        play_sound(SOUND.DEFAULT);
        CURRENT_LEVEL = level_button.tag;
        gameController.reset();
        self.view.addSubview(gameController.view);
    }
    
    func go_to_main()
    {
        play_sound(SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }

    override func viewDidLoad()
    {
        superview = self.view;
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        
        addChildViewController(gameController);
        
        // configure scroll view
        var scroll_mult:CGFloat = 0.9;
        
        var scroll_width = NSLayoutConstraint(item: scroll_view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: scroll_mult, constant: 0.0);
        
        var scroll_height = NSLayoutConstraint(item: scroll_view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Height, multiplier: 0.8, constant: 0.0);
        
        var scroll_centerx = NSLayoutConstraint(item: scroll_view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var scroll_centery = NSLayoutConstraint(item: scroll_view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0);
        
        
        add_back_button(&back_button, &superview);
        add_title_button(&title_label, &superview, "Levels", 15.0, 20.0);
        
        back_button.addTarget(self, action: "go_to_main", forControlEvents: UIControlEvents.TouchUpInside);
        scroll_view.setTranslatesAutoresizingMaskIntoConstraints(false);
        scroll_view.backgroundColor = UIColor.clearColor();
        scroll_view.layer.borderColor = UIColor.whiteColor().CGColor;
        scroll_view.layer.borderWidth = 1.0;
        scroll_view.frame = superview.bounds;
        
        superview.addSubview(scroll_view);
        superview.addConstraint(scroll_width);
        superview.addConstraint(scroll_height);
        superview.addConstraint(scroll_centerx);
        superview.addConstraint(scroll_centery);
        
        var margin:CGFloat = 40.0;
        var dimension:Int = Int(sqrt(Float(NUM_SUB_LEVELS)));
        var mega_width:CGFloat = superview.bounds.width * scroll_mult;
        var mega_height:CGFloat = mega_width;
        var sub_height:CGFloat = mega_height / CGFloat(dimension);
        var sub_width:CGFloat = mega_width / CGFloat(dimension);
        
        var content_width:CGFloat = superview.bounds.width * scroll_mult;
        var content_height:CGFloat = (mega_height * CGFloat(NUM_MEGA_LEVELS)) + (CGFloat(NUM_MEGA_LEVELS) * margin);
        
        scroll_view.contentSize = CGSize(width: superview.bounds.width * scroll_mult, height: content_height);
        scroll_view.clipsToBounds = true;
        
        for(var i = 0; i < NUM_MEGA_LEVELS; ++i)
        {
            // configure tab properties
            var tab = UILabel();
            var current_dim = 4 + i;
            tab.backgroundColor = UIColor.whiteColor();
            tab.setTranslatesAutoresizingMaskIntoConstraints(false);
            tab.text = DIFFICULTY[i]; //+ String(format: " - %i X %i ", current_dim, current_dim);
            tab.textAlignment = NSTextAlignment.Center;
            tab.textColor = UIColor.blackColor();
            tabs.append(tab);
            
            // configure constraints
            var baseline = ((margin + mega_height) * CGFloat(i));
            
            var tab_x = NSLayoutConstraint(item:tab, attribute: NSLayoutAttribute.CenterX , relatedBy: NSLayoutRelation.Equal, toItem: scroll_view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
            
            var tab_y = NSLayoutConstraint(item:tab, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scroll_view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: baseline);
            
            var tab_width = NSLayoutConstraint(item:tab, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scroll_view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0);
            
            var tab_height = NSLayoutConstraint(item:tab, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: tab, attribute: NSLayoutAttribute.Height, multiplier: 0, constant: margin);
            
            scroll_view.clipsToBounds = true;
            scroll_view.addSubview(tab);
            scroll_view.addConstraint(tab_x);
            scroll_view.addConstraint(tab_y);
            scroll_view.addConstraint(tab_width);
            scroll_view.addConstraint(tab_height);
            
            for(var row = 0; row < dimension; ++row)
            {
                for(var col = 0; col < dimension; ++col)
                {
                    // configure level button properties
                    var level_but:level_view = level_view(in_level: (row * dimension) + col + 1, in_progress: 0, in_difficulty:DIFFICULTY[i]);
                    level_but.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75);
                    level_but.layer.borderWidth = 1.0;
                    level_but.layer.borderColor = UIColor.whiteColor().CGColor;
                    level_but.clipsToBounds = false;
                    level_but.setTranslatesAutoresizingMaskIntoConstraints(false);
                    level_but.setTitle(String(level_but.level), forState: UIControlState.Normal);
                    level_but.addTarget(self, action: "selected_level:", forControlEvents: UIControlEvents.TouchUpInside);
                    level_but.tag = (i * (dimension * dimension)) + (row * dimension) + col;
                    
                    var baseline = margin + ((margin + mega_height) * CGFloat(i)) + (CGFloat(row) * sub_height);
                    
                    var level_center_x = NSLayoutConstraint(item:level_but, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: scroll_view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: CGFloat(col) * sub_width);
                    
                    var level_center_y = NSLayoutConstraint(item:level_but, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: scroll_view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: baseline);
                    
                    var level_width = NSLayoutConstraint(item:level_but, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scroll_view, attribute: NSLayoutAttribute.Width, multiplier: 1.0 / CGFloat(dimension), constant: 0.0);
                    
                    var level_height = NSLayoutConstraint(item:level_but, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: scroll_view, attribute: NSLayoutAttribute.Width, multiplier: 1.0 / CGFloat(dimension), constant: 0.0);
                    
                    scroll_view.addSubview(level_but);
                    scroll_view.addConstraint(level_center_x);
                    scroll_view.addConstraint(level_center_y);
                    scroll_view.addConstraint(level_width);
                    scroll_view.addConstraint(level_height);
                    level_buttons.append(level_but);
                    
                    for(var j = 0; j < 3; ++j)  // generate status
                    {
                        var level_status = UIView();
                        level_status.setTranslatesAutoresizingMaskIntoConstraints(false);
                        level_status.backgroundColor = UIColor.clearColor();
                        var width:CGFloat = superview.frame.width * scroll_mult / 5.0 / 3.0;
                        
                        var status_height_constr = NSLayoutConstraint(item: level_status, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: level_but, attribute: NSLayoutAttribute.Height, multiplier: 0.15, constant: 0.0);
                        
                        var status_width_constr = NSLayoutConstraint(item: level_status, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: level_but, attribute: NSLayoutAttribute.Width, multiplier: 1.0 / 3.0, constant: 0.0);
                        
                        var status_left = NSLayoutConstraint(item: level_status, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: level_but, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: width * CGFloat(j));
                        
                        var status_bottom = NSLayoutConstraint(item: level_status, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: level_but, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0);
                        
                        level_but.addSubview(level_status);
                        level_but.addConstraint(status_left);
                        level_but.addConstraint(status_bottom);
                        level_but.addConstraint(status_height_constr);
                        level_but.addConstraint(status_width_constr);
                        level_but.level_status_indicator.append(level_status);
                    }
                }
            }
        }
    }
}