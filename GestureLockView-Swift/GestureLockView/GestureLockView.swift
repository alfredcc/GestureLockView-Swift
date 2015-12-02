//
//  GestureLockView.swift
//  GestureLockView-Swift
//
//  Created by race on 15/12/2.
//  Copyright © 2015年 alfredcc. All rights reserved.
//

import UIKit

protocol GestureLockViewDelegate:class {
    func gestureLockView(gestureLockView: GestureLockView, didBeginWithPasscode passcode:String)
    func gestureLockView(gestureLockView: GestureLockView, didEndWithPasscode passcode:String)
    func gestureLockView(gestureLockView: GestureLockView, didCanceledWithPasscode passcode:String)
}

class GestureLockView: UIView {

    weak var delegate: GestureLockViewDelegate?
    var numberOfNodes: Int!{
        didSet {
            // 根据 Node 数量生成 Node 并添加到 View 中
            if nodes.count > 0 {
                for node in nodes {
                    node.removeFromSuperview()
                }
                nodes.removeAll()
            }

            for index in 0..<numberOfNodes {
                let node = UIButton(type: .Custom)
                node.tag = index
                node.bounds = CGRect(x: 0, y: 0, width: kNodeWidth, height: kNodeHeight)
                node.backgroundColor = UIColor.clearColor()
                node.userInteractionEnabled = false
                if let nomalImage = nomalNodeImage {
                    node.setImage(nomalImage, forState: .Normal)
                }
                if let selectImage = selectedNodeImage {
                    node.setImage(selectImage, forState: .Selected)
                }
                self.addSubview(node)
                nodes.append(node)
            }
        }
    }

    private let kNodesPerRow = 3
    private let kNodeHeight = 60.0
    private let kNodeWidth = 60.0
    private let kTrackedLocationInvalidValue: CGFloat = -1.0


    var nodes = [UIButton]()
    var nodeSize: CGSize!
    var nomalNodeImage: UIImage?
    var selectedNodeImage: UIImage?
    var selectedNodes = [UIButton]()

    let nodeLineWidth: CGFloat = 5
    let lineColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)

    var trackedLocationInView = CGPoint(x: -1, y: -1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        viewInitialize()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        // 如果有已经选择的节点需要先绘制
        if selectedNodes.count > 0 {
            let bezierPath = UIBezierPath()
            bezierPath.lineWidth = nodeLineWidth
            bezierPath.lineJoinStyle = .Round
            lineColor.setStroke()
            let firstNode = selectedNodes.first
            bezierPath.moveToPoint(firstNode!.center)
            for index in 1..<selectedNodes.count {
                let node = selectedNodes[index]
                bezierPath.addLineToPoint(node.center)
            }
            if trackedLocationInView.x != kTrackedLocationInvalidValue &&
                trackedLocationInView.y != kTrackedLocationInvalidValue {
                    bezierPath.addLineToPoint(trackedLocationInView)
                    bezierPath.stroke()
            }
        }
    }

    // MARK: - private methods
    func viewInitialize() {
        backgroundColor = UIColor.blackColor()
        nodeSize = CGSize(width: kNodeHeight, height: kNodeHeight)
        nomalNodeImage = roundImageWithColor(UIColor.greenColor(), size: nodeSize)
        selectedNodeImage = roundImageWithColor(UIColor.redColor(), size: nodeSize)
        numberOfNodes = 9
    }

    func roundImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    func nodeContainsThePoint(point: CGPoint) -> UIButton? {
        for node in nodes {
            if CGRectContainsPoint(node.frame, point) {
                return node;
            }
        }
        return nil;
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 计算 Node 的水平间距和垂直间距以及行数
        let numberOfRows = ceilf(Float(numberOfNodes / kNodesPerRow))
        let horizontalNodeMargin = (bounds.size.width - nodeSize.width * CGFloat(kNodesPerRow))/CGFloat(kNodesPerRow+1)
        let verticalNodeMargin = (bounds.size.height - nodeSize.height * CGFloat(numberOfRows))/CGFloat(numberOfRows+1)

        // 根据水平间距和垂直间距以及行数计算出每个 Node 在frame中的位置
        for index in 0..<numberOfNodes {
            let row = index / kNodesPerRow
            let column = index % kNodesPerRow
            let node = nodes[index]
            node.frame = CGRect(
                x: horizontalNodeMargin + CGFloat(floorf(Float(nodeSize.width + horizontalNodeMargin) * Float(column))),
                y: verticalNodeMargin + CGFloat(floorf(Float(nodeSize.height + verticalNodeMargin) * Float(row))),
                width: CGFloat(nodeSize.width),
                height: CGFloat(nodeSize.height))
        }
    }

    // MARK: - Touch Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch =  touches.first
        if let
            touchLocation = touch?.locationInView(self),
            touchedNode = nodeContainsThePoint(touchLocation) {
                touchedNode.selected = true
                selectedNodes.append(touchedNode)
                trackedLocationInView = touchLocation
                delegate?.gestureLockView(self, didBeginWithPasscode: String(touchedNode.tag))
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch =  touches.first
        if let touchLocation = touch?.locationInView(self) {
            trackedLocationInView = touchLocation
            if CGRectContainsPoint(bounds, touchLocation) {
                if let touchedNode = nodeContainsThePoint(touchLocation) {
                    if selectedNodes.indexOf(touchedNode) == nil {
                        touchedNode.selected = true
                        selectedNodes.append(touchedNode)
                    }
                    //If the touched button is the first button in the selected buttons,
                    //It's the beginning of the passcode creation
                    delegate?.gestureLockView(self, didBeginWithPasscode: String(touchedNode.tag))
                }
            }
        }
        setNeedsDisplay()
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if selectedNodes.count > 0 {
            var passCode = ""
            for node in selectedNodes {
                passCode += "\(node.tag)"
                 // 重置选中状态
                node.selected = false
            }
            selectedNodes.removeAll()
            delegate?.gestureLockView(self, didEndWithPasscode: passCode)
        }
        trackedLocationInView = CGPoint(x: kTrackedLocationInvalidValue, y: kTrackedLocationInvalidValue)
        setNeedsDisplay()
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if selectedNodes.count > 0 {
            var passCode = ""
            for node in selectedNodes {
                passCode += "\(node.tag)"
                // 重置选中状态
                node.selected = false
            }
            selectedNodes.removeAll()
            delegate?.gestureLockView(self, didCanceledWithPasscode: passCode)
        }
        trackedLocationInView = CGPoint(x: kTrackedLocationInvalidValue, y: kTrackedLocationInvalidValue)
        setNeedsDisplay()
    }
}
