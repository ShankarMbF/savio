import UIKit
import QuartzCore
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


// delegate method
public protocol LineChartDelegate {
//    func didSelectDataPoint(x: CGFloat, yValues: [CGFloat])
//    func setValuesForSlider(min: CGFloat, max: CGFloat)
    func scrollLineDragged(_ x: CGFloat, widhtContent: CGFloat)
    func chartVerticalLineDrawingCompleted()
}

/**
 * LineChart
 */
open class LineChart: UIView {
    
    /**
    * Helpers class
    */
    fileprivate class Helpers {
        
        /**
        * Convert hex color to UIColor
        */
        fileprivate class func UIColorFromHex(_ hex: Int) -> UIColor {
            let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
            let blue = CGFloat((hex & 0xFF)) / 255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1)
        }
        /**
        * Lighten color.
        */
        fileprivate class func lightenUIColor(_ color: UIColor) -> UIColor {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return UIColor(hue: h, saturation: s, brightness: b * 1.5, alpha: a)
        }
    }
    
    public struct Labels {
        public var visible: Bool = true
        public var values: [String] = []
    }
    
    public struct Grid {
        public var visible: Bool = true
        public var count: CGFloat = 10
        // #eeeeee
        public var color: UIColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    }
    
    public struct Axis {
        public var visible: Bool = true
        // #607d8b
        public var color: UIColor = UIColor(red: 96/255.0, green: 125/255.0, blue: 139/255.0, alpha: 1)
        public var inset: CGFloat = 30
    }
    
    public struct Coordinate {
        // public
        public var labels: Labels = Labels()
        public var grid: Grid = Grid()
        public var axis: Axis = Axis()
        
        // private
        fileprivate var linear: LinearScale!
        fileprivate var scale: ((CGFloat) -> CGFloat)!
        fileprivate var invert: ((CGFloat) -> CGFloat)!
        fileprivate var ticks: (CGFloat, CGFloat, CGFloat)!
    }
    
    public struct Animation {
        public var enabled: Bool = true
        public var duration: CFTimeInterval = 1
    }
    
    public struct Dots {
        public var visible: Bool = true
        public var color: UIColor = UIColor.white
        public var innerRadius: CGFloat = 6
        public var outerRadius: CGFloat = 10
        public var innerRadiusHighlighted: CGFloat = 8
        public var outerRadiusHighlighted: CGFloat = 12
    }
    
    // default configuration
    open var area: Bool = true
    open var animation: Animation = Animation()
    open var dots: Dots = Dots()
    open var lineWidth: CGFloat = 1
    

    fileprivate var colorGraphLine: UIColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
    fileprivate var colorGraphDot: UIColor = UIColor.init(red: 242.0/255.0, green: 173.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    fileprivate var colorGraphUnderArea: UIColor = UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)
    fileprivate var colorGraphScrollLine: UIColor = UIColor.init(red: 242.0/255.0, green: 173.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    fileprivate var colorGraphProgressView: UIColor = UIColor.init(red: 242.0/255.0, green: 173.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    
    
    open var _planTitle: String = ""

    
    open var planTitle: String {
        get {
            return _planTitle
        }
        set(newValue) {
            _planTitle = newValue
            
            if _planTitle == "Group" {
                
                let blueColor: UIColor = UIColor(red: 176.0/255.0, green: 211.0/255.0, blue: 240.0/255.0, alpha: 1)
                self.colorGraphLine = blueColor
                self.colorGraphDot = blueColor
                self.colorGraphUnderArea = blueColor
                self.colorGraphScrollLine = blueColor
                self.colorGraphProgressView = blueColor
                
            } else {
                
                let brownColor: UIColor = UIColor(red: 242.0/255.0, green: 173.0/255.0, blue: 52.0/255.0, alpha: 1.0)
                self.colorGraphLine = brownColor
                self.colorGraphDot = brownColor
                self.colorGraphUnderArea = brownColor
                self.colorGraphScrollLine = brownColor
                self.colorGraphProgressView = brownColor
            }
        }
    }
    
    open var x: Coordinate = Coordinate()
    open var y: Coordinate = Coordinate()
    open var graphView: UIView = UIView()
    open var graphHeight: CGFloat = 0
    open var maximumValue: CGFloat = 0
    open var minimumValue: CGFloat = 0
    var scrollViewReference: UIScrollView  = UIScrollView()
    var thumbImgView = UIImageView()
    var graphMovingVerticalLine = UIView()

    // values calculated on init
    fileprivate var drawingHeight: CGFloat = 0 {
        didSet {
            let max = getMaximumValue()
            let min = getMinimumValue()
            y.linear = LinearScale(domain: [min, max], range: [0, drawingHeight])
            y.scale = y.linear.scale()
            y.ticks = y.linear.ticks(Int(y.grid.count))
        }
    }
    fileprivate var drawingWidth: CGFloat = 0 {
        didSet {

//            let data = dataStore[0]
            let data = x.labels.values
            x.linear = LinearScale(domain: [0.0, CGFloat(data.count - 1)], range: [0, drawingWidth])
            x.scale = x.linear.scale()
            x.invert = x.linear.invert()
            x.ticks = x.linear.ticks(Int(x.grid.count))
        }
    }
    
    open var delegate: LineChartDelegate?
    
    // data stores
    fileprivate var dataStore: [[CGFloat]] = []
    fileprivate var dotsDataStore: [[DotCALayer]] = []
    fileprivate var lineLayerStore: [CAShapeLayer] = []
    open var impulseStore: [String] = []
    
    fileprivate var removeAll: Bool = false
    
    // category10 colors from d3 - https://github.com/mbostock/d3/wiki/Ordinal-Scales
    open var colors: [UIColor] = [
        UIColor(red: 0.121569, green: 0.466667, blue: 0.705882, alpha: 1),
        UIColor(red: 1, green: 0.498039, blue: 0.054902, alpha: 1),
        UIColor(red: 0.172549, green: 0.627451, blue: 0.172549, alpha: 1),
        UIColor(red: 0.839216, green: 0.152941, blue: 0.156863, alpha: 1),
        UIColor(red: 0.580392, green: 0.403922, blue: 0.741176, alpha: 1),
        UIColor(red: 0.54902, green: 0.337255, blue: 0.294118, alpha: 1),
        UIColor(red: 0.890196, green: 0.466667, blue: 0.760784, alpha: 1),
        UIColor(red: 0.498039, green: 0.498039, blue: 0.498039, alpha: 1),
        UIColor(red: 0.737255, green: 0.741176, blue: 0.133333, alpha: 1),
        UIColor(red: 0.0901961, green: 0.745098, blue: 0.811765, alpha: 1)
    ]
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor(colorLiteralRed: 2536.0/255.0, green: 246.0/255.0, blue: 235.0/255.0, alpha: 1)
        self.backgroundColor = UIColor.clear
    }

    convenience init() {
        self.init(frame: CGRect.zero)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override open func draw(_ rect: CGRect) {
        
        graphHeight = self.bounds.height

        if removeAll {
            let context = UIGraphicsGetCurrentContext()
            context!.clear(rect)
            return
        }
        
        self.drawingHeight = graphHeight - (2 * y.axis.inset)
        self.drawingWidth = self.bounds.width - (2 * x.axis.inset)
        
        // remove all labels
        for view: AnyObject in self.subviews {
            view.removeFromSuperview()
        }
        
        // remove all lines on device rotation
        for lineLayer in lineLayerStore {
            lineLayer.removeFromSuperlayer()
        }
        lineLayerStore.removeAll()
        
        // remove all dots on device rotation
        for dotsData in dotsDataStore {
            for dot in dotsData {
                dot.removeFromSuperlayer()
            }
        }
        dotsDataStore.removeAll()
        
        // draw grid
        if x.grid.visible && y.grid.visible { drawGrid() }
        
        // draw axes
        if x.axis.visible && y.axis.visible { drawAxes() }
        
        // draw labels
        if x.labels.visible { drawXLabels() }
        if y.labels.visible { drawYLabels() }
        
        // draw lines
        for (lineIndex, _) in dataStore.enumerated() {
            
            drawLine(lineIndex)
            
            // draw dots
            if dots.visible { drawDataDots(lineIndex) }
            
            // draw area under line chart
            if area { drawAreaBeneathLineChart(lineIndex) }
            
        }
        
        
        //draw liner line
        self.drawScrollLineForPoint(x.axis.inset)
    }
    
    
    /**
     * Get y value for given x value. Or return zero or maximum value.
     */
    fileprivate func getYValuesForXValue(_ x: Int) -> [CGFloat] {
        var result: [CGFloat] = []
        for lineData in dataStore {
            if x < 0 {
                result.append(lineData[0])
            } else if x > lineData.count - 1 {
                result.append(lineData[lineData.count - 1])
            } else {
                result.append(lineData[x])
            }
        }
        return result
    }
    
    
    
    /**
     * Handle touch events.
     */
//    private func handleTouchEvents(touches: NSSet!, event: UIEvent) {
//        if (self.dataStore.isEmpty) {
//            return
//        }
//        let point: AnyObject! = touches.anyObject()
//        let xValue = point.locationInView(self).x
//        let inverted = self.x.invert(xValue - x.axis.inset)
//        let rounded = Int(round(Double(inverted)))
//        let yValues: [CGFloat] = getYValuesForXValue(rounded)
//        highlightDataPoints(rounded)
//        delegate?.didSelectDataPoint(CGFloat(rounded), yValues: yValues)
//    }
//    
//    
    
    /**
     * Listen on touch end event.
     */
//    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        handleTouchEvents(touches, event: event!)
//    }
    
    
    
    /**
     * Listen on touch move event
     */
//    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        
//        handleTouchEvents(touches, event: event!)
//    }
//    
    
    
    /**
     * Highlight data points at index.
     */
    fileprivate func highlightDataPoints(_ index: Int) {
        for (lineIndex, dotsData) in dotsDataStore.enumerated() {
            // make all dots white again
            for dot in dotsData {
                dot.backgroundColor = dots.color.cgColor
            }
            // highlight current data point
            var dot: DotCALayer
            if index < 0 {
                dot = dotsData[0]
            } else if index > dotsData.count - 1 {
                dot = dotsData[dotsData.count - 1]
            } else {
                dot = dotsData[index]
            }
//            dot.backgroundColor = Helpers.lightenUIColor(UIColor(red: 0.94, green: 0.58, blue: 0.20, alpha: 1)).CGColor
            
        }
    }
    
    
    //   circle value ....
    func setProgressForCircularFloatingProgressBar(_ index: Int)  {
        var data: [CGFloat] = self.dataStore[0]
        if data.count > 0 && data.count > index {
            
            let currentValue: CGFloat = data[index] as CGFloat
            if currentValue >= 0 {
                let progressValue = (360.0  / self.maximumValue) * currentValue
                progress.angle = Double(progressValue)
            }
        }
    }
    /**
     * Draw small dot at every data point.
     */
    fileprivate func drawDataDots(_ lineIndex: Int) {
        var dotLayers: [DotCALayer] = []
        var data = self.dataStore[lineIndex]
        
        self.setProgressForCircularFloatingProgressBar(0)
        for index in 0..<data.count {
            
            if data[index] < 0 {
                return
            }
            let xValue = self.x.scale(CGFloat(index)) + x.axis.inset - dots.outerRadius/2
            let yValue = graphHeight - self.y.scale(data[index]) - y.axis.inset - dots.outerRadius/2
            
            // draw custom layer with another layer in the center
            let dotLayer = DotCALayer()
            dotLayer.dotInnerColor = self.colorGraphDot//colors[lineIndex]
            if index == 0 {
                dotLayer.dotInnerColor = UIColor.clear//colors[lineIndex]
            }
            dotLayer.innerRadius = dots.innerRadius
            
//            if index % 2 == 0  {
//                dotLayer.backgroundColor = UIColor.clearColor().CGColor
//            } else {
//                dotLayer.backgroundColor = UIColor(colorLiteralRed: 85.0/255.0, green: 87.0/255.0, blue: 86.0/255.0, alpha: 1).CGColor
//
//            }
            
            if impulseStore[index] != "IMPULSE"  {
                dotLayer.backgroundColor = UIColor.clear.cgColor
            } else {
                dotLayer.backgroundColor = UIColor(colorLiteralRed: 85.0/255.0, green: 87.0/255.0, blue: 86.0/255.0, alpha: 1).cgColor
                
            }
            
            
            dotLayer.cornerRadius = dots.outerRadius / 2
            dotLayer.frame = CGRect(x: xValue, y: yValue, width: dots.outerRadius, height: dots.outerRadius)
            self.layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
            // animate opacity
            if animation.enabled {
                let anim = CABasicAnimation(keyPath: "opacity")
                anim.duration = animation.duration
                anim.fromValue = 0
                anim.toValue = 1
                dotLayer.add(anim, forKey: "opacity")
            }
            
        }
        dotsDataStore.append(dotLayers)
    }
    
    
    
    open var valueLabel: UILabel = UILabel()
    let widthOfScrollingLineView: CGFloat = 34.0

    let progress = KDCircularProgress(frame: CGRect(x:  0, y: -17.0, width: 34, height: 34))
    
    // scrolling line
    func scrollLineMoved(_ gesture: UIPanGestureRecognizer) {
        let  transalation = gesture.location(in: self)
        if  CGFloat(transalation.x) >= x.axis.inset && CGFloat(transalation.x) <=  self.drawingWidth + x.axis.inset {
            self.delegate?.scrollLineDragged(transalation.x, widhtContent:self.drawingWidth + x.axis.inset)
            moveScrollLineForPoint(CGFloat(transalation.x))
            let xValue = CGFloat(transalation.x)
            let inverted = self.x.invert(xValue - x.axis.inset)
            let rounded = Int(round(Double(inverted)))
            setProgressForCircularFloatingProgressBar(rounded)
            let yValues: [CGFloat] = getYValuesForXValue(rounded)
            let firstValue = yValues.first
            if firstValue >= 0 {
                let stringValue: String = String.init(format: "%.0f", firstValue!)
                self.valueLabel.text = stringValue
            }
        }
    }
    
    func drawSliderTrack() {
        let myInsets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        let trackImage = UIImage(named: "stats-slider-bar")?.resizableImage(withCapInsets: myInsets)
        let width = self.frame.size.width - x.axis.inset
        
        let trackImageView = UIImageView(frame: CGRect(x: x.axis.inset, y: self.frame.size.height , width: width, height: 4))
        trackImageView.image = trackImage
        self.addSubview(trackImageView)
    }
    
    func drawScrollLineForPoint(_ a1: CGFloat) {
        //add track images
        self.drawSliderTrack()

        graphView = UIView(frame: CGRect(x: a1 - widthOfScrollingLineView / 2.0, y: x.axis.inset, width: 40, height: self.frame.size.height ))
        graphView.backgroundColor = UIColor.clear
        
        let data = self.dataStore[0]

        
        self.valueLabel.frame = CGRect(x: 4.0 , y: widthOfScrollingLineView / 2.0 - 2.0, width: widthOfScrollingLineView - 10.0, height: 10)
        var firstValue = data.first
        if firstValue < 0 {
            firstValue = 0
        }
        let stringValue: String = String.init(format: "%.0f", firstValue!)
        self.valueLabel.text = stringValue
        self.valueLabel.font =  UIFont(name: kMediumFont, size: 7)
        self.valueLabel.textAlignment = .center
        
        //draw line
        graphMovingVerticalLine  = UIView(frame: CGRect(x: (widthOfScrollingLineView / 2.0) + 0.25                   , y: 0, width: 1, height: self.frame.size.height - 30))
        graphMovingVerticalLine.backgroundColor = self.colorGraphScrollLine
        graphView.addSubview(graphMovingVerticalLine)
        self.addSubview(graphView)
        
        //draw thumbImage 
        thumbImgView = UIImageView(frame: CGRect(x: 14, y: self.frame.size.height - 32.0, width: 8, height: 9))
        graphView.addSubview(thumbImgView)


        //white center view
        let cvRadius: CGFloat = 12.5
        let cvX: CGFloat = progress.frame.width / 2.0 - cvRadius
        let cvY: CGFloat = progress.frame.height / 2.0 - cvRadius
        let centerView = UIView(frame: CGRect(origin: CGPoint(x: cvX, y:cvY), size: CGSize(width: 2 * cvRadius, height: 2 * cvRadius)))
        centerView.layer.cornerRadius = centerView.frame.width / 2.0
        centerView.backgroundColor = UIColor.white
        progress.addSubview(centerView)

        
        
        //image view
        let imgHeight: CGFloat = 7
        let imageView: UIImageView = UIImageView(frame: CGRect(x: (widthOfScrollingLineView - imgHeight) / 2, y: imgHeight, width: imgHeight, height: imgHeight))
        imageView.image = UIImage(named: "target-score-crown")
        
        //progress view
        self.progress.addSubview(imageView)
        progress.startAngle = -90
        progress.progressThickness = 0.4
        progress.trackThickness = 0.2
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .noGlow
        progress.setColors(self.colorGraphProgressView)
        progress.trackColor = UIColor.init(red: 232.0/255.0, green: 236.0/255.0, blue: 237.0/255.0, alpha: 1.0)
        graphView.addSubview(progress)
        progress.addSubview(valueLabel)

        delegate?.chartVerticalLineDrawingCompleted()
        
        // add getsture recogniszer
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(LineChart.scrollLineMoved(_:)))
        
        graphView.addGestureRecognizer(gesture)
    }
    
    func circlePathWithCenter(_ center: CGPoint, radius: CGFloat) -> UIBezierPath {
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat(M_PI), endAngle: -CGFloat(M_PI/2), clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat(M_PI/2), endAngle: 0, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI/2), clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: CGFloat(M_PI/2), endAngle: CGFloat(M_PI), clockwise: true)
        circlePath.close()
        return circlePath
    }

     func moveScrollLineForPoint(_ a1: CGFloat) {
        graphView.frame = CGRect(x: a1 - widthOfScrollingLineView / 2, y: x.axis.inset, width: self.graphView.frame.width, height: self.frame.size.height)
    }

    /**
     * Draw x and y axis.
     */
    fileprivate func drawAxes() {
        let height = graphHeight
        let width = self.bounds.width
        let path = UIBezierPath()
        // draw x-axis
        x.axis.color.setStroke()
        let y0 = height - self.y.scale(0) - y.axis.inset
        path.move(to: CGPoint(x: x.axis.inset, y: y0))
//        path.addLineToPoint(CGPoint(x: width - x.axis.inset, y: y0))
        path.addLine(to: CGPoint(x: width + x.axis.inset , y: y0))
        path.stroke()
        // draw y-axis
        y.axis.color.setStroke()
//        path.moveToPoint(CGPoint(x: x.axis.inset, y: height - y.axis.inset))
//        path.addLineToPoint(CGPoint(x: x.axis.inset, y: y.axis.inset))
//        path.stroke()
    }
    
    
    
    /**
     * Get maximum value in all arrays in data store.
     */
    fileprivate func getMaximumValue() -> CGFloat {
//        var max: CGFloat = 1
//        for data in dataStore {
//            let newMax = data.maxElement()!
//            if newMax > max {
//                max = newMax
//            }
//        }
        return self.maximumValue
    }
    
    
    
    /**
     * Get maximum value in all arrays in data store.
     */
    fileprivate func getMinimumValue() -> CGFloat {
//        var min: CGFloat = 0
//        for data in dataStore {
//            let newMin = data.minElement()!
//            if newMin < min {
//                min = newMin
//            }
//        }
        return self.minimumValue
    }
    
    
    /**
     * Draw line.
     */
    fileprivate func drawLine(_ lineIndex: Int) {
        
        var data = self.dataStore[lineIndex]
        

        let path = UIBezierPath()
        
        var xValue = self.x.scale(0) + x.axis.inset
        var yValue = graphHeight - self.y.scale(data[0]) - y.axis.inset
        path.move(to: CGPoint(x: xValue, y: yValue))
        for index in 1..<data.count {
            if data[index]  >= 0 {
                xValue = self.x.scale(CGFloat(index)) + x.axis.inset
                yValue = graphHeight - self.y.scale(data[index]) - y.axis.inset
                path.addLine(to: CGPoint(x: xValue, y: yValue))
            }
        }
        
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath
        layer.strokeColor = self.colorGraphLine.cgColor //colors[lineIndex].CGColor
        layer.fillColor = nil
        layer.lineWidth = lineWidth
        self.layer.addSublayer(layer)
        
        // animate line drawing
        if animation.enabled {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.duration = animation.duration
            anim.fromValue = 0
            anim.toValue = 1
            layer.add(anim, forKey: "strokeEnd")
        }
        
        // add line layer to store
        lineLayerStore.append(layer)
    }
    
    
    
    /**
     * Fill area between line chart and x-axis.
     */
    fileprivate func drawAreaBeneathLineChart(_ lineIndex: Int) {
        
        var data = self.dataStore[lineIndex]
        let path = UIBezierPath()
        
       
//        colors[lineIndex].colorWithAlphaComponent(0.2).setFill()
        self.colorGraphUnderArea.withAlphaComponent(0.2).setFill()
        // move to origin
        path.move(to: CGPoint(x: x.axis.inset, y: graphHeight - self.y.scale(0) - y.axis.inset))
        // add line to first data point
        path.addLine(to: CGPoint(x: x.axis.inset, y: graphHeight - self.y.scale(data[0]) - y.axis.inset))
        // draw whole line chart
        var lastIndex = 0
        for index in 1..<data.count {
            if data[index]  >= 0 {
                let x1 = self.x.scale(CGFloat(index)) + x.axis.inset
                let y1 = graphHeight - self.y.scale(data[index]) - y.axis.inset
                path.addLine(to: CGPoint(x: x1, y: y1))
                lastIndex = index
            }
        }
        // move down to x axis
        path.addLine(to: CGPoint(x: self.x.scale(CGFloat(lastIndex)) + x.axis.inset, y: graphHeight - self.y.scale(0) - y.axis.inset))
        // move to origin
        path.addLine(to: CGPoint(x: x.axis.inset, y: graphHeight - self.y.scale(0) - y.axis.inset))
        path.fill()
    }
    
    
    
    /**
     * Draw x grid.
     */
    fileprivate func drawXGrid() {
        x.grid.color.setStroke()
        let path = UIBezierPath()
        var x1: CGFloat
        let y1: CGFloat = graphHeight - y.axis.inset
        let y2: CGFloat = y.axis.inset
        let (start, stop, step) = self.x.ticks
        
        for i in stride(from: start, to: stop, by: step)
        {
            x1 = self.x.scale(i) + x.axis.inset
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x1, y: y2))
            
        }
        
        /*  issue in swift 3 : C-style for statement has been removed in Swift 3
        for var i: CGFloat = start; i <= stop; i += step {
            x1 = self.x.scale(i) + x.axis.inset
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x1, y: y2))
        }
        */
        path.stroke()
    }
    
    /**
     * Draw y grid.
     */
    fileprivate func drawYGrid() {
        self.y.grid.color.setStroke()
        let path = UIBezierPath()
        let x1: CGFloat = x.axis.inset
        let x2: CGFloat = self.bounds.width
        var y1: CGFloat
        var (start, stop, step) = self.y.ticks
        let drawIndex: CGFloat =  floor(( (stop - start) / step ) / 5.0)
        step *= drawIndex
        for i in stride(from: start, to: stop, by: step)
        {
            y1 = graphHeight - self.y.scale(i) - y.axis.inset
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x2, y: y1))
        }
        
        
