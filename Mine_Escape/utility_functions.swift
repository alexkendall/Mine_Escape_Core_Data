//
//  functions.swift
//  MineEscape
//
//  Created by Alex Harrison on 4/14/15.
//  Copyright (c) 2015 Alex Harrison. All rights reserved.
//

import Foundation
import UIKit

var back_button_size:CGFloat = 40.0;

// created gradient on background view
func configure_gradient( background:inout UIView, top_color:UIColor, bottom_color:UIColor)
{
    background.translatesAutoresizingMaskIntoConstraints = false
    
    // generate constraints for background
    let width = NSLayoutConstraint(item: background, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: super_view, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0);
    
    let height = NSLayoutConstraint(item: background, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: super_view, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0.0);
    
    let centerx = NSLayoutConstraint(item: background, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: super_view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0);
    
    let centery = NSLayoutConstraint(item: background, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: super_view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0);
    
    super_view.addSubview(background);
    super_view.addConstraint(width);
    super_view.addConstraint(height);
    super_view.addConstraint(centerx);
    super_view.addConstraint(centery);
    
    let test_loc = [0,1];
    let test_color = [top_color.cgColor, bottom_color.cgColor];
    
    let gradient = CAGradientLayer();
    gradient.frame = super_view.bounds;
    gradient.locations = test_loc as [NSNumber];
    gradient.colors = test_color;
    gradient.startPoint = CGPoint(x: 0.5, y: 0.0);
    gradient.endPoint = CGPoint(x: 0.5, y: 1.0);
    background.layer.insertSublayer(gradient, at: 0);
    
    super_view.addSubview(background);
    super_view.addConstraint(width);
    super_view.addConstraint(height);
    super_view.addConstraint(centerx);
    super_view.addConstraint(centery);
}

// adds back button to bottom left corner of view
func add_back_button( back_button:inout UIButton, superview:inout UIView)
{
    // configure back button properties
    let back_image = UIImage(named: "prev_level");
    back_button.translatesAutoresizingMaskIntoConstraints = false;
    back_button.backgroundColor = UIColor.clear;
    back_button.layer.borderWidth = 1.0;
    back_button.layer.borderColor = UIColor.white.cgColor;
    back_button.setBackgroundImage(back_image, for: UIControlState.normal);
    
    // configure back button constraints
    
    let back_margin:CGFloat = superview.bounds.width * 0.025;
    let back_length:CGFloat = 40.0;
    global_but_margin = back_margin;
    global_but_dim = back_length;
    
    let back_left = NSLayoutConstraint(item:back_button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: back_margin);
    
    let back_bottom = NSLayoutConstraint(item:back_button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -back_margin);
    
    let back_height = NSLayoutConstraint(item:back_button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: back_button, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -back_length);
    
    let back_width = NSLayoutConstraint(item:back_button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: back_button, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0.0);
    
    // configure back button hiearchy
    
    superview.addSubview(back_button);
    superview.addConstraint(back_left);
    superview.addConstraint(back_bottom);
    superview.addConstraint(back_height);
    superview.addConstraint(back_width);
    
}

// adds title label
func add_title_button( title_label: UILabel, superview: UIView, text:String, margin:CGFloat, size:CGFloat)
{
    // configure title label properties
    title_label.font = UIFont(name: "Galano Grotesque Alt DEMO", size: size);
    title_label.text = text;
    title_label.textColor = UIColor.orange;
    title_label.textAlignment = NSTextAlignment.center;
    
    let center = NSLayoutConstraint(item:title_label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0);
    
    let width = NSLayoutConstraint(item:title_label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0);
    
    let top = NSLayoutConstraint(item:title_label, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: margin);
    
    // configure back button hiearchy
    
    title_label.translatesAutoresizingMaskIntoConstraints = false;
    superview.addSubview(title_label);
    superview.addConstraint(center);
    superview.addConstraint(width);
    superview.addConstraint(top);
}

// GENERATES SUPERVIEW WITH VIEW WITH CONSTRAINTS
func insert_subview(ht_ratio:CGFloat,cwidth_ratio:CGFloat, x:CGFloat, y:CGFloat, parent_view:inout UIView, child_view: UIView)
{
    parent_view.translatesAutoresizingMaskIntoConstraints = false;    child_view.translatesAutoresizingMaskIntoConstraints = false
    let width_parent = parent_view.bounds.width;
    let height_parent = parent_view.bounds.height;
    let width_offset = width_parent * x;
    let height_offset = height_parent * y;
    
    // CONSTRAINTS
    let height_constr = NSLayoutConstraint(item: child_view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: parent_view, attribute: NSLayoutAttribute.height, multiplier: ht_ratio, constant: 0.0);
    
    let width_constr = NSLayoutConstraint(item: child_view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: parent_view, attribute: NSLayoutAttribute.width, multiplier: cwidth_ratio, constant: 0.0);
    
    let center_x = NSLayoutConstraint(item: child_view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: parent_view, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: width_offset);
    
    let center_y = NSLayoutConstraint(item: child_view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: parent_view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -height_offset);
    
    parent_view.addSubview(child_view);
    parent_view.addConstraint(height_constr);
    parent_view.addConstraint(width_constr);
    parent_view.addConstraint(center_x);
    parent_view.addConstraint(center_y);
}

//-------------------------------------------------------------------------------------------------------------------------

// requires: nothing
// modifies: subview
// effects: centers subview to superview, sets height and width to height and width ratios of superview
func add_subview( subview:UIView, superview:UIView, top_margin:CGFloat, bottom_margin:CGFloat, left_margin:CGFloat, right_margin:CGFloat)
{
    subview.translatesAutoresizingMaskIntoConstraints = false;
    
    // confogure constraints
    let left = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: left_margin);
    
    let right = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -right_margin);
    
    let top = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: top_margin);
    
    let bottom = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -bottom_margin);
    
    // configure hiearchy
    superview.addSubview(subview);
    
    // apply constraints
    superview.addConstraint(left);
    superview.addConstraint(right);
    superview.addConstraint(top);
    superview.addConstraint(bottom);
}

func AddSubview(subview:UIView, superview:UIView, in_x:CGFloat, in_y:CGFloat, width:CGFloat, height:CGFloat)
{
    subview.frame = CGRect(x: in_x, y: in_y, width: width, height: height);
    superview.addSubview(subview);
}

//-------------------------------------------------------------------------------------------------------------------------

func addGradient(view:UIView, colors:Array<CGColor>)
{
    let gradient = CAGradientLayer();
    gradient.frame = view.bounds;
    gradient.colors = colors;
    view.layer.insertSublayer(gradient, at: 0);
}

