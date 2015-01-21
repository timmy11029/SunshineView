//
//  SunshineView.swift
//  Sunshine
//
//  Created by Tim Luebke on 1/21/15.
//  Copyright (c) 2015 Tim Luebke. All rights reserved.
//

import UIKit

@IBDesignable class SunshineView: UIView {

    @IBInspectable var rays: Int = 6
    @IBInspectable var rayAngle: CGFloat = 25.0
    @IBInspectable var rayColor: UIColor = UIColor.grayColor()
    @IBInspectable var rayOpacity: Float = 0.25
    @IBInspectable var centerRadius: CGFloat = 5.0
    @IBInspectable var centerOffset: CGPoint = CGPoint(x: 0, y: 0)
    @IBInspectable var rotationDuration: Double = 20.0
    @IBInspectable var animate: Bool = true
    {
        didSet
        {
            #if !TARGET_INTERFACE_BUILDER
                if(animate)
                {
                    startAnimation()
                }
                else
                {
                    stopAnimation()
                }
            #endif
        }
    }



    private var sunLayer:CAShapeLayer!

    private var sunPath:CGPath
        {
        get
        {
            let path: UIBezierPath = UIBezierPath()
            let width: CGFloat = frame.width / 2 + fabs(centerOffset.x)
            let height: CGFloat = frame.height / 2 + fabs(centerOffset.y)
            let rayRads: CGFloat = (rayAngle / 2) / 180 * CGFloat(M_PI)
            let centerLength: CGFloat = CGFloat(sqrtf(Float(width * width) + Float(height * height)))
            let extendedLength: CGFloat = CGFloat(centerLength / cos(rayRads))
            
            for rayNum in 0 ..< rays
            {
                let theda:CGFloat = (CGFloat(M_PI * 2) / CGFloat(rays)) * CGFloat(rayNum)
                
                path.moveToPoint(CGPointZero)
                path.addLineToPoint(CGPointMake(extendedLength * cos(theda - (rayRads)), extendedLength * sin(theda - (rayRads))))
                path.addLineToPoint(CGPointMake(extendedLength * cos(theda + (rayRads)), extendedLength * sin(theda + (rayRads))))
                path.moveToPoint(CGPointZero)
            }
            
            path.addArcWithCenter(CGPointZero, radius: centerRadius, startAngle: 0.0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            
            return path.CGPath
        }
    }

    override var frame: CGRect
        {
        didSet
        {
            drawRect(frame)
        }
    }

    override init()
    {
        super.init()
        self.layer.masksToBounds = true
    }

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.layer.masksToBounds = true
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.layer.masksToBounds = true
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if(sunLayer != nil)
        {
            sunLayer.removeFromSuperlayer()
            
        }
        
        sunLayer = CAShapeLayer()
        sunLayer.path = sunPath
        sunLayer.strokeColor = rayColor.CGColor
        sunLayer.fillColor = rayColor.CGColor
        sunLayer.position = CGPoint(x: (self.frame.width / 2) + centerOffset.x, y: (self.frame.height / 2) + centerOffset.y)
        sunLayer.opacity = rayOpacity
        sunLayer.lineWidth = 1
        
        self.layer.addSublayer(sunLayer)
        
        for subView in subviews
        {
            bringSubviewToFront(subView as UIView)
        }
    }

    private func animateView()
    {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = NSNumber(double: 0.0)
        animation.toValue = NSNumber(double: 2 * M_PI)
        animation.duration = rotationDuration
        sunLayer.addAnimation(animation, forKey: "transform")
        
    }

    private func stopAnimation()
    {
        CATransaction.begin()
        CATransaction.commit()
    }

    private func startAnimation()
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            if(self.animate)
            {
                self.startAnimation()
            }
        }
        animateView()
        CATransaction.commit()
    }
}