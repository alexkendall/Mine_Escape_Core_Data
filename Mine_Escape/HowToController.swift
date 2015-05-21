//
//  HowToController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit

class HowToController : ViewController
{
    var superview = UIView();
    var text = "Click all squares that do not contain mines." + " As you explore more squares, more mines will appear." +
        " But beware, mines disappear  after a short amount of time. Red mines will be visible longer than blue mines." +
    " You win once all squares not containing mines are explored.";
    var text_view = UITextView();
    var back_button = UIButton();
    
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
        case .IPHONE_4: font_size = 25.0; text_size = 18.0;
            
        case .IPHONE_5: font_size = 27.0; text_size = 18.0;
            
        case .IPHONE_6: font_size = 30.0; text_size = 20.0;
            
        case .IPHONE_6_PLUS: font_size = 33.0; text_size = 21.0;
            
        case .IPAD: font_size = 50.0; text_size = 30.0;
            
        default: font_size = 30.0;
        }
        
        add_title_button(&title, &superview, "HOW TO PLAY", margin, font_size);
        
        // configure text view
        add_subview(text_view, superview, (margin * 2.5), margin + back_button_size, margin, margin);
        text_view.text = text;
        text_view.textAlignment = NSTextAlignment.Left;
        text_view.textColor = UIColor.whiteColor();
        text_view.backgroundColor = UIColor.clearColor();
        text_view.font = UIFont(name: "Arial", size: text_size);
        text_view.editable = false;
        
        // create back button
        add_back_button(&back_button, &superview);
        back_button.addTarget(self, action: "GoToMain", forControlEvents: UIControlEvents.TouchUpInside);
    }
    
    func GoToMain()
    {
        play_sound(SOUND.DEFAULT);
        self.view.removeFromSuperview();
    }
}