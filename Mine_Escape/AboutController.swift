//
//  AboutController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit

class AboutController : ViewController
{
    var superview = UIView();
    var text = "App created by Alex Harrison\n" + "alexharr@umich.edu\n" + "alexkendall.harrison@Gmail.com\n";
    var text_view = UITextView();
    var back_button = UIButton();

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
        
        // generate constraints for text_view
        var width_tv = NSLayoutConstraint(item: text_view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: 0.90, constant: 0.0);
        
        var height_tv = NSLayoutConstraint(item: text_view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Height, multiplier: 0.90, constant: 0.0);
        
        var centerx_tv = NSLayoutConstraint(item: text_view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
        
        var centery_tv = NSLayoutConstraint(item: text_view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: baseline_height + seperation);
        
        // generate title subview
        var title = UILabel();
        add_title_button(&title, &superview, "ABOUT", baseline_height, 30.0);
        
        // configure text view
        text_view.setTranslatesAutoresizingMaskIntoConstraints(false);
        text_view.frame = super_view.bounds;
        text_view.text = text;
        text_view.textAlignment = NSTextAlignment.Left;
        text_view.textColor = UIColor.whiteColor();
        text_view.backgroundColor = UIColor.clearColor();
        text_view.font = UIFont(name: "Arial", size: 18.0);
        text_view.editable = false;
        
        
        // organize hiearchy
        superview.addSubview(text_view);
        superview.addConstraint(width_tv);
        superview.addConstraint(height_tv);
        superview.addConstraint(centerx_tv);
        superview.addConstraint(centery_tv);
        
        // create back button
        add_back_button(&back_button, &superview);
        back_button.addTarget(self, action: "GoToMain", forControlEvents: UIControlEvents.TouchUpInside);
    }
}
