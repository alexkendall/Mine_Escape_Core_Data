//
//  audio.swift
//  MineEscape
//
//  Created by Alex Harrison on 4/8/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import UIKit
import AVFoundation

// enum for each sound effect type
enum SOUND{case DEFAULT, EXPLORED, WON, LOST };

// globals for various audio players and sounds
let default_sound_path = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("button_click", ofType: "wav")!)
var default_player = AVAudioPlayer();

let won_sound_path = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("won_game", ofType: "wav")!)
var won_player = AVAudioPlayer();

let lost_sound_path = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("game_lost", ofType: "wav")!)
var lost_player = AVAudioPlayer();

let explored_sound_path = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("explore_thud", ofType: "wav")!)
var explore_player = AVAudioPlayer();

// Plays sound effect of specified sound at current colume setting
func play_sound(sound_effect:SOUND)
{
    switch sound_effect
    {
    case .EXPLORED:
        explore_player = AVAudioPlayer(contentsOfURL: explored_sound_path, error: nil);
        explore_player.volume = VOLUME_LEVEL;
        explore_player.prepareToPlay();
        explore_player.play();
        break;
        
    case .DEFAULT:
        default_player = AVAudioPlayer(contentsOfURL: default_sound_path, error: nil);
        default_player.volume = VOLUME_LEVEL;
        default_player.prepareToPlay();
        default_player.play();
        break;
        
    case .WON:
        won_player = AVAudioPlayer(contentsOfURL: won_sound_path, error: nil);
        won_player.volume = VOLUME_LEVEL;
        won_player.prepareToPlay();
        won_player.play();
        break;
        
    case .LOST:
        lost_player = AVAudioPlayer(contentsOfURL: lost_sound_path, error: nil);
        lost_player.volume = VOLUME_LEVEL;
        lost_player.prepareToPlay();
        lost_player.play();
        break;
        
    }
}