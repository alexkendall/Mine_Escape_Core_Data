//
//  SettingsController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingsController : ViewController
{
    var superview = UIView();
    var back_button = UIButton();
    var volume_slider = UISlider();
    var volume_label = UILabel();
    var restore_button = UIButton();
    var label_text = ["VOLUME", "RESTORE PROGRESS"];
    var clearController = ClearDataController();
    
    func GoToMain()
    {
        play_sound(SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }
    
    func clicked_reset()
    {
        superview.addSubview(clearController.view);
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        superview.bounds = superview.frame;
        
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        
        // generate title subview
        var title = UILabel();
        var margin:CGFloat = superview.bounds.height / 15.0;
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
        case .IPHONE_4: font_size = 25.0; text_size = 16.0;
            
        case .IPHONE_5: font_size = 27.0; text_size = 16.0;
            
        case .IPHONE_6: font_size = 30.0; text_size = 18.0;
            
        case .IPHONE_6_PLUS: font_size = 33.0; text_size = 19.0;
            
        case .IPAD: font_size = 50.0; text_size = 26.0;
            
        default: font_size = 30.0;
        }
        
        add_title_button(&title, &superview, "SETTINGS", margin, font_size);
        add_back_button(&back_button, &superview);
        back_button.addTarget(self, action: "GoToMain", forControlEvents: UIControlEvents.TouchUpInside);
        
        var container_view = UIView();
        var top = margin * 2.5;
        var left_margin = margin;
        var right_margin = margin;
        var bottom_margin = back_button_size + banner_view.bounds.height;
        
        add_subview(container_view, superview, top, bottom_margin, left_margin, right_margin);
        //container_view.backgroundColor = UIColor.whiteColor();
        
        
        for(var i = 0; i < label_text.count; ++i)
        {
            container_view.layoutIfNeeded();
            container_view.setNeedsLayout();
            var label_height = container_view.bounds.height / 5.0;
            var label_width = container_view.bounds.width;
            var label_x:CGFloat = 0.0;
            var label_y = CGFloat(i) * label_height;
            
            var label = UIButton(frame: CGRect(x: label_x, y: label_y, width: label_width, height: label_height));
            label.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
            label.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
            label.setTitle(label_text[i], forState: UIControlState.Normal);
            label.titleLabel?.font = UIFont.systemFontOfSize(text_size);
            container_view.addSubview(label);
            
            if(i == 1)  // add buttons to adjust volume
            {
                label.addTarget(self, action: "clicked_reset", forControlEvents: UIControlEvents.TouchUpInside);
            }
        }
    }
}

class ClearDataController : ViewController
{
    var superview = UIView()
    var container_view = UIView();
    var text:String = "Are you sure you would like to permanently reset all level progress?"
    var text_view = UITextView();
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        
        // shouldn't be able to click add
        var margin:CGFloat = superview.bounds.height / 20.0;
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        
        
        // configure container
        superview.addSubview(container_view);
        var dim:CGFloat = superview.bounds.width - (2.0 * margin);
        var y:CGFloat = (superview.bounds.height - dim - banner_view.bounds.height) / 2.0;
        container_view.frame = CGRect(x: margin, y: y, width: dim, height: dim);
        container_view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4);
        container_view.layer.borderWidth = 1.0;
        container_view.layoutIfNeeded();
        container_view.setNeedsLayout();
        
        // add text label
        var t_margin:CGFloat = container_view.bounds.width * 0.1;
        var text_x:CGFloat = margin;
        var text_y:CGFloat = container_view.bounds.height / 8.0;
        var text_height:CGFloat = container_view.bounds.height / 3.0;
        var text_width:CGFloat = container_view.bounds.width - (2.0 * t_margin);
        text_view.frame = CGRect(x: text_x, y: text_y, width: text_width, height: text_height);
        text_view.text = text;
        text_view.textAlignment = NSTextAlignment.Center;
        text_view.textColor = UIColor.blackColor();
        text_view.font = UIFont.systemFontOfSize(23.0);
        text_view.textColor = UIColor.orangeColor();
        text_view.backgroundColor = UIColor.clearColor();
        container_view.addSubview(text_view);
        
        // add yes button
        var yes_x:CGFloat = t_margin;
        var yes_y:CGFloat = container_view.bounds.height * 2.0 / 3.0;
        var yes_width:CGFloat = text_width / 2.0;
        var yes_height:CGFloat = text_height / 2.0;
        var yes_button = UIButton(frame: CGRect(x: yes_x, y: yes_y, width: yes_width, height: yes_height));
        yes_button.layer.borderWidth = 1.0;
        yes_button.layer.borderColor = UIColor.whiteColor().CGColor;
        yes_button.setTitle("Yes", forState: UIControlState.Normal);
        yes_button.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4);
        yes_button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
        yes_button.addTarget(self, action: "delete_data", forControlEvents: UIControlEvents.TouchUpInside);
        container_view.addSubview(yes_button);
        
        // add no button
        var no_x:CGFloat = yes_x + yes_width - 1.0; // sift left 1 to account for border
        var no_y:CGFloat = yes_y;
        var no_height:CGFloat = yes_height;
        var no_width:CGFloat = yes_width + 1.0; // to account for border
        var no_button = UIButton(frame: CGRect(x: no_x, y: no_y, width: no_width, height: no_height));
        no_button.layer.borderWidth = 1.0;
        no_button.layer.borderColor = UIColor.whiteColor().CGColor;
        no_button.setTitle("No", forState: UIControlState.Normal);
        no_button.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4);
        no_button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
        no_button.addTarget(self, action: "exit", forControlEvents: UIControlEvents.TouchUpInside);
        container_view.addSubview(no_button);
    }
    
    func delete_data()
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext;
        
        var fetch = NSFetchRequest(entityName: "Level");
        
        var error:NSError?;
        var results:[NSManagedObject] = managedContext?.executeFetchRequest(fetch, error: &error) as! [NSManagedObject];
        
        for(var i = 0; i < results.count; ++i)
        {
            managedContext?.deleteObject(results[i]);
        }
        managedContext?.save(&error);
        
        for(var i = 0; i < LevelsController.level_buttons.count; ++i)
        {
            LevelsController.level_buttons[i].progress = 0;
            
            for(var j = 0; j < 3; ++j)
            {
                LevelsController.level_buttons[i].level_status_indicator[j].backgroundColor = UIColor.clearColor();
                LevelsController.level_buttons[i].level_data = nil;
            }
        }
        LevelsController.loadData();
        exit();
    }
    
    func exit()
    {
        self.superview.removeFromSuperview();
    }
}