/*       issue in swift 3 -C-style for statement has been removed in Swift 3
         for var i: CGFloat = start; i <= stop; i += step {
            y1 = graphHeight - self.y.scale(i) - y.axis.inset
                path.move(to: CGPoint(x: x1, y: y1))
                path.addLine(to: CGPoint(x: x2, y: y1))
        }*/
        path.stroke()
    }
    
    /**
     * Draw grid.
     */
    fileprivate func drawGrid() {
//        drawXGrid()
        drawYGrid()
    }
    
    /**
     * Draw x labels.
     */
    fileprivate func createXLabelText (_ index: Int) -> NSMutableAttributedString {
        let text = x.labels.values[index]
        let attributes: Dictionary = [NSFontAttributeName:UIFont(name: kMediumFont, size: 8)!]
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: text, attributes: attributes)
        let fontSuper:UIFont? = UIFont(name: kMediumFont, size:4)

        switch index {
        case 0:
            let superscript = NSMutableAttributedString(string: "st", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            attString.append(superscript)
            break
            
        case 1:
            let superscript = NSMutableAttributedString(string: "nd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            attString.append(superscript)
            break
            
        case 2:
            let superscript = NSMutableAttributedString(string: "rd", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            attString.append(superscript)
            break
            
        default:
            let superscript = NSMutableAttributedString(string: "th", attributes: [NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:5])
            attString.append(superscript)
            break
            
        }
        attString.append(NSAttributedString(string: " month", attributes: attributes))
        
        return attString
    }
    
    fileprivate func drawXLabels() {
        let xAxisData = self.dataStore[0]
//        let xAxisData = self.x.labels.values
        let y = graphHeight - x.axis.inset + 4 // 4 added for giving space to supercript
        let (_, _, step) = x.linear.ticks(xAxisData.count)
        let width = x.scale(step)
     
        for (index, _) in xAxisData.enumerated() {
            let xValue = self.x.scale(CGFloat(index)) + x.axis.inset - (width / 2)
            let label = UILabel(frame: CGRect(x: xValue, y: y, width: width, height: x.axis.inset))
            label.font = UIFont(name: kMediumFont, size: 8)!
            if index == 0 {
                label.textAlignment = .right
            }
            else  if index == xAxisData.count - 1 {
                label.textAlignment = .left
            }
            else {
                label.textAlignment = .center
            }
            
            if (x.labels.values.count != 0) {
//                label.attributedText =  createXLabelText(index) //x.labels.values[index]
                label.text = x.labels.values[index]
            } else {
                label.text = String(index)
            }

            self.addSubview(label)
        }
    }
    
    
    /**
     * Draw y labels.
     */
    fileprivate func drawYLabels() {
        var yValue: CGFloat
        var (start, stop, step) = self.y.ticks
        let drawIndex: CGFloat =  floor(( (stop - start) / step ) / 5.0)
        step *= drawIndex
        
        for i in stride(from: start, to: stop, by: step)
        {
            yValue = graphHeight - self.y.scale(i) - (y.axis.inset * 1.5)
            let label = UILabel(frame: CGRect(x: 2.0, y: yValue, width: y.axis.inset - 8.0, height: y.axis.inset))
            label.font = UIFont(name: kLightFont, size: 6)
            label.textAlignment = .right
            label.text = String(Int(round(i)))
            label.backgroundColor = UIColor.clear
            self.addSubview(label)
        }
        
        
      /*    issue in swift 3 : C-style for statement has been removed in Swift 3
         
         for var i: CGFloat = start; i <= stop; i += step {
            yValue = graphHeight - self.y.scale(i) - (y.axis.inset * 1.5)
            let label = UILabel(frame: CGRect(x: 2.0, y: yValue, width: y.axis.inset - 8.0, height: y.axis.inset))
            label.font = UIFont(name: kLightFont, size: 6)
            label.textAlignment = .right
            label.text = String(Int(round(i)))
            label.backgroundColor = UIColor.clear
            self.addSubview(label)
        }
 */
    }
    
    /**
     * Add line chart
     */
    open func addLine(_ data: [CGFloat]) {
        self.dataStore.append(data)
        self.setNeedsDisplay()
    }
    
    
    
    /**
     * Make whole thing white again.
     */
    open func clearAll() {
        self.removeAll = true
        clear()
        self.setNeedsDisplay()
        self.removeAll = false
    }
    
    
    
    /**
     * Remove charts, areas and labels but keep axis and grid.
     */
    open func clear() {
        // clear data
        dataStore.removeAll()
        self.setNeedsDisplay()
    }
}



/**
 * DotCALayer
 */
class DotCALayer: CALayer {
    
    var innerRadius: CGFloat = 8
    var dotInnerColor = UIColor.black
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        let inset = self.bounds.size.width - innerRadius
        let innerDotLayer = CALayer()
        innerDotLayer.frame = self.bounds.insetBy(dx: inset/2, dy: inset/2)
        innerDotLayer.backgroundColor = dotInnerColor.cgColor
        innerDotLayer.cornerRadius = innerRadius / 2
        self.addSublayer(innerDotLayer)
    }
    
}



