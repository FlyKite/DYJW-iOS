//
//  FKButton.swift
//  FKTools
//
//  Created by 风筝 on 2017/9/19.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//
import UIKit

public protocol BackgroundSource {
    func updateButtonBackground(_ layer: CAGradientLayer, extraAlpha alpha: CGFloat?)
}

extension UIColor: BackgroundSource { }

public struct GradientBackground: BackgroundSource {
    
    public enum GradientType {
        case axial
        case radial
        
        @available(iOS 12.0, *)
        case conic
    }
    
    public var colors: [UIColor]?
    public var locations: [CGFloat]?
    
    public var startPoint: CGPoint = CGPoint(x: 0.5, y: 0)
    public var endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
    
    public var gradientType: GradientType = .axial
    
}

open class FKButton: UIButton {
    
    /// Sets the background source to use for the specified state.
    ///
    /// In general, if a property is not specified for a state, the default is to use the
    /// UIControlStateNormal value. If the UIControlStateNormal value is not set, then the
    /// property defaults to a system value. Therefore, at a minimum, you should set the value
    /// for the normal state.
    ///
    /// - Parameters:
    ///   - source: The background source to use for the specified state.
    ///   - state: The state that uses the specified title. The possible values are described in UIControlState.
    open func setBackground(_ source: BackgroundSource, for state: UIControl.State) {
        backgroundSourceMap[sourceKey(for: state)] = source
        checkCurrentState()
    }
    

    /// Returns the background gradient associated with the specified state.
    ///
    /// - Parameter state: The state that uses the background gradient. The possible values are described in UIControlState.
    /// - returns: The background source for the specified state. If no title has been set for the specific state, this method returns the title associated with the UIControlStateNormal state.
    open func background(for state: UIControl.State) -> BackgroundSource? {
        if let source = backgroundSourceMap[sourceKey(for: state)] {
            return source
        }
        return backgroundSourceMap[sourceKey(for: .normal)]
    }
    
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var backgroundSourceMap: [UInt: BackgroundSource] = [:]
    
    private func sourceKey(for state: UIControl.State) -> UInt {
        let selected = state.contains(.selected)
        let highlighted = state.contains(.highlighted)
        let disabled = state.contains(.disabled)
        var key: UInt = 0
        if selected {
            key |= UIControl.State.selected.rawValue
        }
        if disabled {
            key |= UIControl.State.disabled.rawValue
        } else if highlighted {
            key |= UIControl.State.highlighted.rawValue
        }
        return key
    }
    
    open override var isEnabled: Bool {
        get { return super.isEnabled }
        set {
            super.isEnabled = newValue
            checkCurrentState()
        }
    }
    
    open override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set {
            super.isHighlighted = newValue
            checkCurrentState()
        }
    }
    
    open override var isSelected: Bool {
        get { return super.isSelected }
        set {
            super.isSelected = newValue
            checkCurrentState()
        }
    }
    
    private func checkCurrentState() {
        guard let layer = layer as? CAGradientLayer else { return }
        let state = self.state
        if let source = backgroundSourceMap[sourceKey(for: state)] {
            source.updateButtonBackground(layer, extraAlpha: nil)
        } else {
            var alpha: CGFloat?
            if !isEnabled {
                alpha = 0.5
            } else if isHighlighted {
                alpha = 0.8
            }
            let source = backgroundSourceMap[sourceKey(for: .normal)] ?? UIColor.clear
            source.updateButtonBackground(layer, extraAlpha: alpha)
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                checkCurrentState()
            }
        }
    }
}

extension UIColor {
    public func updateButtonBackground(_ layer: CAGradientLayer, extraAlpha alpha: CGFloat?) {
        if let alpha = alpha {
            var colorAlpha: CGFloat = 0
            getRed(nil, green: nil, blue: nil, alpha: &colorAlpha)
            let newColor = withAlphaComponent(colorAlpha * alpha)
            layer.colors = [newColor.cgColor, newColor.cgColor]
        } else {
            layer.colors = [cgColor, cgColor]
        }
        layer.locations = [0, 1]
        layer.startPoint = .zero
        layer.endPoint = .zero
        layer.type = .axial
    }
}

extension GradientBackground {
    public func updateButtonBackground(_ layer: CAGradientLayer, extraAlpha alpha: CGFloat?) {
        layer.colors = colors?.map { (color) -> CGColor in
            if let alpha = alpha {
                var colorAlpha: CGFloat = 0
                color.getRed(nil, green: nil, blue: nil, alpha: &colorAlpha)
                return color.withAlphaComponent(colorAlpha * alpha).cgColor
            } else {
                return color.cgColor
            }
        }
        layer.locations = locations?.map { $0 as NSNumber }
        layer.startPoint = startPoint
        layer.endPoint = endPoint
        switch gradientType {
        case .axial:
            layer.type = .axial
        case .radial:
            layer.type = .radial
        case .conic:
            if #available(iOS 12, *) {
                layer.type = .conic
            }
        }
    }
}
