//
//  TreeView.swift
//  DeepLife
//
//  Created by Gwinyai on 19/11/2018.
//  Copyright © 2018 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit

class Node {
    
    var position: CGPoint = CGPoint(x: 0, y: 0)
    
    var label: String
    
    var children: [Node] = []
    
    var profile: User
    
    weak var parent: Node?
    
    init(label: String, profile: User) {
        
        self.label = label
        
        self.profile = profile
        
    }
    
    func add(child: Node) {
        
        children.append(child)
        
        child.parent = self
        
    }
    
}

class TreeView: UIView {
    
    enum Join {
        
        case topToBottom, leftToRight, leftToRightMore
        
        static let joinLength: CGFloat = 20
        
        static let joinThickness: CGFloat = 4
        
        static let generationLength: CGFloat = 28
        
    }
    
    var generationLeap: CGFloat {
        
        return nodeHeight + Join.joinLength
        
    }
    
    var nodeWidth: CGFloat = 150.0
    
    var nodeHeight: CGFloat = 50.0
    
    var startYPos: CGFloat = 40.0
    
    var treeColor: CGColor = UIColor(hexString: "03A9F4").cgColor
    
    var textFont: UIFont = UIFont(name: "Roboto-Bold", size: 15)!
    
    var textColor: UIColor = UIColor.white
    
    private var scrollViewStartX: CGFloat = 0
    
    private var scrollViewFinalX: CGFloat = 0
    
    private lazy var scrollView: UIScrollView = {
        
        return UIScrollView()
        
    }()
    
    private lazy var mainLayer: CALayer = {
        
        return CALayer()
        
    }()
    
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
        
        scrollViewFinalX = frame.width
        
        scrollView.layer.addSublayer(mainLayer)
        
