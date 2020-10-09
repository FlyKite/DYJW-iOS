//
//  GradientView.swift
//  DYJW
//
//  Created by FlyKite on 2020/6/27.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

class HeaderGradientView: UIView {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let isDark: Bool
        if #available(iOS 12.0, *) {
            isDark = traitCollection.userInterfaceStyle == .dark
        } else {
            isDark = false
        }
        if isDark {
            layer.colors = [0x263238.rgbColor.cgColor, 0x111619.rgbColor.cgColor]
        } else {
            layer.colors = [0x00BCD4.rgbColor.cgColor, 0x0086DA.rgbColor.cgColor]
        }
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    layer.colors = [0x263238.rgbColor.cgColor, 0x111619.rgbColor.cgColor]
                default:
                    layer.colors = [0x00BCD4.rgbColor.cgColor, 0x0086DA.rgbColor.cgColor]
                }
            }
        }
    }

}
