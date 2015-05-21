//
//  SettingsController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit

class SettingsController : ViewController
{
    var superview = UIView();
    var back_button = UIButton();
    var volume_slider = UISlider();
    var volume_label = UILabel();
    var restore_button = UIButton();
    
    func GoToMain()
    {
        play_sound(SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        superview = self.view;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        superview.bounds = superview.frame;
        
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        
        var baseline_height:CGFloat = 75.0;
        var seperation:CGFloat = 50.0;
        
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
        
        
        // configure volume slider
        volume_slider.setTranslatesAutoresizingMaskIntoConstraints(false);
        volume_slider.maximumValue = 1.0;
        volume_slider.minimumValue = 0.0;
        volume_slider.maximumTrackTintColor = LIGHT_BLUE;
        volume_slider.minimumTrackTintColor = UIColor.orangeColor();
        volume_slider.setValue(VOLUME_LEVEL, animated: false);
        var height_slider_:CGFloat = 40.0;
        
        var width_slider = NSLayoutConstraint(item: volume_slider, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: 0.75, constant: 0.0);
        
        var height_slider = NSLayoutConstraint(item: volume_slider, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: volume_slider, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -height_slider_);
        
        var centerx_slider = NSLayoutConstraint(item: volume_slider, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var centery_slider = NSLayoutConstraint(item: volume_slider, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0);
        
        
        // configure restore progress button
        var restore_height:CGFloat = 30.0;
        var top_margin = superview.bounds.height * 2.0 / 3.0;
        var bottom_margin = superview.bounds.height - top_margin - restore_height;
        var left_margin:CGFloat = 0.0;
        var right_margin:CGFloat = 0.0;
        add_subview(restore_button, superview, top_margin, bottom_margin, left_margin, right_margin);
        restore_button.setTitle("RESTORE PROGRESS", forState: UIControlState.Normal);
        restore_button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal);
        restore_button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted);
        restore_button.titleLabel?.font = UIFont.systemFontOfSize(20.0);
        
        
        // organize hiearchy
        superview.addSubview(volume_slider);
        superview.addConstraint(width_slider);
        superview.addConstraint(height_slider);
        superview.addConstraint(centerx_slider);
        superview.addConstraint(centery_slider);
        
        
        // configure volume label
        volume_label.setTranslatesAutoresizingMaskIntoConstraints(false);
        volume_label.backgroundColor = UIColor.orangeColor();
        volume_label.layer.borderWidth = 2.0;
        volume_label.layer.borderColor = UIColor.whiteColor().CGColor;
        volume_label.text = String(Int(100.0 * VOLUME_LEVEL));
        volume_label.textColor = UIColor.whiteColor();
        volume_label.textAlignment = NSTextAlignment.Center;
        volume_label.font = UIFont(name: "Arial", size: 30.0);
        
        var width_label = NSLayoutConstraint(item: volume_label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: 0.30, constant: 0.0);
        
        var height_label = NSLayoutConstraint(item: volume_label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Height, multiplier: 0.2, constant: -10.0);
        
        var centerx_label = NSLayoutConstraint(item: volume_label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var centery_label = NSLayoutConstraint(item: volume_label, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: volume_slider, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -30.0);
        
        superview.addSubview(volume_label);
        superview.addConstraint(width_label);
        superview.addConstraint(height_label);
        superview.addConstraint(centerx_label);
        superview.addConstraint(centery_label);
        
        add_back_button(&back_button, &superview);
        back_button.addTarget(self, action: "GoToMain", forControlEvents: UIControlEvents.TouchUpInside);
        super.viewDidLoad();
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