/**
 * LinearScale
 */
open class LinearScale {
    
    var domain: [CGFloat]
    var range: [CGFloat]
    
    public init(domain: [CGFloat] = [0, 1], range: [CGFloat] = [0, 1]) {
        self.domain = domain
        self.range = range
    }
    
    open func scale() -> (_ x: CGFloat) -> CGFloat {
        return bilinear(domain, range: range, uninterpolate: uninterpolate, interpolate: interpolate)
    }
    
    open func invert() -> (_ x: CGFloat) -> CGFloat {
        return bilinear(range, range: domain, uninterpolate: uninterpolate, interpolate: interpolate)
    }
    
    open func ticks(_ m: Int) -> (CGFloat, CGFloat, CGFloat) {
        return scale_linearTicks(domain, m: m)
    }
    
    fileprivate func scale_linearTicks(_ domain: [CGFloat], m: Int) -> (CGFloat, CGFloat, CGFloat) {
        return scale_linearTickRange(domain, m: m)
    }
    
    fileprivate func scale_linearTickRange(_ domain: [CGFloat], m: Int) -> (CGFloat, CGFloat, CGFloat) {
        var extent = scaleExtent(domain)
        let span = extent[1] - extent[0]
        var step = CGFloat(pow(10, floor(log(Double(span) / Double(m)) / M_LN10)))
        let err = CGFloat(m) / span * step
        
        // Filter ticks to get closer to the desired count.
        if (err <= 0.15) {
            step *= 10
        } else if (err <= 0.35) {
            step *= 5
        } else if (err <= 0.75) {
            step *= 2
        }
        
        // Round start and stop values to step interval.
        let start = ceil(extent[0] / step) * step
        let stop = floor(extent[1] / step) * step + step * 0.5 // inclusive
        
        return (start, stop, step)
    }
    
