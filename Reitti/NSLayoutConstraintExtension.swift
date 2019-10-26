//
//  NSLayoutConstraintExtension.swift
//  ASAHelpers
//
//  Created by Anteneh Sahledengel on 5/2/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    class public func fillSuperviewConstraints(view: UIView) -> [NSLayoutConstraint] {
        let constraint1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["view": view])
        let constraint2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["view": view])
        
        return constraint1+constraint2
    }
}
