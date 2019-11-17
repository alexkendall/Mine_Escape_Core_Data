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
        super.init(frame:CGRect.zero);
    }
    required init(coder aDecoder: NSCoder) {
        self.level = 0;
        self.progress = 0;
        self.difficulty = EASY;
        super.init(frame:CGRect.zero);
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
        super.init(frame:CGRect.zero);
        self.level = in_level;
    }
    func update_progress()
    {
        var color = UIColor.clear;
        if(progress == 3)
        {
            color = UIColor.green;
        }
        else if(progress == 2)
        {
            color = UIColor.yellow;
        }
        else if(progress == 1)
        {
            color = UIColor.red;
        }
        for i in 0..<progress
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
        play_sound(sound_effect: SOUND.DEFAULT);
        CURRENT_LEVEL = level_button.tag;
        gameController.reset();
        self.view.addSubview(gameController.view);
    }
    
    func go_to_main()
    {
        play_sound(sound_effect: SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }
    
    func loadData()
    {
        for i in 0..<level_buttons.count
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate;
            let managedContext = appDelegate.managedObjectContext;
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Level");
            let pred = NSPredicate(format: "level_no = %i", i);
            fetch.predicate = pred;
            do {
                let results:[NSManagedObject] = try managedContext?.execute(fetch) as! [NSManagedObject];
                if(results.count == 0)
                {
                    level_buttons[i].progress = 0;
                }
                else if(results.count == 1)
                {
                    let data = results[0];
                    let prev_progress:Int = data.value(forKey: "progress") as! Int;
                    
                    for j in 0..<prev_progress
                    {
                        level_buttons[i].level_data = data;
                        level_buttons[i].level_status_indicator[j].layer.borderWidth = 0.5;
                        var color = UIColor();
                        if(prev_progress == 1)
                        {
                            color = UIColor.red;
                        }
                        if(prev_progress == 2)
                        {
                            color = UIColor.yellow;
                        }
                        if(prev_progress == 3)
                        {
                            color = UIColor.green;
                        }
                        level_buttons[i].level_status_indicator[j].backgroundColor = color;
                    }
                }
                else
                {
                    NSLog("Error: %i Managed Objects Stored for Single Level No. %i", results.count, i);
                }
            } catch (let error) {
                // handle this
                print(error)
            }
         
        }
    }
    
    func see_times()
    {
        self.view.addSubview(time_controller.view);
        time_controller.load_data();
        time_controller.scroll_view.contentOffset = scroll_view.contentOffset;
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated);
        UIView.animate(withDuration: 0.5, animations: {self.scroll_view.frame = self.scroll_frame});
    }

    override func viewDidLoad()
    {
        superview = self.view;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        superview.bounds = superview.frame;
        
        addGradient(view: superview, colors: [UIColor.black.cgColor, LIGHT_BLUE.cgColor]);
        addChildViewController(gameController);
        
        // configure title
        // generate title subview
        let margin:CGFloat = superview.bounds.height / 20.0;
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
        case .IPHONE_4: font_size = 23.0; text_size = 15.0;
            
        case .IPHONE_5: font_size = 25.0; text_size = 15.0;
            
        case .IPHONE_6: font_size = 28.0; text_size = 17.0;
            
        case .IPHONE_6_PLUS: font_size = 29.0; text_size = 18.0;
            
        case .IPAD: font_size = 50.0; text_size = 24.0;
            
        default: font_size = 30.0;
        }
        
        add_title_button(title_label: title_label, superview: superview, text: "LEVELS", margin: margin, size: font_size);
        
        title_label.layoutIfNeeded();
        title_label.setNeedsLayout();
        let scroll_width = superview.bounds.width - (2.0 * margin);
        let scroll_height = superview.bounds.height - title_label.bounds.height - (margin * 2.0) - back_button_size;
        
        self.scroll_frame = CGRect(x: margin, y: (margin * 2.5), width: scroll_width, height: scroll_height);
        scroll_view.frame = CGRect(x: margin, y: (margin * 2.5), width: scroll_width, height: 0.0);
        superview.addSubview(scroll_view);
        
        // add back button to bottom left corner
        add_back_button(back_button: &back_button, superview: &superview);
        back_button.addTarget(self, action: Selector(("go_to_main")), for: UIControlEvents.touchUpInside);
        
        // add time information button to right corner
        back_button.layoutIfNeeded();
        back_button.setNeedsLayout();
        let x = superview.bounds.width - global_but_margin - global_but_dim;
        let y = back_button.frame.origin.y;
        let width = back_button.bounds.width;
        let height = back_button.bounds.height;
        let time_button:UIButton = UIButton(frame: CGRect(x: x, y: y, width: width, height: height));
        time_button.layer.borderWidth = 1.0;
        time_button.layer.borderColor = UIColor.white.cgColor;
        time_button.setBackgroundImage(UIImage(named: "clock"), for: UIControlState.normal);
        superview.addSubview(time_button);
        time_button.addTarget(self, action: Selector(("see_times")), for: UIControlEvents.touchUpInside);
        
        scroll_view.backgroundColor = UIColor.clear;
        scroll_view.layer.borderColor = UIColor.white.cgColor;
        scroll_view.layer.borderWidth = 1.0;
        scroll_view.layoutIfNeeded();
        scroll_view.setNeedsLayout();
        
        let tab_height:CGFloat = self.scroll_frame.height / 15.0;
        let tab_width:CGFloat = self.scroll_frame.width;
        let dimension:Int = Int(sqrt(Float(NUM_SUB_LEVELS)));
        let subview_width:CGFloat = scroll_view.bounds.width / CGFloat(dimension);
        let subview_height:CGFloat = subview_width;
        
        for i in 0..<NUM_MEGA_LEVELS
        {
            let tab_view = UILabel();
            scroll_view.addSubview(tab_view);
            tab_view.backgroundColor = UIColor.white;
            let top_margin:CGFloat = CGFloat(i) * (tab_height + (CGFloat(dimension) * subview_height));
            tab_view.frame = CGRect(x: 0.0, y: top_margin, width: tab_width, height: tab_height);
            tab_view.bounds = CGRect(x: 0.0, y: 0.0, width: tab_width, height: tab_height);
            tab_view.text = DIFFICULTY[i]; //+ String(format: " - %i X %i ", current_dim, current_dim);
            tab_view.textAlignment = NSTextAlignment.center;
            tab_view.textColor = UIColor.black;
            tab_view.layer.borderWidth = 1.0;
            tab_view.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
            tab_view.layer.borderColor = UIColor.white.cgColor;
            for row in 0..<dimension
            {
                let dist_from_top:CGFloat = top_margin + (CGFloat(row) * subview_height) + tab_height;
                for col in 0..<dimension
                {
                    // configure level button
                    let dist_from_left:CGFloat = CGFloat(col) * subview_width;
                    let level_ = level_view(in_level: (row * dimension) + col + 1, in_progress: 0, in_difficulty:DIFFICULTY[i]);
                    scroll_view.addSubview(level_);
                    level_.frame = CGRect(x: dist_from_left, y: dist_from_top, width: subview_width, height: subview_height);
                    level_.bounds = CGRect(x: 0.0, y: 0.0, width: subview_width, height: subview_height);
                    level_.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75);
                    level_.layer.borderWidth = 1.0;
                    level_.layer.borderColor = UIColor.white.cgColor;
                    level_.setTitle(String(level_.level), for: UIControlState.normal);
                    level_.addTarget(self, action: Selector(("selected_level:")), for: UIControlEvents.touchUpInside);
                    level_.tag = (i * (dimension * dimension)) + (row * dimension) + col;
                    level_.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
                    level_buttons.append(level_);
                    for ind in 0..<3
                    {
                        level_.layoutIfNeeded();
                        level_.setNeedsLayout();
                        let indicator = UIView();
                        let ind_height = level_.bounds.height / 6.0;
                        let ind_width = level_.bounds.width / 3.0;
                        let x = ind_width * CGFloat(ind);
                        let y = level_.bounds.height - ind_height;
                        indicator.frame = CGRect(x: x, y: y, width: ind_width, height: ind_height);
                        indicator.layer.borderWidth = 0.5;
                        indicator.backgroundColor = UIColor.clear;
                        level_.addSubview(indicator);
                        level_.level_status_indicator.append(indicator);
                    }
                }
            }
        }
        let mega_height:CGFloat = subview_height * CGFloat(dimension);
        let content_height:CGFloat = (mega_height * CGFloat(NUM_MEGA_LEVELS)) + (CGFloat(NUM_MEGA_LEVELS) * tab_height);
        scroll_view.contentSize = CGSize(width: tab_width, height: content_height);
        scroll_view.clipsToBounds = true;
        scroll_view.isScrollEnabled = true;
        loadData();
    }
}


