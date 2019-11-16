//
//  ViewController.swift
//  MineEscape
//
//  Created by Alex Harrison on 3/20/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//®
import UIKit
import AVFoundation

// view of view_controller
var super_view = UIView();


// flags to identify current state of app
enum STATE{case MAIN_MENU, GAME, HOW_TO_MENU, ABOUT_MENU, VOLUME_MENU, LEVEL_MENU};
var CURRENT_STATE:STATE = STATE.MAIN_MENU;    // app starts in main menu

var DIM:Int = 4;
var current_level = 1;
var local_level = 1;
var current_difficulty = EASY;
var levels_completed = Array<Int>(); // will store this in core data in future

var levels_generated = false;

class ViewController: UIViewController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
