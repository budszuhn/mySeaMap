//
//  MSMScaleView.swift
//  mySeaMap
//
//  Created by Frank Budszuhn on 21.11.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

import UIKit

class MSMScaleView: UIView
{
    struct DrawingConstants {
        static let ScaleHeight = 3.0
    }
    
    var scaleDrawWidth = 10.0 // wird von außen gesetzt

    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        
        let width = self.scaleDrawWidth / 5.0
        let frameHeight = Double(self.frame.height.native)
        let frameWidth = Double(self.frame.width.native)
        let y = frameHeight - 10.0
        let x = frameWidth - self.scaleDrawWidth
        self.drawScale(context: context, width: width, x: x, y: y)
    }
    
    
    private func drawScale(context: CGContext?, width: Double, x: Double, y: Double)
    {
        guard let ctx = context else {
            return
        }
        
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.8).cgColor)
        
        let r1 = CGRect(x: x, y: y, width: width, height: DrawingConstants.ScaleHeight)
        let r2 = CGRect(x: x+2*width, y: y, width: width, height: DrawingConstants.ScaleHeight)
        let r3 = CGRect(x: x+4*width, y: y, width: width, height: DrawingConstants.ScaleHeight)
        
        ctx.addRects([r1,r2,r3])
        ctx.drawPath(using: .fill)
        
        ctx.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
        
        let w1 = CGRect(x:x+width, y:y, width: width, height: DrawingConstants.ScaleHeight)
        let w2 = CGRect(x:x+3*width, y:y, width: width, height: DrawingConstants.ScaleHeight)

        ctx.addRects([w1,w2])
        ctx.drawPath(using: .fill)
        
        // und hier noch einen Rahmen
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(0.5)
        let rect = CGRect(x: x, y: y, width: 5 * width, height: DrawingConstants.ScaleHeight)
        ctx.addRect(rect)
        ctx.drawPath(using: .stroke)
    }

}
