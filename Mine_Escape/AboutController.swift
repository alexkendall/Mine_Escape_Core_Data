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
    var text = "Created by Alex Harrison\n" + "alexharr@umich.edu\n" + "alexkendall.harrison@Gmail.com\n";
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
            case .IPHONE_4: font_size = 25.0; text_size = 15.0;
            
            case .IPHONE_5: font_size = 27.0; text_size = 15.0;
            
            case .IPHONE_6: font_size = 30.0; text_size = 18.0;
            
            case .IPHONE_6_PLUS: font_size = 33.0; text_size = 19.0;
            
            case .IPAD: font_size = 50.0; text_size = 30.0;
    
            default: font_size = 30.0;
        }
        add_title_button(&title, &superview, "ABOUT", margin, font_size);
        
        // configure text view
        text_view.setTranslatesAutoresizingMaskIntoConstraints(false);
        text_view.text = text;
        text_view.textAlignment = NSTextAlignment.Left;
        text_view.textColor = UIColor.whiteColor();
        text_view.backgroundColor = UIColor.clearColor();
        text_view.font = UIFont(name: "MicroFLF", size: text_size);
        text_view.editable = false;
        var text_margin = superview.bounds.height * 0.05;
        add_subview(text_view, superview, (margin * 2.5), text_margin, text_margin, text_margin);
        
        

        // create back button
        add_back_button(&back_button, &superview);
        back_button.addTarget(self, action: "GoToMain", forControlEvents: UIControlEvents.TouchUpInside);
    }
}






