//
//  MainController.swift
//  Mine_Escape
//
//  Created by Alex Harrison on 5/18/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit

//
//  ViewController.swift
//  Animation
//
//  Created by Alex Harrison on 5/21/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import UIKit
import Foundation
import iAd

class MainController: UIViewController, ADBannerViewDelegate {
    
    var superview = UIView();
    var animate_button = UIButton();
    var animate_switch = true;
    var square = UIView();
    var result_blocker_frame = CGRect();
    var init_blocker_frame = CGRect();
    var result_mine_frame = CGRect();
    var init_mine_frame = CGRect();
    var num_rows = 8;
    var num_cols = 5;
    var result_frames = Array<CGRect>();
    var title_view = UILabel();
    var margin:CGFloat = 0.0;
    var mine_view = UIButton();
    var blocker = UIView();
    
    // configure subtitles
    var subtitles = Array<UIButton>();
    var subtitle_texts = ["free play", "about", "how to play", "settings"];
    var subtitle_margin:CGFloat = CGFloat();
    var subtitle_result_frames = Array<CGRect>();
    var delay = NSTimeInterval();
    var start_alpha:Bool = false;
    var alpha:CGFloat = 0.0;
    
    // dificulty controller testing
    var beatDifficultyController = BeatDifficultyController();
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated);
        UIView.animateWithDuration(1.5, animations: {self.blocker.frame = self.result_blocker_frame; self.mine_view.frame = self.result_mine_frame;});
        
        for(var i = 0; i < subtitles.count; ++i)
        {
            UIView.animateWithDuration(0.5, delay: 1.5, options: nil, animations: {self.subtitles[i].frame = self.subtitle_result_frames[i]}, completion: nil);
        }
        
        
        var period:NSTimeInterval = 0.01;
        var alpha_timer = NSTimer.scheduledTimerWithTimeInterval(period, target: self, selector: "appear_bottom:", userInfo: nil, repeats: true);
        
        delay = 2.0 * (1.0 / period);
        
    }
    
    func appear_bottom(timer:NSTimer)
    {
        if(!start_alpha)
        {
            delay--;
        }
        else
        {
            alpha += 0.02;
            subtitles[2].alpha = alpha;
            subtitles[3].alpha = alpha;
            if(alpha >= 1.0)
            {
                timer.invalidate();
            }
        }
        if(delay == Double(0))
        {
            start_alpha = true;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // configure superview
        superview = self.view;
        superview.frame = CGRect(x: 0.0, y: 0.0, width: superview.bounds.width, height: superview.bounds.height - banner_view.bounds.height);
        addGradient(superview, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        
        margin = superview.bounds.height * 0.05;
        
        // confogure title view
        var title_width = superview.bounds.width - (margin * 2.0);
        var title_height = title_width * 0.3;
        var title_margin = superview.bounds.height / 5.0;
        
        self.init_blocker_frame = CGRect(x: -title_height / 2.0, y: 0, width: superview.bounds.width + title_width, height: superview.bounds.height);
        self.result_blocker_frame = CGRect(x: superview.bounds.width + (title_height / 2.0), y: 0, width: superview.bounds.width + title_width, height: superview.bounds.height);
        
        
        self.init_mine_frame = CGRect(x: -title_height, y: title_margin, width: title_height, height: title_height);
        self.result_mine_frame = CGRect(x: superview.bounds.width, y: title_margin, width: title_height, height: title_height);
        
        
        // configure device specific attributes
        setDeviceInfo();
        var font_size:CGFloat = 30.0;
        var text_size:CGFloat = 20.0;
        
        switch DEVICE_VERSION
        {
        case .IPHONE_4: font_size = 34.0; text_size = 20.0;
            
        case .IPHONE_5: font_size = 34.0; text_size = 20.0;
            
        case .IPHONE_6: font_size = 40.0; text_size = 24.0;
            
        case .IPHONE_6_PLUS: font_size = 43.0; text_size = 26.0;
            
        case .IPAD: font_size = 70.0; text_size = 40.0;
            
        default: font_size = 30.0;
        }
        
        // configure title view
        var title_frame = CGRect(x: margin, y: title_margin, width: title_width, height: title_height);
        title_view = UILabel(frame: title_frame);
        title_view.text = "Mine Escape";
        title_view.font = UIFont(name: "AirstrikeBold", size: font_size);
        title_view.textAlignment = NSTextAlignment.Center;
        title_view.textColor = UIColor.orangeColor();
        superview.addSubview(title_view);
        var names = UIFont.familyNames();
        
        // confgure blocker view
        blocker = UIView(frame: self.init_blocker_frame);
        addGradient(blocker, [UIColor.blackColor().CGColor, LIGHT_BLUE.CGColor]);
        superview.addSubview(blocker);
        
        // configure logo view
        var mine_width = title_height;
        mine_view = UIButton(frame: self.init_mine_frame);
        mine_view.setBackgroundImage(UIImage(named: "mine_orange"), forState: UIControlState.Normal);
        superview.addSubview(mine_view);
        
        // configure subtitles
        var total_height = superview.bounds.height - (title_margin * 2.0);
        var sub_height = total_height / CGFloat(subtitle_texts.count + 2);
        
        for(var i:Int = 0; i < subtitle_texts.count; ++i)
        {
            var top_marg:CGFloat = (sub_height * CGFloat(i + 1)) + title_margin + (0.5 * sub_height);
            var sub_width:CGFloat = superview.bounds.width;
            
            var subtitle:UIButton;
            
            if(i == 0) // left to right
            {
                subtitle = UIButton(frame: CGRect(x: -sub_width, y: top_marg, width: sub_width, height: sub_height));
                subtitle.addTarget(self, action: "goToLevels", forControlEvents: UIControlEvents.TouchUpInside);
            }
            else if(i == 1) // right to left
            {
                subtitle = UIButton(frame: CGRect(x: sub_width, y: top_marg, width: sub_width, height: sub_height));
                subtitle.addTarget(self, action: "goToAbout", forControlEvents: UIControlEvents.TouchUpInside);
            }
            else if (i == 2) // invisible to visibe
            {
                subtitle = UIButton(frame: CGRect(x: 0, y: top_marg, width: sub_width, height: sub_height));
                subtitle.alpha = 0.0;
                subtitle.addTarget(self, action: "goToHow", forControlEvents: UIControlEvents.TouchUpInside);
            }
            else
            {
                subtitle = UIButton(frame: CGRect(x: 0, y: top_marg, width: sub_width, height: sub_height));
                subtitle.alpha = 0.0;
                subtitle.addTarget(self, action: "goToSettings", forControlEvents: UIControlEvents.TouchUpInside);
            }
            subtitle.titleLabel?.font = UIFont(name: "Galano Grotesque Alt DEMO", size: text_size);
            subtitle_result_frames.append(CGRect(x: 0.0, y: top_marg, width: sub_width, height: sub_height));
            superview.addSubview(subtitle);
            subtitle.setTitle(subtitle_texts[i], forState: UIControlState.Normal);
            subtitle.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Highlighted);
            subtitle.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
            subtitles.append(subtitle);
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
