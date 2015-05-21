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
    
    func GoToMain()
    {
        play_sound(SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }
    
    func resetProgress()
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
        LevelsController.loadData();
        for(var i = 0; i < LevelsController.level_buttons.count; ++i)
        {
            LevelsController.level_buttons[i].progress = 0;
            
            for(var j = 0; j < 3; ++j)
            {
                LevelsController.level_buttons[i].level_status_indicator[j].backgroundColor = UIColor.clearColor();
            }
        }
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
        var margin:CGFloat = superview.bounds.height / 20.0;
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
        case .IPHONE_4: font_size = 25.0; text_size = 14.0;
            
        case .IPHONE_5: font_size = 27.0; text_size = 14.0;
            
        case .IPHONE_6: font_size = 30.0; text_size = 16.0;
            
        case .IPHONE_6_PLUS: font_size = 33.0; text_size = 16.0;
            
        case .IPAD: font_size = 50.0; text_size = 24.0;
            
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
            var label_height = container_view.bounds.height / 10.0;
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
                label.addTarget(self, action: "resetProgress", forControlEvents: UIControlEvents.TouchUpInside);
            }
        }
    }
}

class ClearDataController : ViewController
{
    var superview = UIView()
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // configure superview
        superview = self.view;
        superview.backgroundColor = UIColor.whiteColor();
        
    }
}