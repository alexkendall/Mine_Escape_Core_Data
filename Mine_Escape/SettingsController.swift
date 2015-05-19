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
    
    func GoToMain()
    {
        play_sound(SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        superview = self.view;
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        
        
        var baseline_height:CGFloat = 75.0;
        var seperation:CGFloat = 50.0;
        
        // generate title subview
        
        var title = UILabel();
        add_title_button(&title, &superview, "VOLUME", baseline_height, 30.0);
        
        // configure volume slider
        volume_slider.setTranslatesAutoresizingMaskIntoConstraints(false);
        volume_slider.maximumValue = 1.0;
        volume_slider.minimumValue = 0.0;
        volume_slider.maximumTrackTintColor = LIGHT_BLUE;
        volume_slider.minimumTrackTintColor = UIColor.orangeColor();
        volume_slider.setValue(VOLUME_LEVEL, animated: false);
        
        var width_slider = NSLayoutConstraint(item: volume_slider, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: 0.75, constant: 0.0);
        
        var height_slider = NSLayoutConstraint(item: volume_slider, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: volume_slider, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -40.0);
        
        var centerx_slider = NSLayoutConstraint(item: volume_slider, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var centery_slider = NSLayoutConstraint(item: volume_slider, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0);
        
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
