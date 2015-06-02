//
//  LevelsController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var EASY = "EASY", MEDIUM = "MEDIUM", HARD = "HARD", INSANE = "INSANE", IMPOSSIBLE = "IMPOSSIBLE";
var DIFFICULTY:[String] = [EASY, MEDIUM, HARD, INSANE, IMPOSSIBLE];


class level_view:UIButton
{
    var level_data:NSManagedObject?;
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
    var level_buttons = Array<level_view>();
    var back_button = UIButton();
    var title_label = UILabel();
    var scroll_frame = CGRect();
    var time_controller = TimeController();
    
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
    
    func loadData()
    {
        for(var i = 0; i < level_buttons.count; ++i)
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            let managedContext = appDelegate.managedObjectContext;
            
            var fetch = NSFetchRequest(entityName: "Level");
            var pred = NSPredicate(format: "level_no = %i", i);
            fetch.predicate = pred;
            
            var error:NSError?;
            var results:[NSManagedObject] = managedContext?.executeFetchRequest(fetch, error: &error) as! [NSManagedObject];
            
            if(results.count == 0)
            {
                level_buttons[i].progress = 0;
            }
            if(results.count == 1)
            {
                var data = results[0];
                var prev_progress:Int = data.valueForKey("progress") as! Int;
                
                for(var j = 0; j < prev_progress; ++j)
                {
                    level_buttons[i].level_data = data;
                    level_buttons[i].level_status_indicator[j].layer.borderWidth = 0.5;
                    var color = UIColor();
                    if(prev_progress == 1)
                    {
                        color = UIColor.redColor();
                    }
                    if(prev_progress == 2)
                    {
                        color = UIColor.yellowColor();
                    }
                    if(prev_progress == 3)
                    {
                        color = UIColor.greenColor();
                    }
                    level_buttons[i].level_status_indicator[j].backgroundColor = color;
                }
            }
        }
    }
    
    func see_times()
    {
        self.view.addSubview(time_controller.view);
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        UIView.animateWithDuration(0.5, animations: {self.scroll_view.frame = self.scroll_frame});
    }

    override func viewDidLoad()
    {
        superview = self.view;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        superview.bounds = superview.frame;
        
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        addChildViewController(gameController);
        
        // configure title
        // generate title subview
        var title = UILabel();
        var margin:CGFloat = superview.bounds.height / 20.0;
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
            case .IPHONE_4: font_size = 23.0; text_size = 14.0;
            
            case .IPHONE_5: font_size = 25.0; text_size = 14.0;
            
            case .IPHONE_6: font_size = 28.0; text_size = 16.0;
            
            case .IPHONE_6_PLUS: font_size = 29.0; text_size = 16.0;
            
            case .IPAD: font_size = 50.0; text_size = 24.0;
            
            default: font_size = 30.0;
        }
        
        add_title_button(&title_label, &superview, "LEVELS", margin, font_size);
        
        title_label.layoutIfNeeded();
        title_label.setNeedsLayout();
        var scroll_width = superview.bounds.width - (2.0 * margin);
        var scroll_height = superview.bounds.height - title_label.bounds.height - (margin * 2.0) - back_button_size;
        
        self.scroll_frame = CGRect(x: margin, y: (margin * 2.5), width: scroll_width, height: scroll_height);
        scroll_view.frame = CGRect(x: margin, y: (margin * 2.5), width: scroll_width, height: 0.0);
        superview.addSubview(scroll_view);
        
        // add back button to bottom left corner
        add_back_button(&back_button, &superview);
        back_button.addTarget(self, action: "go_to_main", forControlEvents: UIControlEvents.TouchUpInside);
        
        // add time information button to right corner
        back_button.layoutIfNeeded();
        back_button.setNeedsLayout();
        var x = superview.bounds.width - global_but_margin - global_but_dim;
        var y = back_button.frame.origin.y;
        var width = back_button.bounds.width;
        var height = back_button.bounds.height;
        var time_button:UIButton = UIButton(frame: CGRect(x: x, y: y, width: width, height: height));
        time_button.layer.borderWidth = 1.0;
        time_button.layer.borderColor = UIColor.whiteColor().CGColor;
        time_button.setBackgroundImage(UIImage(named: "clock"), forState: UIControlState.Normal);
        superview.addSubview(time_button);
        time_button.addTarget(self, action: "see_times", forControlEvents: UIControlEvents.TouchUpInside);
        
        scroll_view.backgroundColor = UIColor.clearColor();
        scroll_view.layer.borderColor = UIColor.whiteColor().CGColor;
        scroll_view.layer.borderWidth = 1.0;
        scroll_view.layoutIfNeeded();
        scroll_view.setNeedsLayout();
        
        var tab_height:CGFloat = self.scroll_frame.height / 15.0;
        var tab_width:CGFloat = self.scroll_frame.width;
        var dimension:Int = Int(sqrt(Float(NUM_SUB_LEVELS)));
        var subview_width:CGFloat = scroll_view.bounds.width / CGFloat(dimension);
        var subview_height:CGFloat = subview_width;
        
        for(var i = 0; i < NUM_MEGA_LEVELS; ++i)
        {
            var tab_view = UILabel();
            scroll_view.addSubview(tab_view);
            tab_view.backgroundColor = UIColor.whiteColor();
            var top_margin:CGFloat = CGFloat(i) * (tab_height + (CGFloat(dimension) * subview_height));
            tab_view.frame = CGRect(x: 0.0, y: top_margin, width: tab_width, height: tab_height);
            tab_view.bounds = CGRect(x: 0.0, y: 0.0, width: tab_width, height: tab_height);
            tab_view.text = DIFFICULTY[i]; //+ String(format: " - %i X %i ", current_dim, current_dim);
            tab_view.textAlignment = NSTextAlignment.Center;
            tab_view.textColor = UIColor.blackColor();
            tab_view.layer.borderWidth = 1.0;
            tab_view.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 17.0);
            tab_view.layer.borderColor = UIColor.whiteColor().CGColor;
            for(var row = 0; row < dimension; ++row)
            {
                var dist_from_top:CGFloat = top_margin + (CGFloat(row) * subview_height) + tab_height;
                for(var col = 0; col < dimension; ++col)
                {
                    // configure level button
                    var dist_from_left:CGFloat = CGFloat(col) * subview_width;
                    var level_ = level_view(in_level: (row * dimension) + col + 1, in_progress: 0, in_difficulty:DIFFICULTY[i]);
                    scroll_view.addSubview(level_);
                    level_.frame = CGRect(x: dist_from_left, y: dist_from_top, width: subview_width, height: subview_height);
                    level_.bounds = CGRect(x: 0.0, y: 0.0, width: subview_width, height: subview_height);
                    level_.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75);
                    level_.layer.borderWidth = 1.0;
                    level_.layer.borderColor = UIColor.whiteColor().CGColor;
                    level_.setTitle(String(level_.level), forState: UIControlState.Normal);
                    level_.addTarget(self, action: "selected_level:", forControlEvents: UIControlEvents.TouchUpInside);
                    level_.tag = (i * (dimension * dimension)) + (row * dimension) + col;
                    level_.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 17.0);
                    level_buttons.append(level_);
                    for(var ind = 0; ind < 3; ++ind)
                    {
                        level_.layoutIfNeeded();
                        level_.setNeedsLayout();
                        var indicator = UIView();
                        var ind_height = level_.bounds.height / 6.0;
                        var ind_width = level_.bounds.width / 3.0;
                        var x = ind_width * CGFloat(ind);
                        var y = level_.bounds.height - ind_height;
                        indicator.frame = CGRect(x: x, y: y, width: ind_width, height: ind_height);
                        indicator.layer.borderWidth = 0.5;
                        indicator.backgroundColor = UIColor.clearColor();
                        level_.addSubview(indicator);
                        level_.level_status_indicator.append(indicator);
                    }
                }
            }
        }
        var mega_height:CGFloat = subview_height * CGFloat(dimension);
        var content_height:CGFloat = (mega_height * CGFloat(NUM_MEGA_LEVELS)) + (CGFloat(NUM_MEGA_LEVELS) * tab_height);
        scroll_view.contentSize = CGSize(width: tab_width, height: content_height);
        scroll_view.clipsToBounds = true;
        scroll_view.scrollEnabled = true;
        loadData();
    }
}


