//
//  UIView+View.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan on 6/8/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//

import UIKit

extension UIView {
    
    func rasterizedLayer() -> CALayer {
        let layer = self.layer
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        return layer
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.shouldRasterize = true
        mask.rasterizationScale = UIScreen.main.scale
        mask.path = path.cgPath
        
        let layer = rasterizedLayer()
        layer.mask = mask
    }
    
    func fullRoundCorner() {
        DispatchQueue.main.async {
            self.clipsToBounds = true
            let layer = self.rasterizedLayer()
            
            layer.cornerRadius = self.bounds.size.height / 2
            layer.masksToBounds = true
        }
    }
    
    func addConstaintsToSuperview(leadingOffset: CGFloat, trailingOffset: CGFloat,topOffset: CGFloat, bottomOffset: CGFloat) {
        
        guard superview != nil else {
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        leadingAnchor.constraint(equalTo: superview!.leadingAnchor,
                                 constant: leadingOffset).isActive = true
        
        trailingAnchor.constraint(equalTo: superview!.trailingAnchor,
                                  constant: trailingOffset).isActive = true
        
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor,
                                constant: bottomOffset).isActive = true
        
        topAnchor.constraint(equalTo: superview!.topAnchor,
                             constant: topOffset).isActive = true
        
    }
    
}
//Mark - @IBInspectable
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            let layer = rasterizedLayer()
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            let layer = rasterizedLayer()
            return layer.cornerRadius
        }
    }
    
    
    @IBInspectable var completeRoundCorners: Bool {
        set {
            if newValue {
                fullRoundCorner()
            }else {
                let layer = rasterizedLayer()
                layer.cornerRadius = 0.0
            }
        }
        get {
            return self.completeRoundCorners
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            let layer = rasterizedLayer()
            layer.borderColor = newValue?.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            let layer = rasterizedLayer()
            layer.borderWidth = newValue / UIScreen.main.scale
        }
        get {
            let layer = rasterizedLayer()
            return (layer.borderWidth * UIScreen.main.scale)
        }
    }
    
}
