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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext;
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Volume");
        do {
            let results = try managedContext?.execute(request) as? [AnyObject]
            if let managedResults = results as [AnyObject]? {
                if managedResults.count == 0 {
                    let descr = NSEntityDescription.entity(forEntityName: "Volume", in: managedContext!);
                    let managed_object = NSManagedObject(entity: descr!, insertInto: managedContext);
                    managed_object.setValue(10, forKey: "value");
                    managedContext?.insert(managed_object);
                    try managedContext?.save();
                } else {
                    self.volume = managedResults[0].value(forKey: "value") as! Int;
                }
            }
        } catch (let error) {
            print("error \(error)")
        }
        volume_indicator.setTitle("VOLUME: " + String(volume), for: UIControlState.normal);
        VOLUME_LEVEL = Float(volume) / 10.0;
    }
    
    @objc func GoToMain()
    {
        play_sound(sound_effect: SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }
    
    @objc func set_volume()
    {
        volume_indicator.setTitle("VOLUME: " + String(volume), for: UIControlState.normal);
        VOLUME_LEVEL = Float(volume) / 10.0;
        play_sound(sound_effect: SOUND.DEFAULT);
    }
    
    @objc func clicked_reset()
    {
        superview.addSubview(clearController.view);
    }
    
    @objc func change_volume(sender:UIButton!)
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext;
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Volume");
        do {
            let results = try managedContext?.fetch(request)
            if let resultObjs = results {
                for obj in resultObjs
                {
                    if let managedObject = obj as? NSManagedObject {
                        managedContext?.delete(managedObject)
                    }
                }
            }
        } catch (let error) {
            print("error \(error)")
        }
        let descr = NSEntityDescription.entity(forEntityName: "Volume", in: managedContext!);
        let managed_object = NSManagedObject(entity: descr!, insertInto: managedContext);
        managed_object.setValue(volume, forKey: "value");
        managedContext?.insert(managed_object);
        do {
            try managedContext?.save()
        } catch(let error) {
            print("error \(error)")
        }
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        superview.bounds = superview.frame;
        
        addGradient(view: superview, colors: [UIColor.black.cgColor, LIGHT_BLUE.cgColor]);
        
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
        
        add_title_button(title_label: title, superview: superview, text: "SETTINGS", margin: margin, size: font_size);
        add_back_button(back_button: &back_button, superview: &superview);
        back_button.addTarget(self, action: Selector("GoToMain"), for: UIControlEvents.touchUpInside);
        
        var container_view = UIView();
        var top = margin * 2.5;
        var left_margin = margin;
        var right_margin = margin;
        var bottom_margin = back_button_size + banner_view.bounds.height;
        
        add_subview(subview: container_view, superview: superview, top_margin: top, bottom_margin: bottom_margin, left_margin: left_margin, right_margin: right_margin);
        //container_view.backgroundColor = UIColor.whiteColor();
        
        
        for i in 0..<label_text.count
        {
            container_view.layoutIfNeeded();
            container_view.setNeedsLayout();
            
            var label = UIButton();
            label.setTitleColor(UIColor.white, for: UIControlState.normal);
            label.setTitleColor(UIColor.orange, for: UIControlState.highlighted);
            label.setTitle(label_text[i], for: UIControlState.normal);
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
                minus_button.setTitle("-", for: UIControlState.normal);
                minus_button.setTitleColor(UIColor.white, for: UIControlState.normal);
                minus_button.setTitleColor(UIColor.orange, for: UIControlState.highlighted);
                minus_button.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
                minus_button.addTarget(self, action: Selector("change_volume:"), for: UIControlEvents.touchDown);
                minus_button.tag = -1;
                container_view.addSubview(minus_button);
                
                // add + button
                var plus_dim:CGFloat = minus_dim;
                var plus_x = label.frame.origin.x + label.frame.width;
                var plus_y = minus_y;
                plus_button = UIButton(frame: CGRect(x: plus_x, y: plus_y, width: plus_dim, height: plus_dim));
                plus_button.setTitle("+", for: UIControlState.normal);
                plus_button.setTitleColor(UIColor.white, for: UIControlState.normal);
                plus_button.setTitleColor(UIColor.orange, for: UIControlState.highlighted);
                plus_button.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
                plus_button.addTarget(self, action: Selector("change_volume:"), for: UIControlEvents.touchDown);
                plus_button.tag = 1;
                container_view.addSubview(plus_button);
                
            }
            if(i == 1) // RESTORE PROGRESS
            {
                label.addTarget(self, action: #selector(SettingsController.clicked_reset), for: UIControlEvents.touchUpInside);
            }
            
        }
        volume_indicator.setTitle("VOLUME: " + String(volume), for: UIControlState.normal);
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
        let margin:CGFloat = superview.bounds.height / 20.0;
        addGradient(view: superview, colors: [UIColor.black.cgColor, LIGHT_BLUE.cgColor]);
        
        
        // configure container
        superview.addSubview(container_view);
        let dim:CGFloat = superview.bounds.width - (2.0 * margin);
        let y:CGFloat = (superview.bounds.height - dim) * 0.5;
        container_view.frame = CGRect(x: margin, y: y, width: dim, height: dim);
        container_view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4);
        container_view.layer.borderWidth = 1.0;
        container_view.layer.borderColor = UIColor.white.cgColor;
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
        let t_margin:CGFloat = container_view.bounds.width * 0.1;
        let text_x:CGFloat = margin;
        let text_y:CGFloat = container_view.bounds.height / 8.0;
        let text_height:CGFloat = container_view.bounds.height / 2.0;
        let text_width:CGFloat = container_view.bounds.width - (2.0 * t_margin);
        text_view.frame = CGRect(x: text_x, y: text_y, width: text_width, height: text_height);
        text_view.text = text;
        text_view.textAlignment = NSTextAlignment.center;
        text_view.textColor = UIColor.black;
        text_view.textColor = UIColor.orange;
        text_view.backgroundColor = UIColor.clear;
        text_view.font = UIFont(name: "MicroFLF", size: text_size);
        
        container_view.addSubview(text_view);
        
        // add yes button
        let yes_y:CGFloat = container_view.bounds.height * 2.0 / 3.0;
        let yes_width:CGFloat = text_width / 2.0;
        let yes_height:CGFloat = text_height / 3.0;
        let yes_x:CGFloat = t_margin + yes_width - 1.0;
        let yes_button = UIButton(frame: CGRect(x: yes_x, y: yes_y, width: yes_width, height: yes_height));
        yes_button.layer.borderWidth = 1.0;
        yes_button.layer.borderColor = UIColor.white.cgColor;
        yes_button.setTitle("Yes", for: UIControlState.normal);
        yes_button.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4);
        yes_button.setTitleColor(UIColor.orange, for: UIControlState.highlighted);
        yes_button.addTarget(self, action: "delete_data", for: UIControlEvents.touchUpInside);
        yes_button.titleLabel?.font = UIFont(name: "MicroFLF", size: font_size);
        container_view.addSubview(yes_button);
        
        
        // add no button
        let no_x:CGFloat = t_margin; // sift left 1 to account for border
        let no_y:CGFloat = yes_y;
        let no_height:CGFloat = yes_height;
        let no_width:CGFloat = yes_width + 1.0; // to account for border
        let no_button = UIButton(frame: CGRect(x: no_x, y: no_y, width: no_width, height: no_height));
        no_button.layer.borderWidth = 1.0;
        no_button.layer.borderColor = UIColor.white.cgColor;
        no_button.setTitle("No", for: UIControlState.normal);
        no_button.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4);
        no_button.setTitleColor(UIColor.orange, for: UIControlState.highlighted);
        no_button.addTarget(self, action: #selector(Thread.exit), for: UIControlEvents.touchUpInside);
        no_button.titleLabel?.font = UIFont(name: "MicroFLF", size: font_size);
        container_view.addSubview(no_button);
    }
    
    func delete_data()
    {
        /*
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let managedContext = appDelegate.managedObjectContext;
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Level");
        
        var error:NSError?;
        do {
            let results:[NSManagedObject] = try managedContext?.execute(fetch) as! [NSManagedObject];
            
            for i in 0..<results.count
            {
                managedContext?.delete(results[i]);
            }
            try managedContext?.save();
        } catch (let error) {
            print(error)
        }
        for i in 0..<LevelsController.level_buttons.count
        {
            LevelsController.level_buttons[i].progress = 0;
            
            for j in 0..<3
            {
                LevelsController.level_buttons[i].level_status_indicator[j].backgroundColor = UIColor.clear
                LevelsController.level_buttons[i].level_data = nil;
            }
        }
         */
        LevelsController.loadData();
        exit();
    }
    
    func exit()
    {
        self.superview.removeFromSuperview();
    }
}