class TimeController:UIViewController
{
    var superview:UIView = UIView();
    var title_label = UILabel();
    var scroll_view = UIScrollView();
    var scroll_frame = CGRect();
    var time_label = UILabel();
    var level_color = UIColor();
    var level_buttons = [UIButton]();
    override func viewDidLoad()
    {
        superview = self.view as UIView;
        superview.frame = CGRect(x: 0, y: 0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        addGradient(view: superview, colors: [UIColor.black.cgColor, LIGHT_BLUE.cgColor]);
        var back_button = UIButton();
        add_back_button(back_button: &back_button, superview: &superview);
        back_button.addTarget(self, action: "enter_levels", Selector("enter_levels"), UIControlEvents.TouchUpInside);
        
        // configure title
        // generate title subview
        var title = UILabel();
        var margin:CGFloat = superview.bounds.height / 20.0;
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
        case .IPHONE_4: font_size = 23.0; text_size = 15.0;
            
        case .IPHONE_5: font_size = 25.0; text_size = 15.0;
            
        case .IPHONE_6: font_size = 28.0; text_size = 17.0;
            
        case .IPHONE_6_PLUS: font_size = 29.0; text_size = 18.0;
            
        case .IPAD: font_size = 50.0; text_size = 24.0;
            
        default: font_size = 30.0;
        }
        
        add_title_button(title_label: title_label, superview: superview, text: "BEST TIMES", margin: margin, size: font_size);
        // add time information button to right corner
        back_button.layoutIfNeeded();
        back_button.setNeedsLayout();
        
        // configure time label at bottom
        var x = back_button.frame.origin.x + global_but_dim + global_but_margin;
        var y = back_button.frame.origin.y;
        var height = back_button.bounds.height;
        var width = superview.bounds.width - x - global_but_margin;
        time_label.layer.borderColor = UIColor.white.cgColor;
        time_label.layer.borderWidth = 1.0;
        time_label.frame = CGRect(x: x, y: y, width: width, height: height);
        time_label.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75);
        
