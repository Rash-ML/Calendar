import Foundation
import UIKit

class StrokeLabel: UILabel {
    
    var showStroke: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var strokeColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
        
        let foo = textRect(forBounds: self.bounds, limitedToNumberOfLines: 1)
        
        guard showStroke else { return }
        
        let linePath = UIBezierPath()
        
        linePath.move(to: CGPoint(x: foo.minX - 3.0, y: foo.maxY - 4.0))
        linePath.addLine(to: CGPoint(x: foo.maxX + 5.0, y: foo.minY + 4.0))
        linePath.close()
        
        strokeColor.setStroke()
        linePath.lineWidth = 1
        linePath.stroke()
    }
}
