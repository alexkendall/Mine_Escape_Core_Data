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
    var label_text = ["VOLUME: 10", "RESTORE PROGRESS"];
    var clearController = ClearDataController();
    var volume:Int = 10;
    var plus_button = UIButton();
    var minus_button = UIButton();
    var volume_indicator = UIButton();
    
    func load_volume()
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext;
        
        var fetch = NSFetchRequest(entityName: "Volume");
        var error:NSError?;
        var results:[NSManagedObject] = managedContext?.executeFetchRequest(fetch, error: &error) as! [NSManagedObject];
        
        if(results.count == 0)
        {
            var descr = NSEntityDescription.entityForName("Volume", inManagedObjectContext: managedContext!);
            var managed_object = NSManagedObject(entity: descr!, insertIntoManagedObjectContext: managedContext);
            managed_object.setValue(10, forKey: "value");
            managedContext?.insertObject(managed_object);
            
            var error:NSError?;
            managedContext?.save(&error);
        }
        else
        {
            self.volume = results[0].valueForKey("value") as! Int;
        }
        volume_indicator.setTitle("VOLUME: " + String(volume), forState: UIControlState.Normal);
        VOLUME_LEVEL = Float(volume) / 10.0;
    }
    
    func GoToMain()
    {
        play_sound(SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }
    
    func set_volume()
    {
        volume_indicator.setTitle("VOLUME: " + String(volume), forState: UIControlState.Normal);
        VOLUME_LEVEL = Float(volume) / 10.0;
        play_sound(SOUND.DEFAULT);
    }
    
    func clicked_reset()
    {
        superview.addSubview(clearController.view);
    }
    
    func change_volume(sender:UIButton!)
    {
        volume += sender.tag;
        if(volume < 0)
        {
            volume = 0;
        }
        if(volume > 10)
        {
            volume = 10;
        }
        set_volume();
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext;
        
        var fetch = NSFetchRequest(entityName: "Volume");
        var error:NSError?;
        var results:[NSManagedObject] = managedContext?.executeFetchRequest(fetch, error: &error) as! [NSManagedObject];
        
        assert(results.count == 1, "INVALID FETCH OF VOLUME ENTITY");
        for(var i = 0; i < results.count; ++i)
        {
            var obj = results[i];
            managedContext?.deleteObject(obj);
        }
        
        var descr = NSEntityDescription.entityForName("Volume", inManagedObjectContext: managedContext!);
        var managed_object = NSManagedObject(entity: descr!, insertIntoManagedObjectContext: managedContext);
        managed_object.setValue(volume, forKey: "value");
        managedContext?.insertObject(managed_object);
        
        managedContext?.save(&error);
        
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
            
            var label = UIButton();
            label.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
            label.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
            label.setTitle(label_text[i], forState: UIControlState.Normal);
            label.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
            label.sizeToFit();
            var label_width:CGFloat = label.frame.width;
            var label_x:CGFloat = (container_view.frame.width - label_width) / 2.0;
            var label_height = container_view.bounds.height / 5.0;
            var label_y = CGFloat(i) * label_height;
            label.frame = CGRect(x: label_x, y: label_y, width: label_width, height: label_height);
            container_view.addSubview(label);
            
            
            if(i == 0)  // VOLUME
            {
                volume_indicator = label;
                // add  - volume buttons
                var space:CGFloat = 10.0
                var minus_dim:CGFloat = label_height;
                var minus_x = label.frame.origin.x - minus_dim;
                var minus_y = label_y;
                minus_button = UIButton(frame: CGRect(x: minus_x, y: minus_y, width: minus_dim, height: minus_dim));
                minus_button.setTitle("-", forState: UIControlState.Normal);
                minus_button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
                minus_button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
                minus_button.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
                minus_button.addTarget(self, action: "change_volume:", forControlEvents: UIControlEvents.TouchDown);
                minus_button.tag = -1;
                container_view.addSubview(minus_button);
                
                // add + button
                var plus_dim:CGFloat = minus_dim;
                var plus_x = label.frame.origin.x + label.frame.width;
                var plus_y = minus_y;
                plus_button = UIButton(frame: CGRect(x: plus_x, y: plus_y, width: plus_dim, height: plus_dim));
                plus_button.setTitle("+", forState: UIControlState.Normal);
                plus_button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
                plus_button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
                plus_button.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
                plus_button.addTarget(self, action: "change_volume:", forControlEvents: UIControlEvents.TouchDown);
                plus_button.tag = 1;
                container_view.addSubview(plus_button);
                
            }
            if(i == 1) // RESTORE PROGRESS
            {
                label.addTarget(self, action: "clicked_reset", forControlEvents: UIControlEvents.TouchUpInside);
            }
            
        }
        volume_indicator.setTitle("VOLUME: " + String(volume), forState: UIControlState.Normal);
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
        var y:CGFloat = (superview.bounds.height - dim) * 0.5;
        container_view.frame = CGRect(x: margin, y: y, width: dim, height: dim);
        container_view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4);
        container_view.layer.borderWidth = 1.0;
        container_view.layer.borderColor = UIColor.whiteColor().CGColor;
        container_view.layoutIfNeeded();
        container_view.setNeedsLayout();
        
        // configure fonts
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
        case .IPHONE_4: font_size = 21.0; text_size = 20.0;
            
        case .IPHONE_5: font_size = 22.0; text_size = 21.0;
            
        case .IPHONE_6: font_size = 24.0; text_size = 23.0;
            
        case .IPHONE_6_PLUS: font_size = 25.0; text_size = 24.0;
            
        case .IPAD: font_size = 32.0; text_size = 45.0;
            
        default: font_size = 30.0;
        }

        
        // add text label
        var t_margin:CGFloat = container_view.bounds.width * 0.1;
        var text_x:CGFloat = margin;
        var text_y:CGFloat = container_view.bounds.height / 8.0;
        var text_height:CGFloat = container_view.bounds.height / 2.0;
        var text_width:CGFloat = container_view.bounds.width - (2.0 * t_margin);
        text_view.frame = CGRect(x: text_x, y: text_y, width: text_width, height: text_height);
        text_view.text = text;
        text_view.textAlignment = NSTextAlignment.Center;
        text_view.textColor = UIColor.blackColor();
        text_view.textColor = UIColor.orangeColor();
        text_view.backgroundColor = UIColor.clearColor();
        text_view.font = UIFont(name: "MicroFLF", size: text_size);
        
        container_view.addSubview(text_view);
        
        // add yes button
        var yes_y:CGFloat = container_view.bounds.height * 2.0 / 3.0;
        var yes_width:CGFloat = text_width / 2.0;
        var yes_height:CGFloat = text_height / 3.0;
        var yes_x:CGFloat = t_margin + yes_width - 1.0;
        var yes_button = UIButton(frame: CGRect(x: yes_x, y: yes_y, width: yes_width, height: yes_height));
        yes_button.layer.borderWidth = 1.0;
        yes_button.layer.borderColor = UIColor.whiteColor().CGColor;
        yes_button.setTitle("Yes", forState: UIControlState.Normal);
        yes_button.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4);
        yes_button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
        yes_button.addTarget(self, action: "delete_data", forControlEvents: UIControlEvents.TouchUpInside);
        yes_button.titleLabel?.font = UIFont(name: "MicroFLF", size: font_size);
        container_view.addSubview(yes_button);
        
        
        // add no button
        var no_x:CGFloat = t_margin; // sift left 1 to account for border
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
        no_button.titleLabel?.font = UIFont(name: "MicroFLF", size: font_size);
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