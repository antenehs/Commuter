//
//  RealtimeIndicatorView.swift
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/23/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

import UIKit

@objc class RealtimeIndicatorView: UIView {
    
    let realtimeImages = [UIImage(named:"realtime2"), UIImage(named:"realtime1")];
    var indicatorImageView = UIImageView()
    
    var timer = Timer()
    
    @objc var color: UIColor = UIColor.clear {
        didSet {
            self.indicatorImageView.tintColor = color
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        defaultInit();
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    deinit {
        self.timer.invalidate()
    }
    
    private func defaultInit() {
        indicatorImageView.removeFromSuperview()
        self.backgroundColor = UIColor.clear;
        indicatorImageView.tintColor = AppManagerBase.systemGreenColor();
        
        indicatorImageView.frame = self.frame
        indicatorImageView.image = realtimeImages[0];
        self.addSubview(indicatorImageView)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeRealtimeImage), userInfo: nil, repeats: true)
        
    }
    
    @objc func changeRealtimeImage() {
        if indicatorImageView.image == realtimeImages[0] {
            indicatorImageView.image = realtimeImages[1]
        } else {
            indicatorImageView.image = realtimeImages[0]
        }
    }
    
    func show(forView parentView: UIView) {
        self.isHidden = false
        
        let newOrigin = CGPoint(x: parentView.frame.origin.x - self.frame.size.width + 3,
                                y: parentView.frame.origin.y - self.frame.size.height + 3)
        
        self.frame = CGRect(origin: newOrigin, size: self.frame.size)
        
        parentView.superview?.addSubview(self)
        
    }
    
    func hide() {
        self.removeFromSuperview()
        self.isHidden = true
    }
    
}
