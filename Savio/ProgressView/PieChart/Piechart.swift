
import UIKit


public protocol PiechartDelegate {
    func setSubtitle(_ total: CGFloat, slice: Piechart.Slice) -> String
    func setInfo(_ total: CGFloat, slice: Piechart.Slice) -> String
}



/**
 * Piechart
 */
open class Piechart: UIControl {
    
    /**
     * Slice
     */
    public struct Slice {
        public var color: UIColor!
        public var value: CGFloat!
        public var text: String!
    }
    
    /**
     * Radius
     */
    public struct Radius {
        public var outer: CGFloat = 125
        
        public var inner: CGFloat = 100
    
    }
    
    /**
     * private
     */
    fileprivate var total: CGFloat!
    
    
    /**
     * public
     */
    open var radius: Radius = Radius()
    open var activeSlice: Int = -1
    open var delegate: PiechartDelegate?
    
    
    open var slices: [Slice] = [] {
        didSet {
            total = 0
            for slice in slices {
                total = slice.value + total
            }
        }
    }
    
    
    
    /**
     * methods
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        self.addTarget(self, action: #selector(Piechart.click as (Piechart) -> () -> ()), for: .touchUpInside)
        
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        var startValue: CGFloat = 0
        var startAngle: CGFloat = 0
        var endValue: CGFloat = 0
        var endAngle: CGFloat = 0
        
        for (index, slice) in slices.enumerated() {
            
            startAngle = (startValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            endValue = startValue + (slice.value / self.total)
            endAngle = (endValue * 2 * CGFloat(M_PI)) - CGFloat(M_PI_2)
            
            //Create Path
            let path = UIBezierPath()
            path.move(to: center)
            
            // create center donut hole
            let innerPath = UIBezierPath()
            //innerPath.moveToPoint(center)
            
            if index == activeSlice {
                path.addArc(withCenter: center, radius: radius.outer + 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                innerPath.addArc(withCenter: center, radius: radius.inner - 2.0 , startAngle: startAngle, endAngle: endAngle, clockwise: true)
            }
            else if index == slices.count - 1 && slice.text == "Error"{
                //this will be the last slice
                path.addArc(withCenter: center, radius: radius.outer - 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//                innerPath.addArcWithCenter(center, radius: radius.inner + 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            }
            else {
                
                path.addArc(withCenter: center, radius: radius.outer, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//                innerPath.addArcWithCenter(center, radius: radius.inner, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                
            }
            
            let color = slice.color
            color?.setFill()
            path.fill()
            
//            UIColor.whiteColor().setFill()
//            innerPath.fill()
            
            // add white border to slice
            // increase start value for next slice
            startValue += slice.value / self.total
        }
        let innerPath = UIBezierPath()
        innerPath.move(to: center)
        innerPath.addArc(withCenter: center, radius: radius.inner, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
        UIColor.white.setFill()
        innerPath.fill()
    }
    
    
    func click()
    {
        
    }
    func click(_ index:Int) {
   
        activeSlice = index
        
        setNeedsDisplay()
    }
    
}
