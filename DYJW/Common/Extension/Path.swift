//
//  a.swift
//  DYJW
//
//  Created by 风筝 on 2017/12/29.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit

extension UIBezierPath {

    /// 根据SVG文件中的path字符串生成UIBezierPath
    ///
    /// - Parameter svgPath: SVG文件中的path字符串（如: "M28,30 L30,60")
    static func create(with svgPath: String, offset: CGPoint = CGPoint.zero) -> UIBezierPath {
        let commands = svgPath.components(separatedBy: " ")
        let path = UIBezierPath()
        var index = 0
        while index < commands.count {
            
            var command = commands[index]
            guard command.count > 0 else {
                index += 1
                continue
            }
            
            let firstChar = command.removeFirst()
            switch firstChar {
            case "M": path.move(to: self.getPoint(from: command, offset: offset))
            case "L": path.addLine(to: self.getPoint(from: command, offset: offset))
            case "C":
                path.addCurve(to: self.getPoint(from: commands[index + 2], offset: offset),
                                    controlPoint1: self.getPoint(from: command, offset: offset),
                                    controlPoint2: self.getPoint(from: commands[index + 1], offset: offset))
                index += 2
            case "Z": path.close()
            default: break
            }
            
            index += 1
        }
        return path
    }
    
    fileprivate static func getPoint(from pointString: String, offset: CGPoint) -> CGPoint {
        let xy = pointString.components(separatedBy: ",")
        if xy.count < 2 {
            return CGPoint.zero
        }
        guard let x = Double(xy[0]) else {
            return CGPoint.zero
        }
        guard let y = Double(xy[1]) else {
            return CGPoint.zero
        }
        return CGPoint(x: CGFloat(x) + offset.x,
                       y: CGFloat(y) + offset.y)
    }
    
}
