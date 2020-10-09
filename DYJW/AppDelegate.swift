//
//  AppDelegate.swift
//  DYJW
//
//  Created by 风筝 on 16/9/12.
//  Copyright © 2016年 Doge Studio. All rights reserved.
//

import UIKit
import SnapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13, *) {
            window?.backgroundColor = UIColor(dynamicProvider: { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return 0x121212.rgbColor
                } else {
                    return .white
                }
            })
        } else {
            window?.backgroundColor = .white
        }
        setupRootViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func setupRootViewController() {
        let tab = UITabBarController()
        
        let course = HomeCourseViewController()
        course.tabBarItem = UITabBarItem(title: "课表", image: UIImage(named: "tab_course"), selectedImage: nil)
        let eduSystem = NavigationController(rootViewController: EduSystemViewController())
        eduSystem.tabBarItem = UITabBarItem(title: "教务", image: UIImage(named: "tab_edu"), selectedImage: nil)
        let news = NavigationController(rootViewController: NewsViewController())
        news.tabBarItem = UITabBarItem(title: "新闻", image: UIImage(named: "tab_news"), selectedImage: nil)
        
        tab.viewControllers = [course, eduSystem, news]
        
        window?.rootViewController = tab
    }

}

private class NavigationController: UINavigationController, UIGestureRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        setNavigationBarHidden(true, animated: false)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.hidesBottomBarWhenPushed = viewControllers.count > 0
        super.pushViewController(viewController, animated: animated)
    }
}