        self.addSubview(scrollView)
        
    }
    
    override func layoutSubviews() {
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
    }
    
    private func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String) {
        
        let textLayer = CATextLayer()
        
        textLayer.frame = CGRect(x: xPos, y: yPos + (nodeHeight / 2) - (textFont.pointSize / 2), width: nodeWidth, height: 30)
        
        textLayer.foregroundColor = textColor.cgColor
        
        textLayer.backgroundColor = UIColor.clear.cgColor
        
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        textLayer.contentsScale = UIScreen.main.scale
        
        textLayer.font = CTFontCreateWithName(textFont.fontName as CFString, 0, nil)
        
        textLayer.fontSize = textFont.pointSize
        
        textLayer.string = textValue
        
        mainLayer.addSublayer(textLayer)
        
    }
    
    private func drawTreeNode(xPos: CGFloat, yPos: CGFloat, label: String, joinType: Join?) {
        
        let node = CAShapeLayer()
        
        let nodeShape = UIBezierPath(rect: CGRect(x: xPos, y: yPos, width: nodeWidth, height: nodeHeight))
        
        node.path = nodeShape.cgPath
        
        node.fillColor = treeColor
        
        mainLayer.addSublayer(node)
        
        if let join = joinType {
            
            let joinLayer = CAShapeLayer()
            
            joinLayer.fillColor = nil
            
            joinLayer.strokeColor = treeColor
            
            joinLayer.lineWidth = Join.joinThickness
            
            let joinShape = UIBezierPath()
            
            joinShape.lineWidth = Join.joinThickness
            
            switch join {
                
            case .leftToRight:
                
                let joinXPos = xPos + nodeWidth
                
                let joinYPos = yPos + (nodeHeight / 2) - (Join.joinThickness / 2)
                
                joinShape.move(to: CGPoint(x: joinXPos, y: joinYPos))
                
                joinShape.addLine(to: CGPoint(x: joinXPos + Join.joinLength, y: joinYPos))
                
                joinLayer.path = joinShape.cgPath
                
            case .topToBottom:
                
                let joinXPos = xPos + (nodeWidth / 2) - (Join.joinThickness / 2)
                
                let joinYPos = yPos + nodeHeight
                
                joinShape.move(to: CGPoint(x: joinXPos, y: joinYPos))
                
                joinShape.addLine(to: CGPoint(x: joinXPos, y: joinYPos + Join.joinLength))
                
                joinLayer.path = joinShape.cgPath
                
            case .leftToRightMore:
                
                let joinXPos = xPos + nodeWidth
                
                let joinYPos = yPos + (nodeHeight / 2) - (Join.joinThickness / 2)
                
                joinShape.move(to: CGPoint(x: joinXPos, y: joinYPos))
                
                joinShape.addLine(to: CGPoint(x: joinXPos + Join.joinLength * 2, y: joinYPos))
                
                joinLayer.path = joinShape.cgPath
                
            }
            
            mainLayer.addSublayer(joinLayer)
            
        }
        
        drawTextValue(xPos: xPos, yPos: yPos, textValue: label)
        
    }
    
    func renderTree(node: Node) {
        
        mainLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let viewCenter = center
        
        let firstLevelNode: Node = node
        
        //root or first level
        
        let parentChildrenCount: Int = node.children.count
        
        var firstMiddleIndex: Int?
        
        var secondMiddleIndex: Int?
        
        if parentChildrenCount == 0 {
            
            drawTreeNode(xPos: viewCenter.x - (nodeWidth / 2), yPos: startYPos, label: node.label, joinType: Join.topToBottom)
            
        }
        else if parentChildrenCount % 2 == 0 {
            
            let halfParentChildrenCount: Int = (parentChildrenCount / 2) - 1
            
            firstMiddleIndex = halfParentChildrenCount
            
            secondMiddleIndex = halfParentChildrenCount + 1
            
            drawTreeNode(xPos: viewCenter.x - (nodeWidth / 2), yPos: startYPos, label: node.label, joinType: nil)
            
        }
        else {
            
            drawTreeNode(xPos: viewCenter.x - (nodeWidth / 2), yPos: startYPos, label: node.label, joinType: Join.topToBottom)
            
        }
        
        node.position = CGPoint(x: viewCenter.x - (nodeWidth / 2), y: startYPos)
        
        //second level
        let secondLevelCount: Int = firstLevelNode.children.count
        
        if !(secondLevelCount > 0) {
            
            return
            
        }
        
        let secondLevelWidth: CGFloat = CGFloat(secondLevelCount) * (nodeWidth) + (CGFloat(secondLevelCount - 1) * Join.joinLength)
        
        let secondLevelStartXPos: CGFloat = viewCenter.x - (secondLevelWidth / 2)
        
        let secondLevelYPos: CGFloat = nodeHeight + Join.generationLength + startYPos
        
        var thirdLevelCount: Int = 0
        
        var secondLevelNodes: [Node] = [Node]()
        
        for (index, child) in firstLevelNode.children.enumerated() {
            
            secondLevelNodes.append(child)
            
            thirdLevelCount += child.children.count
            
            let xPos: CGFloat = (CGFloat(index) * (nodeWidth + Join.joinLength)) + secondLevelStartXPos
            
            let joinType = index == (firstLevelNode.children.count - 1) ? nil : Join.leftToRight
            
            drawTreeNode(xPos: xPos, yPos: secondLevelYPos, label: child.label, joinType: joinType)
            
            if let _firstMiddleIndex = firstMiddleIndex,
                _firstMiddleIndex == index {
                
                let from = CGPoint(x: xPos + (nodeWidth / 2), y: secondLevelYPos)
                
                let to = CGPoint(x: firstLevelNode.position.x + (nodeWidth / 2), y: firstLevelNode.position.y + nodeHeight)
                
                drawConnection(from: from, to: to)
                
            }
            
            if let _secondMiddleIndex = secondMiddleIndex,
                _secondMiddleIndex == index {
                
                let from = CGPoint(x: xPos + (nodeWidth / 2), y: secondLevelYPos)
                
                let to = CGPoint(x: firstLevelNode.position.x + (nodeWidth / 2), y: firstLevelNode.position.y + nodeHeight)
                
                drawConnection(from: from, to: to)
                
            }
            
            child.position = CGPoint(x: xPos, y: secondLevelYPos)
            
            child.parent = firstLevelNode
            
            if xPos < scrollViewStartX {
                
                scrollViewStartX = xPos
                
            }
            
            if (xPos + nodeWidth) > scrollViewFinalX {
                
                scrollViewFinalX = xPos + nodeWidth
                
            }
            
        }
        
        //next level
        
        //time to get recursive
        
        if thirdLevelCount > 0 {
            
            drawNextLevel(nextLevelCount: thirdLevelCount, levelNodes: secondLevelNodes, level: 2)
            
        }
        
        let treeWidth: CGFloat = scrollViewFinalX - scrollViewStartX
        
        let treeHeight: CGFloat = frame.height
        
        scrollView.contentSize = CGSize(width: treeWidth, height: treeHeight)
        
        mainLayer.frame = CGRect(x: -scrollViewStartX, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        let contentOffset = (scrollView.contentSize.width / 2) - (frame.width / 2)
        
        scrollView.contentOffset.x = contentOffset
        
    }
    
    private func drawConnection(from: CGPoint, to: CGPoint) {
        
        let connectionLineLayer = CAShapeLayer()
        
        connectionLineLayer.fillColor = nil
        
        connectionLineLayer.strokeColor = treeColor
        
        connectionLineLayer.lineWidth = Join.joinThickness
        
        let connectionLineShape = UIBezierPath()
        
        connectionLineShape.lineWidth = Join.joinThickness
        
        let upY: CGFloat = CGFloat(abs(from.y - to.y)) / CGFloat(2)
        
        connectionLineShape.move(to: CGPoint(x: from.x, y: from.y))
        
        connectionLineShape.addLine(to: CGPoint(x: from.x, y: from.y - upY))
        
        connectionLineShape.addLine(to: CGPoint(x: to.x, y: from.y - upY))
        
        connectionLineShape.addLine(to: CGPoint(x: to.x, y: to.y))
        
        connectionLineLayer.path = connectionLineShape.cgPath
        
        mainLayer.addSublayer(connectionLineLayer)
        
    }
    
    private func drawNextLevel(nextLevelCount: Int, levelNodes: [Node], level: Int) {
        
        let levelWidth: CGFloat = CGFloat(nextLevelCount) * (nodeWidth) + (CGFloat(nextLevelCount - 1) * Join.joinLength)
        
        let levelStartXPos: CGFloat = center.x - (levelWidth / 2)
        
        let levelYPos: CGFloat = CGFloat(level) * (nodeHeight + Join.generationLength) + startYPos
        
        var levelRunningCount: Int = 0
        
        var incomingLevelNodes: [Node] = [Node]()
        
        var incomingLevelCount: Int = 0
        
        let incomingLevel: Int = level + 1
        
        for node in levelNodes {
            
            let isChildCountEven: Bool = node.children.count % 2 == 0
            
            var middleChildIndex: Int = 0
            
            if node.children.count == 1 {
                
                middleChildIndex = 0
                
            }
            else if isChildCountEven {
                
                middleChildIndex = (node.children.count / 2) - 1
                
            }
            else {
                
                let evenCount: Int = node.children.count - 1
                
                let middleCount: Int = evenCount / 2
                
                middleChildIndex = middleCount + 1
                
            }
            
            for (childIndex, child) in node.children.enumerated() {
                
                let xPos: CGFloat = (CGFloat(levelRunningCount) * (nodeWidth + Join.joinLength)) + levelStartXPos
                
                incomingLevelNodes.append(child)
                
                levelRunningCount += 1
                
                incomingLevelCount += child.children.count
                
                let joinType = childIndex == (node.children.count - 1) ? nil : Join.leftToRight
                
                drawTreeNode(xPos: xPos, yPos: levelYPos, label: child.label, joinType: joinType)
                
                if childIndex == middleChildIndex {
                    
                    let from = CGPoint(x: xPos + (nodeWidth / 2), y: levelYPos)
                    
                    let to = CGPoint(x: node.position.x + (nodeWidth / 2), y: node.position.y + nodeHeight)
                    
                    drawConnection(from: from, to: to)
                    
                }
                
                child.position = CGPoint(x: xPos, y: levelYPos)
                
                child.parent = node
                
                if xPos < scrollViewStartX {
                    
                    scrollViewStartX = xPos
                    
                }
                
                if (xPos + nodeWidth) > scrollViewFinalX {
                    
                    scrollViewFinalX = xPos + nodeWidth
                    
                }
                
            }
            
        }
        
        if incomingLevelCount > 0 {
            
            self.drawNextLevel(nextLevelCount: incomingLevelCount, levelNodes: incomingLevelNodes, level: incomingLevel)
            
        }
        
    }
    
    override func didMoveToSuperview() {
        
        /*
        let fourthLevelNode1 = Node(label: "Left")
        
        let thirdLevelNode1 = Node(label: "Left")
        
        thirdLevelNode1.children = [fourthLevelNode1]
        
        let thirdLevelNode2 = Node(label: "Left")
        
        let thirdLevelNode3 = Node(label: "Left")
        
        let thirdLevelNode4 = Node(label: "Left")
        
        let thirdLevelNode5 = Node(label: "Left")
        
        let secondLevelNode1 = Node(label: "Left")
        
        secondLevelNode1.children = [thirdLevelNode1, thirdLevelNode2]
        
        let secondLevelNode2 = Node(label: "Left")
        
        secondLevelNode2.children = [thirdLevelNode3, thirdLevelNode4, thirdLevelNode5]
        
        let rootNode = Node(label: "Root")
        
        rootNode.children = [secondLevelNode1, secondLevelNode2]
        
        renderTree(node: rootNode)
        */
        
    }
    
}