    fileprivate func scaleExtent(_ domain: [CGFloat]) -> [CGFloat] {
        let start = domain[0]
        let stop = domain[domain.count - 1]
        return start < stop ? [start, stop] : [stop, start]
    }
    
    fileprivate func interpolate(_ a: CGFloat, b: CGFloat) -> (_ c: CGFloat) -> CGFloat {
        var diff = b - a
        func f(_ c: CGFloat) -> CGFloat {
            return (a + diff) * c
        }
        return f
    }
    
    fileprivate func uninterpolate(_ a: CGFloat, b: CGFloat) -> (_ c: CGFloat) -> CGFloat {
        var diff = b - a
        var re = diff != 0 ? 1 / diff : 0
        func f(_ c: CGFloat) -> CGFloat {
            return (c - a) * re
        }
        return f
    }
    
    fileprivate func bilinear(_ domain: [CGFloat], range: [CGFloat], uninterpolate: (_ a: CGFloat, _ b: CGFloat) -> (_ c: CGFloat) -> CGFloat, interpolate: (_ a: CGFloat, _ b: CGFloat) -> (_ c: CGFloat) -> CGFloat) -> (_ c: CGFloat) -> CGFloat {
        var u: (_ c: CGFloat) -> CGFloat = uninterpolate(domain[0], domain[1])
        var i: (_ c: CGFloat) -> CGFloat = interpolate(range[0], range[1])
        func f(_ d: CGFloat) -> CGFloat {
            return i(u(d))
        }
        return f
    }
    
}
