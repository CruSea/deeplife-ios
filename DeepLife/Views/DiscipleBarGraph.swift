//
//  DiscipleBarGraph.swift
//  DeepLife
//
//

import UIKit


struct BarGraphData {
    
    var label: String
    
    var primaryValue: Double
    
    var generationalValue: Double
    
}

@IBDesignable
class DiscipleBarGraph: UIView {
    
    private lazy var mainLayer: CALayer = {
        
        return CALayer()
        
    }()
    
    var barGraphData: [BarGraphData] = [BarGraphData]() {
        
        didSet {
            
            let highestPrimaryValue = (barGraphData.max { $0.primaryValue < $1.primaryValue })!.primaryValue
            
            let highestGenerationalValue = (barGraphData.max { $0.generationalValue < $1.generationalValue })!.generationalValue
            
            highestDataValue = max(highestPrimaryValue, highestGenerationalValue)
            
        }
        
    }
    
    var shouldAnimate: Bool = false
    
    let barWidth: CGFloat = 10.0
    
    private var highestDataValue: Double = 0
    
    private var numberOfBars: Int {
        
        get {
            
            return barGraphData.count
            
        }
        
    }
    
    private var numberOfGaps: Int {
        
        get {
            
            return numberOfBars - 1
            
        }
        
    }
    
    @IBInspectable public var sideMargin: CGFloat = 40.0
    
    @IBInspectable public var bottomMargin: CGFloat = 30.0
    
    @IBInspectable public var topMargin: CGFloat = 10.0
    
    @IBInspectable public var numberVisibleResults: Int = 5
    
    private var barGap: CGFloat {
        
        get {
            
            return (bounds.width - (3 * (3 * barWidth) + (2 * sideMargin))) / 2
            
        }
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        barGraphData = [BarGraphData(label: "Win", primaryValue: 0, generationalValue: 0),
                                            BarGraphData(label: "Build", primaryValue: 0, generationalValue: 0),
                                            BarGraphData(label: "Send", primaryValue: 0, generationalValue: 0)]
        
        renderGraph()
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupView()
        
    }
    
    convenience init() {
        
        self.init(frame: CGRect.zero)
        
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setupView()
        
    }
    
    private func setupView() {
        
        layer.addSublayer(mainLayer)
        
    }
    
    private func showEntry(index i: Int, entry: BarGraphData) {
        
        let xPos = (CGFloat(i) * ((3 * barWidth) + barGap)) + sideMargin
        
        let yPos: CGFloat = bounds.height - bottomMargin
        
        drawBar(xPos: xPos, yPos: yPos, primaryValue: entry.primaryValue, generationalValue: entry.generationalValue)
        
        drawTextValue(xPos: xPos, yPos: layer.frame.height - bottomMargin + (bottomMargin / 2), textValue: entry.label)
        
    }
    
    private func drawBar(xPos: CGFloat, yPos: CGFloat, primaryValue: Double, generationalValue: Double) {
        
        let newXPos = xPos + (2 * barWidth)
        
        if primaryValue > 0 {
        
            let primaryBarHeight: CGFloat = (CGFloat(primaryValue) / CGFloat(highestDataValue) * (bounds.height - bottomMargin - topMargin))
            
            let primaryBarShape = UIBezierPath(rect: CGRect(x: 0, y: 0, width: barWidth, height: primaryBarHeight))
            
            let primaryBarFrame = CGRect(x: xPos, y: yPos - primaryBarHeight, width: barWidth, height: primaryBarHeight)
            
            let primaryBar = CAShapeLayer()
            
            primaryBar.path = primaryBarShape.cgPath
            
            primaryBar.frame = primaryBarFrame
            
            primaryBar.fillColor = UIColor(red: 8/255, green: 99/255, blue: 221/225, alpha: 1.0).cgColor
            
            mainLayer.addSublayer(primaryBar)
            
        }
        
        if generationalValue > 0 {
        
            let generationalBarHeight: CGFloat = (CGFloat(generationalValue) / CGFloat(highestDataValue) * (bounds.height - bottomMargin - topMargin))
            
            let generationalBarShape = UIBezierPath(rect: CGRect(x: newXPos, y: yPos - generationalBarHeight, width: barWidth, height: generationalBarHeight))
            
            let generationalBar = CAShapeLayer()
            
            generationalBar.path = generationalBarShape.cgPath
            
            generationalBar.fillColor = UIColor(red: 8/255, green: 211/255, blue: 221/225, alpha: 1.0).cgColor
            
            mainLayer.addSublayer(generationalBar)
            
        }
        
    }
    
    private func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String) {
        
        let textLayer = CATextLayer()
        
        let textWidth = textValue.width(withConstrainedHeight: 22, font: UIFont.systemFont(ofSize: 13))
        
        textLayer.frame = CGRect(x: xPos, y: yPos, width: textWidth, height: 22)
        
        textLayer.foregroundColor = UIColor.black.cgColor
        
        textLayer.backgroundColor = UIColor.clear.cgColor
        
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        textLayer.contentsScale = UIScreen.main.scale
        
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        
        textLayer.fontSize = 13
        
        textLayer.string = textValue
        
        mainLayer.addSublayer(textLayer)
        
    }
    
    private func drawHorizontalValue(xPos: CGFloat, yPos: CGFloat, textValue: String) {
        
        let textLayer = CATextLayer()
        
        textLayer.frame = CGRect(x: xPos, y: yPos, width: sideMargin - 5, height: 22)
        
        textLayer.foregroundColor = UIColor.black.cgColor
        
        textLayer.backgroundColor = UIColor.clear.cgColor
        
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        textLayer.contentsScale = UIScreen.main.scale
        
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        
        textLayer.fontSize = 12
        
        textLayer.string = textValue
        
        mainLayer.addSublayer(textLayer)
        
    }
    
    private func drawHorizontalInfo() {
        
        let xPos = CGFloat(0)
        
        let bottomLabelYPos: CGFloat = bounds.height - bottomMargin
        
        drawHorizontalValue(xPos: xPos, yPos: bottomLabelYPos, textValue: "0.0")
        
        let middleLabelYPos: CGFloat = bottomLabelYPos - ((bounds.height - bottomMargin) / 2)
        
        let middleLabelValue: Double = highestDataValue / 2
        
        drawHorizontalValue(xPos: xPos, yPos: middleLabelYPos, textValue: String(format: "%.1f", middleLabelValue))
        
        let topLabelYPos: CGFloat = bottomLabelYPos - (bounds.height - bottomMargin)
        
        drawHorizontalValue(xPos: xPos, yPos: topLabelYPos, textValue: String(format: "%.1f", highestDataValue))
        
    }
    
    func renderGraph() {
        
        mainLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        for i in 0...barGraphData.count - 1 {
            
            showEntry(index: i, entry: barGraphData[i])
            
        }
        
        
    }
    
}

fileprivate extension String {
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func height(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
}
