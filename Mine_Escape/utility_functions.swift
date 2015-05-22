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
func configure_gradient(inout background:UIView, top_color:UIColor, bottom_color:UIColor)
{
    background.setTranslatesAutoresizingMaskIntoConstraints(false);
    
    // generate constraints for background
    var width = NSLayoutConstraint(item: background, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: super_view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0);
    
    var height = NSLayoutConstraint(item: background, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: super_view, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0);
    
    var centerx = NSLayoutConstraint(item: background, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: super_view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
    
    var centery = NSLayoutConstraint(item: background, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: super_view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0);
    
    super_view.addSubview(background);
    super_view.addConstraint(width);
    super_view.addConstraint(height);
    super_view.addConstraint(centerx);
    super_view.addConstraint(centery);
    
    var test_loc = [0,1];
    var test_color = [top_color.CGColor, bottom_color.CGColor];
    
    var gradient = CAGradientLayer();
    gradient.frame = super_view.bounds;
    gradient.locations = test_loc;
    gradient.colors = test_color;
    gradient.startPoint = CGPoint(x: 0.5, y: 0.0);
    gradient.endPoint = CGPoint(x: 0.5, y: 1.0);
    background.layer.insertSublayer(gradient, atIndex: 0);
    
    super_view.addSubview(background);
    super_view.addConstraint(width);
    super_view.addConstraint(height);
    super_view.addConstraint(centerx);
    super_view.addConstraint(centery);
}

// adds back button to bottom left corner of view
func add_back_button(inout back_button:UIButton, inout superview:UIView)
{
    // configure back button properties
    var back_image = UIImage(named: "prev_level");
    back_button.setTranslatesAutoresizingMaskIntoConstraints(false);
    back_button.backgroundColor = UIColor.clearColor();
    back_button.layer.borderWidth = 1.0;
    back_button.layer.borderColor = UIColor.whiteColor().CGColor;
    back_button.setBackgroundImage(back_image, forState: UIControlState.Normal);
    
    // configure back button constraints
    
    var back_margin:CGFloat = superview.bounds.width * 0.025;
    var back_length:CGFloat = 40.0;
    
    var back_left = NSLayoutConstraint(item:back_button, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: back_margin);
    
    var back_bottom = NSLayoutConstraint(item:back_button, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -back_margin);
    
    var back_height = NSLayoutConstraint(item:back_button, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: back_button, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -back_length);
    
    var back_width = NSLayoutConstraint(item:back_button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: back_button, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0);
    
    // configure back button hiearchy
    
    superview.addSubview(back_button);
    superview.addConstraint(back_left);
    superview.addConstraint(back_bottom);
    superview.addConstraint(back_height);
    superview.addConstraint(back_width);
    
}

// adds title label
func add_title_button(inout title_label:UILabel, inout superview:UIView, text:String, margin:CGFloat, size:CGFloat)
{
    // configure title label properties
    title_label.font = UIFont(name:"Arial", size: size);
    title_label.text = text;
    title_label.textColor = UIColor.orangeColor();
    title_label.textAlignment = NSTextAlignment.Center;
    
    var center = NSLayoutConstraint(item:title_label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0);
    
    var width = NSLayoutConstraint(item:title_label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0.0);
    
    var top = NSLayoutConstraint(item:title_label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: margin);
    
    // configure back button hiearchy
    
    title_label.setTranslatesAutoresizingMaskIntoConstraints(false);
    superview.addSubview(title_label);
    superview.addConstraint(center);
    superview.addConstraint(width);
    superview.addConstraint(top);
}

// GENERATES SUPERVIEW WITH VIEW WITH CONSTRAINTS
func insert_subview(var ht_ratio:CGFloat,var width_ratio:CGFloat, var x:CGFloat, var y:CGFloat, inout parent_view:UIView, inout child_view:UIView)
{
    parent_view.setTranslatesAutoresizingMaskIntoConstraints(false);
    child_view.setTranslatesAutoresizingMaskIntoConstraints(false);
    var width_parent = parent_view.bounds.width;
    var height_parent = parent_view.bounds.height;
    var width_offset = width_parent * x;
    var height_offset = height_parent * y;
    
    // CONSTRAINTS
    var height_constr = NSLayoutConstraint(item: child_view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: parent_view, attribute: NSLayoutAttribute.Height, multiplier: ht_ratio, constant: 0.0);
    
    var width_constr = NSLayoutConstraint(item: child_view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: parent_view, attribute: NSLayoutAttribute.Width, multiplier: width_ratio, constant: 0.0);
    
    var center_x = NSLayoutConstraint(item: child_view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: parent_view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: width_offset);
    
    var center_y = NSLayoutConstraint(item: child_view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: parent_view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -height_offset);
    
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
func add_subview(var subview:UIView, var superview:UIView, var top_margin:CGFloat, var bottom_margin:CGFloat, var left_margin:CGFloat, var right_margin:CGFloat)
{
    subview.setTranslatesAutoresizingMaskIntoConstraints(false);
    
    // confogure constraints
    var left = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: left_margin);
    
    var right = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -right_margin);
    
    var top = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: top_margin);
    
    var bottom = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -bottom_margin);
    
    // configure hiearchy
    superview.addSubview(subview);
    
    // apply constraints
    superview.addConstraint(left);
    superview.addConstraint(right);
    superview.addConstraint(top);
    superview.addConstraint(bottom);
    
}

//-------------------------------------------------------------------------------------------------------------------------

func addGradient(var view:UIView, var colors:Array<CGColor>)
{
    var gradient = CAGradientLayer();
    gradient.frame = view.bounds;
    gradient.colors = colors;
    view.layer.insertSublayer(gradient, atIndex: 0);
    
}

