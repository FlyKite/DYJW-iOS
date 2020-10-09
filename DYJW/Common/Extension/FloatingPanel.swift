//
//  FloatingPanel.swift
//  FKTools
//
//  Created by FlyKite on 2020/1/3.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

public enum TransitionType {
    case presenting
    case dismissing
}

public struct AnimationConfig {
    
    public static var `default`: AnimationConfig = {
        return AnimationConfig()
    }()
    
    /// 遮罩类型
    public enum MaskType {
        /// 无遮罩
        case none
        /// 黑色半透明遮罩
        case black(alpha: CGFloat)
        /// 指定颜色的遮罩
        case color(color: UIColor)
    }
    
    /// present时的动画持续时间，默认值为0.35秒
    public var duration: TimeInterval = 0.35
    /// dismiss时的动画持续时间，若为nil则使用duration的值
    public var durationForDismissing: TimeInterval?
    /// 遮罩类型，默认值是alpha值为0.5的半透明黑色，
    public var maskType: MaskType = .black(alpha: 0.5)
    
    /// 可调整展示区域，默认nil不调整
    public var targetFrame: CGRect?
    /// 展示样式，默认为overFullScreen，可根据需求调整
    public var presentationStyle: UIModalPresentationStyle = .overFullScreen
    
    public init() { }
}

public typealias TransitionComplete = (_ isCancelled: Bool) -> Void

public protocol FloatingPanel: UIViewController {
    /// 通过该方法返回动画配置，若返回nil则使用默认值
    ///
    /// - Returns: 浮动面板显示隐藏时的动画配置
    func floatingPanelAnimationConfigs() -> AnimationConfig
    
    /// 转场动画开始之前该方法将被调用，该方法有一个默认的空实现，因此该方法是可选的（optional）
    /// - Parameter type: 即将开始的转场类型
    func floatingPanelWillBeginTransition(type: TransitionType)
    
    /// 通过该方法更新浮动面板显示和隐藏时的约束值或其他属性
    ///
    /// - Parameters:
    ///   - transitionType: 当前要执行的转场动画类型
    ///   - duration: 动画的总持续时长，该值与floatingPanelAnimationConfigs中返回的值一致
    ///   - completeCallback: 当动画结束时需要调用该闭包通知transitioningManager动画已结束
    func floatingPanelUpdateViews(for transitionType: TransitionType, duration: TimeInterval, completeCallback: @escaping () -> Void)
    
    /// 转场动画结束时该方法将被调用，该方法有一个默认的空实现，因此该方法是可选的（optional）
    ///
    /// - Parameters:
    ///   - type: 已结束的转场类型
    ///   - wasCancelled: 是否中途被取消
    func floatingPanelDidEndTransition(type: TransitionType, wasCancelled: Bool)
}

public extension FloatingPanel where Self: UIViewController {
    /// 隐藏浮动面板（可交互的）
    ///
    /// - Parameters:
    ///   - interactiveTransition: 传入一个交互控制器，在外部通过该对象去控制当前dismiss的进度
    ///   - animated: 是否展示动画
    ///   - completion: dismiss结束的回调
    func dismiss(with interactiveTransition: UIViewControllerInteractiveTransitioning,
                 animated: Bool,
                 completion: (() -> Void)?) {
        transitioningManager?.interactiveDismissingTransition = interactiveTransition
        dismiss(animated: animated) {
            self.transitioningManager?.interactiveDismissingTransition = nil
            completion?()
        }
    }
    
    func floatingPanelWillBeginTransition(type: TransitionType) { }
    
    func floatingPanelDidEndTransition(type: TransitionType, wasCancelled: Bool) { }
}

extension UIViewController {
    public func present(_ floatingPanel: FloatingPanel,
                        animated: Bool,
                        completion: (() -> Void)?) {
        floatingPanel.configFloatingPanelAnimator(with: nil)
        present(floatingPanel as UIViewController, animated: animated) {
            floatingPanel.transitioningManager?.interactivePresentingTransition = nil
            completion?()
        }
    }
    
