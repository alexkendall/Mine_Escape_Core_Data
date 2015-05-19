//
//  MainController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit


class MainController : ViewController
{
    var superview = UIView();
    var menu_options = ["free play","about", "how to play", "settings"];
    var game_name:String = "MINE ESCAPE";
    var menu_buttons = Array<UIButton>();
    var super_height = CGFloat();
    var super_width = CGFloat();
    var title_label = UILabel();
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // configure super_view
        superview = self.view;
        self.view.layoutIfNeeded();
        self.view.setNeedsLayout();
        super_height = superview.bounds.height;
        super_width = superview.bounds.width;
        
        superview = self.view;
        var colors:Array<CGColorRef> = [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor];
        addGradient(superview, colors);
        
        // configure title
        var title_height:CGFloat = 50.0;
        
        var top_title_margin:CGFloat = super_height * 0.25;
        var bottom_title_margin = super_height - top_title_margin - title_height;
        var left_title_margin:CGFloat = 0.0;
        var right_title_margin:CGFloat = 0.0;
        
        title_label.text = game_name;
        title_label.textColor = UIColor.orangeColor();
        title_label.textAlignment = NSTextAlignment.Center
        var subFontSize:CGFloat = CGFloat();
        
        // Device specific configurations
        setDeviceInfo();
        switch DEVICE_VERSION
        {
            case .IPHONE_4:
                title_label.font = UIFont.systemFontOfSize(23.0);
                subFontSize = 18.0;
            case .IPHONE_5:
                title_label.font = UIFont.systemFontOfSize(23.0);
                subFontSize = 18.0;
            case .IPHONE_6:
                title_label.font = UIFont.systemFontOfSize(30.0);
                subFontSize = 23.0;
            case .IPHONE_6_PLUS:
                title_label.font = UIFont.systemFontOfSize(35.0);
                subFontSize = 27.0;
            case .IPAD:
                title_label.font = UIFont.systemFontOfSize(60.0);
                subFontSize = 40.0;
            default:
                title_label.font = UIFont.systemFontOfSize(30.0);
                subFontSize = 23.0;
        }

        add_subview(title_label, superview, top_title_margin, bottom_title_margin, left_title_margin, right_title_margin);
        
        for(var i = 0; i < menu_options.count; ++i)
        {
            var button = UIButton();
            button.setTitle(menu_options[i], forState: UIControlState.Normal);
            button.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
            button.titleLabel?.font = UIFont.systemFontOfSize(subFontSize);
            if(i == 0)
            {
                button.addTarget(self, action: "goToLevels", forControlEvents: UIControlEvents.TouchUpInside);
            }
            if(i == 1)
            {
                button.addTarget(self, action: "goToAbout", forControlEvents: UIControlEvents.TouchUpInside);
            }
            if(i == 2)
            {
                button.addTarget(self, action: "goToHow", forControlEvents: UIControlEvents.TouchUpInside);
            }
            if(i == 3)
            {
                button.addTarget(self, action: "goToSettings", forControlEvents: UIControlEvents.TouchUpInside);
            }
            
    
            var span:CGFloat = super_height - top_title_margin - (0.25 * super_height);
            var increment:CGFloat = span / CGFloat(menu_options.count + 2);
            var sub_height = increment;
            var top_sub_margin:CGFloat = (top_title_margin * 1.50) + (increment * CGFloat(i));
            var left_sub_margin:CGFloat = 0.0;
            var right_sub_margin:CGFloat = 0.0;
            var bottom_sub_margin = super_height - top_sub_margin - sub_height;
            add_subview(button, superview, top_sub_margin, bottom_sub_margin, left_sub_margin, right_sub_margin);
        }
        
        self.addChildViewController(LevelsController);
        self.addChildViewController(AboutViewController);
        self.addChildViewController(HowController);
        self.addChildViewController(settingsController);
    }
    
    func goToLevels()
    {
        play_sound(SOUND.DEFAULT);
        superview.addSubview(LevelsController.view);
    }
    func goToAbout()
    {
        play_sound(SOUND.DEFAULT);
        superview.addSubview(AboutViewController.view);
    }
    func goToHow()
    {
        play_sound(SOUND.DEFAULT);
        superview.addSubview(HowController.view);
    }
    func goToSettings()
    {
        play_sound(SOUND.DEFAULT);
        superview.addSubview(settingsController.view);
    }
}



func addGradient(var view:UIView, var colors:Array<CGColor>)
{
    var gradient = CAGradientLayer();
    gradient.frame = view.bounds;
    gradient.colors = colors;
    view.layer.insertSublayer(gradient, atIndex: 0);
    
}