        superview.addSubview(time_label);
        
        title_label.layoutIfNeeded();
        title_label.setNeedsLayout();
        var scroll_width = superview.bounds.width - (2.0 * margin);
        var scroll_height = superview.bounds.height - title_label.bounds.height - (margin * 2.0) - back_button_size;
        
        self.scroll_frame = CGRect(x: margin, y: (margin * 2.5), width: scroll_width, height: scroll_height);
        scroll_view.frame = scroll_frame
        superview.addSubview(scroll_view);
        
        scroll_view.backgroundColor = UIColor.clear;
        scroll_view.layer.borderColor = UIColor.white.cgColor;
        scroll_view.layer.borderWidth = 1.0;
        scroll_view.layoutIfNeeded();
        scroll_view.setNeedsLayout();
        
        var tab_height:CGFloat = self.scroll_frame.height / 15.0;
        var tab_width:CGFloat = self.scroll_frame.width;
        var dimension:Int = Int(sqrt(Float(NUM_SUB_LEVELS)));
        var subview_width:CGFloat = scroll_view.bounds.width / CGFloat(dimension);
        var subview_height:CGFloat = subview_width;
        
        for i in 0..<NUM_MEGA_LEVELS
        {
            var tab_view = UILabel();
            scroll_view.addSubview(tab_view);
            tab_view.backgroundColor = UIColor.white;
            var top_margin:CGFloat = CGFloat(i) * (tab_height + (CGFloat(dimension) * subview_height));
            tab_view.frame = CGRect(x: 0.0, y: top_margin, width: tab_width, height: tab_height);
            tab_view.bounds = CGRect(x: 0.0, y: 0.0, width: tab_width, height: tab_height);
            tab_view.text = DIFFICULTY[i]; //+ String(format: " - %i X %i ", current_dim, current_dim);
            tab_view.textAlignment = NSTextAlignment.center;
            tab_view.textColor = UIColor.black;
            tab_view.layer.borderWidth = 1.0;
            tab_view.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
            tab_view.layer.borderColor = UIColor.white.cgColor;
            for row in 0..<dimension
            {
                var dist_from_top:CGFloat = top_margin + (CGFloat(row) * subview_height) + tab_height;
                for col in 0..<dimension
                {
                    // configure level button
                    level_color = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.75);
                    var dist_from_left:CGFloat = CGFloat(col) * subview_width;
                    var level_ = level_view(in_level: (row * dimension) + col + 1, in_progress: 0, in_difficulty:DIFFICULTY[i]);
                    scroll_view.addSubview(level_);
                    level_.frame = CGRect(x: dist_from_left, y: dist_from_top, width: subview_width, height: subview_height);
                    level_.bounds = CGRect(x: 0.0, y: 0.0, width: subview_width, height: subview_height);
                    level_.backgroundColor = level_color;
                    level_.layer.borderWidth = 1.0;
                    level_.layer.borderColor = UIColor.white.cgColor;
                    level_.setTitle(String(level_.level), for: UIControlState.normal);
                    level_.addTarget(self, action: Selector("get_time:"), for: UIControlEvents.touchUpInside);
                    level_.tag = (i * NUM_SUB_LEVELS) + (row * Int(sqrt(Double(NUM_SUB_LEVELS)))) + col;
                    level_.tag = (i * (dimension * dimension)) + (row * dimension) + col;
                    level_.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
                    level_buttons.append(level_);
                }
            }
        }
        var mega_height:CGFloat = subview_height * CGFloat(dimension);
        var content_height:CGFloat = (mega_height * CGFloat(NUM_MEGA_LEVELS)) + (CGFloat(NUM_MEGA_LEVELS) * tab_height);
        scroll_view.contentSize = CGSize(width: tab_width, height: content_height);
        scroll_view.clipsToBounds = true;
        scroll_view.isScrollEnabled = true;
        self.load_data();
    }
    
    // adds a clock to whatever level button has a time and has been completed
    func load_data()
    {
        for i in 0..<LevelsController.level_buttons.count
        {
            let data = LevelsController.level_buttons[i].level_data;
            if(data != nil)
            {
                let progress = data?.value(forKey: "progress") as! Int;
                if(progress == 3)
                {
                    level_buttons[i].setTitleColor(LIGHT_BLUE, for: UIControlState.normal);
                }
                else
                {
                    level_buttons[i].setTitleColor(UIColor.white, for: UIControlState.normal);
                }
            }
            else
            {
                level_buttons[i].setTitleColor(UIColor.white, for: UIControlState.normal);
            }
        }
    }
    
    func enter_levels()
    {
        self.view.removeFromSuperview();
        self.time_label.text = "";
        for i in 0..<level_buttons.count
        {
            level_buttons[i].backgroundColor = self.level_color;
        }
        LevelsController.scroll_view.contentOffset = scroll_view.contentOffset;
    }
    
    @objc func get_time(level:UIButton)
    {
        
        for i in 0..<level_buttons.count
        {
            level_buttons[i].backgroundColor = self.level_color;
        }
        level_buttons[level.tag].backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75);
        // fetch time for level
        let data:NSManagedObject? = LevelsController.level_buttons[level.tag].level_data;
        var time:String = "";
        var text = "Best Time: Incomplete";
        // only time will be available if level has been completed (progress == 3)
        if(data != nil)
        {
            let time_float = data?.value(forKey: "time") as! Float;
            let progress:Int = data?.value(forKey: "progress") as! Int;
            if(progress == 3)
            {
                time = String(format: "%.2f", time_float);
                text = "Best Time: " + time + " Seconds";
            }
        }
        time_label.text = text;
        time_label.textAlignment = NSTextAlignment.center;
        time_label.textColor = UIColor.white;
    }
}