class TimeController:UIViewController
{
    var superview:UIView = UIView();
    var title_label = UILabel();
    var scroll_view = UIScrollView();
    var scroll_frame = CGRect();
    
    override func viewDidLoad()
    {
        superview = self.view as UIView;
        superview.frame = CGRect(x: 0, y: 0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        var back_button = UIButton();
        add_back_button(&back_button, &superview);
        back_button.addTarget(self, action: "enter_levels", forControlEvents: UIControlEvents.TouchUpInside);
        
        // configure title
        // generate title subview
        var title = UILabel();
        var margin:CGFloat = superview.bounds.height / 20.0;
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
        case .IPHONE_4: font_size = 23.0; text_size = 14.0;
            
        case .IPHONE_5: font_size = 25.0; text_size = 14.0;
            
        case .IPHONE_6: font_size = 28.0; text_size = 16.0;
            
        case .IPHONE_6_PLUS: font_size = 29.0; text_size = 16.0;
            
        case .IPAD: font_size = 50.0; text_size = 24.0;
            
        default: font_size = 30.0;
        }
        
        add_title_button(&title_label, &superview, "BEST TIMES", margin, font_size);
        // add time information button to right corner
        back_button.layoutIfNeeded();
        back_button.setNeedsLayout();
        
        title_label.layoutIfNeeded();
        title_label.setNeedsLayout();
        var scroll_width = superview.bounds.width - (2.0 * margin);
        var scroll_height = superview.bounds.height - title_label.bounds.height - (margin * 2.0) - back_button_size;
        
        self.scroll_frame = CGRect(x: margin, y: (margin * 2.5), width: scroll_width, height: scroll_height);
        scroll_view.frame = scroll_frame
        superview.addSubview(scroll_view);
        
        scroll_view.backgroundColor = UIColor.clearColor();
        scroll_view.layer.borderColor = UIColor.whiteColor().CGColor;
        scroll_view.layer.borderWidth = 1.0;
        scroll_view.layoutIfNeeded();
        scroll_view.setNeedsLayout();
        
        var tab_height:CGFloat = self.scroll_frame.height / 15.0;
        var tab_width:CGFloat = self.scroll_frame.width;
        var dimension:Int = Int(sqrt(Float(NUM_SUB_LEVELS)));
        var subview_width:CGFloat = scroll_view.bounds.width / CGFloat(dimension);
        var subview_height:CGFloat = subview_width;
        
        for(var i = 0; i < NUM_MEGA_LEVELS; ++i)
        {
            var tab_view = UILabel();
            scroll_view.addSubview(tab_view);
            tab_view.backgroundColor = UIColor.whiteColor();
            var top_margin:CGFloat = CGFloat(i) * (tab_height + (CGFloat(dimension) * subview_height));
            tab_view.frame = CGRect(x: 0.0, y: top_margin, width: tab_width, height: tab_height);
            tab_view.bounds = CGRect(x: 0.0, y: 0.0, width: tab_width, height: tab_height);
            tab_view.text = DIFFICULTY[i]; //+ String(format: " - %i X %i ", current_dim, current_dim);
            tab_view.textAlignment = NSTextAlignment.Center;
            tab_view.textColor = UIColor.blackColor();
            tab_view.layer.borderWidth = 1.0;
            tab_view.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 17.0);
            tab_view.layer.borderColor = UIColor.whiteColor().CGColor;
            for(var row = 0; row < dimension; ++row)
            {
                var dist_from_top:CGFloat = top_margin + (CGFloat(row) * subview_height) + tab_height;
                for(var col = 0; col < dimension; ++col)
                {
                    // configure level button
                    var dist_from_left:CGFloat = CGFloat(col) * subview_width;
                    var level_ = level_view(in_level: (row * dimension) + col + 1, in_progress: 0, in_difficulty:DIFFICULTY[i]);
                    scroll_view.addSubview(level_);
                    level_.frame = CGRect(x: dist_from_left, y: dist_from_top, width: subview_width, height: subview_height);
                    level_.bounds = CGRect(x: 0.0, y: 0.0, width: subview_width, height: subview_height);
                    level_.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.75);
                    level_.layer.borderWidth = 1.0;
                    level_.layer.borderColor = UIColor.whiteColor().CGColor;
                    level_.setTitle(String(level_.level), forState: UIControlState.Normal);
                    level_.addTarget(self, action: "get_time:", forControlEvents: UIControlEvents.TouchUpInside);
                    level_.tag = (i * NUM_SUB_LEVELS) + (row * Int(sqrt(Double(NUM_SUB_LEVELS)))) + col;
                    level_.tag = (i * (dimension * dimension)) + (row * dimension) + col;
                    level_.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: 17.0);
                }
            }
        }
        var mega_height:CGFloat = subview_height * CGFloat(dimension);
        var content_height:CGFloat = (mega_height * CGFloat(NUM_MEGA_LEVELS)) + (CGFloat(NUM_MEGA_LEVELS) * tab_height);
        scroll_view.contentSize = CGSize(width: tab_width, height: content_height);
        scroll_view.clipsToBounds = true;
        scroll_view.scrollEnabled = true;
    }
    
    func enter_levels()
    {
        self.view.removeFromSuperview();
    }
    
    func get_time(level:UIButton)
    {
        println("Level time for level: " + String(level.tag));
        // fetch time for level
        
    }
}





