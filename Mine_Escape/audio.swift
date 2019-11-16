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
let default_sound_path = URL(fileURLWithPath: Bundle.main.path(forResource: "button_click", ofType: "wav")!)
var default_player = AVAudioPlayer();

let won_sound_path = URL(fileURLWithPath: Bundle.main.path(forResource: "won_game", ofType: "wav")!)
var won_player = AVAudioPlayer();

let lost_sound_path = URL(fileURLWithPath: Bundle.main.path(forResource: "game_lost", ofType: "wav")!)
var lost_player = AVAudioPlayer();

let explored_sound_path = URL(fileURLWithPath: Bundle.main.path(forResource: "explore_thud", ofType: "wav")!)
var explore_player = AVAudioPlayer();

// Plays sound effect of specified sound at current colume setting
func play_sound(sound_effect:SOUND)
{
    switch sound_effect
    {
    case .EXPLORED:
        do {
            explore_player = try AVAudioPlayer(contentsOf: explored_sound_path)
        } catch (let error) {
            print("audio play error \(error)")
        }
        break;
        
    case .DEFAULT:
        do {
            explore_player = try AVAudioPlayer(contentsOf: default_sound_path)
        } catch (let error) {
            print("audio play error \(error)")
        }
        break;
    case .WON:
        do {
            explore_player = try AVAudioPlayer(contentsOf: won_sound_path)
        } catch (let error) {
            print("audio play error \(error)")
        }
        break;
    case .LOST:
        do {
            explore_player = try AVAudioPlayer(contentsOf: lost_sound_path)
        } catch (let error) {
            print("audio play error \(error)")
        }
        break;        break;
        
    }
    explore_player.volume = VOLUME_LEVEL;
    explore_player.prepareToPlay();
    explore_player.play();
}