    public func present(_ floatingPanel: FloatingPanel,
                        interactiveTransition: UIViewControllerInteractiveTransitioning,
                        animated: Bool,
                        completion: (() -> Void)?) {
        floatingPanel.configFloatingPanelAnimator(with: interactiveTransition)
        present(floatingPanel as UIViewController, animated: animated) {
            floatingPanel.transitioningManager?.interactivePresentingTransition = nil
            completion?()
        }
    }
}

extension FloatingPanel where Self: UIViewController {
    fileprivate func configFloatingPanelAnimator(with interactiveTransition: UIViewControllerInteractiveTransitioning?) {
        let config = floatingPanelAnimationConfigs()
        let transitioningManager = FloatingPanelTransitioning(floatingPanel: self, config: config)
        transitioningManager.interactivePresentingTransition = interactiveTransition
        modalPresentationStyle = config.presentationStyle
        transitioningDelegate = transitioningManager
        modalPresentationCapturesStatusBarAppearance = true
        self.transitioningManager = transitioningManager
    }
}

private var TransitioningManagerKey = "TransitioningManagerKey"
extension FloatingPanel {
    fileprivate var transitioningManager: FloatingPanelTransitioning? {
        get {
            return objc_getAssociatedObject(self, &TransitioningManagerKey) as? FloatingPanelTransitioning
        }
        set {
            objc_setAssociatedObject(self, &TransitioningManagerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private class FloatingPanelTransitioning: NSObject, UIViewControllerTransitioningDelegate {
    
    var interactivePresentingTransition: UIViewControllerInteractiveTransitioning?
    var interactiveDismissingTransition: UIViewControllerInteractiveTransitioning?
    let animator: FloatingPanelAnimator
    
    init(floatingPanel: FloatingPanel, config: AnimationConfig) {
        animator = FloatingPanelAnimator(floatingPanel: floatingPanel, config: config)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.transitionType = .presenting
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.transitionType = .dismissing
        return animator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactivePresentingTransition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveDismissingTransition
    }
    
}

private class FloatingPanelAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    unowned var floatingPanel: FloatingPanel
    var transitionType: TransitionType = .presenting
    
    let config: AnimationConfig
    
    init(floatingPanel: FloatingPanel, config: AnimationConfig) {
        self.floatingPanel = floatingPanel
        self.config = config
    }
    
    private lazy var maskView: UIView = UIView()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return config.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let transitionType = self.transitionType
        guard let view = transitionContext.view(forKey: transitionType.viewKey) else {
            return
        }
        let container = transitionContext.containerView
        if let targetFrame = config.targetFrame {
            container.frame = targetFrame
        }
        view.frame = container.bounds
        updateMask(for: transitionType, container: container)
        container.addSubview(view)
        
        floatingPanel.floatingPanelWillBeginTransition(type: transitionType)
        
        let duration: TimeInterval
        switch transitionType {
        case .presenting: duration = config.duration
        case .dismissing: duration = config.durationForDismissing ?? config.duration
        }
        
        floatingPanel.floatingPanelUpdateViews(for: transitionType, duration: duration) {
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
            self.floatingPanel.floatingPanelDidEndTransition(type: transitionType, wasCancelled: wasCancelled)
        }
    }
    
    private func updateMask(for transitionType: TransitionType, container: UIView) {
        if case .none = config.maskType {
            return
        }
        switch transitionType {
        case .presenting:
            maskView.backgroundColor = config.maskType.maskColor
            maskView.frame = container.bounds
            maskView.alpha = 0
            container.addSubview(maskView)
            UIView.animate(withDuration: config.duration) {
                self.maskView.alpha = 1
            }
        case .dismissing:
            UIView.animate(withDuration: config.durationForDismissing ?? config.duration) {
                self.maskView.alpha = 0
            }
        }
    }
}

private extension TransitionType {
    var viewKey: UITransitionContextViewKey {
        switch self {
        case .presenting: return .to
        case .dismissing: return .from
        }
    }
}

private extension AnimationConfig.MaskType {
    var maskColor: UIColor {
        switch self {
        case .none: return .clear
        case let .black(alpha): return UIColor(white: 0, alpha: alpha)
        case let .color(color): return color
        }
    }
}
