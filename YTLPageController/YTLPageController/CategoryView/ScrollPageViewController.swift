//
//  ScrollPageViewController.swift
//  collectionView
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import UIKit

class ScrollPageViewController: BaseViewController {
    
    fileprivate let screenWidth = UIScreen.main.bounds.width
    fileprivate let screenHeight = UIScreen.main.bounds.height
    fileprivate var currentIndex: Int = 0
    fileprivate var headerView: HeaderView = HeaderView()
    fileprivate var menuStyle: MenuStyle = MenuStyle()
    var controllers: [UIViewController] = [UIViewController]()
    var titles: [String] = [String]()
    fileprivate var historyX: CGFloat = 0
    fileprivate var forbidTouchToAdjustPosition: Bool = false
    var scrollView: UIScrollView = {
        let view = BaseScrollView()
        view.scrollsToTop = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.isPagingEnabled = true
        view.bounces = false
        view.panGestureRecognizer.delegate = view
        return view
    }()
    var menuView: MenuScrollView = MenuScrollView(frame: CGRect.zero, menuStyle: MenuStyle(), titles: [""])
    public final var currentChildController: UIViewController? {
        if currentIndex < controllers.count {
            return controllers[currentIndex]
        }
        return nil
    }

    init(viewControllers: [UIViewController], menuStyle: MenuStyle = MenuStyle()) {
        controllers = viewControllers
        titles = viewControllers.flatMap { $0.title }
        self.menuStyle = menuStyle
        if menuStyle.setCenterLayout {
            self.menuStyle.titleFontSize = 15
        } else {
            self.menuStyle.selectedTitleColor = BasicConst.Color.Color_4F5054
            self.menuStyle.normalTitleColor = BasicConst.Color.Color_4F5054
        }
        menuView = MenuScrollView(frame: CGRect.zero, menuStyle: self.menuStyle, titles: titles)
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(viewControllers: [UIViewController], initialIndex: Int, menuStyle: MenuStyle = MenuStyle()) {
        self.init(viewControllers: viewControllers, menuStyle: menuStyle)
        self.currentIndex = initialIndex
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = UIColor.white
        createUI()
    }
    
    func createUI() {
        menuView.delegate = self
        menuView.layer.shadowOpacity = 0.06
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOffset = CGSize(width: 1, height: 1)
        let extendHeight = menuStyle.hadTabbar ? -BasicConst.Layout.tabBarHeight : 0
        scrollView.frame = CGRect(x: 0, y: menuView.bottom, width: screenWidth, height: screenHeight - menuView.bottom + extendHeight)
        scrollView.delegate = self
        insertControllerToScrollView()
        view.addSubview(scrollView)
        view.addSubview(menuView)
        menuView.moveToCurrentIndex(currentIndex)
        moveToCurrentController(index: currentIndex)
    }
    
    func insertControllerToScrollView() {
        for (index, controller) in controllers.enumerated() {
            controller.view.frame = CGRect(x: CGFloat(index) * screenWidth, y: 0, width: screenWidth, height: scrollView.frame.height)
            addChildViewController(controller)
            controller.didMove(toParentViewController: self)
            scrollView.addSubview(controller.view)
        }
        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(controllers.count), height: 0)
    }
    
    // 定位controller
    // 主动 定位 vc 时，请用 func tapMenuWithIndex(index: Int)
    fileprivate func moveToCurrentController(index: Int) {
        scrollView.setContentOffset(CGPoint(x: screenWidth * CGFloat(index), y: 0), animated: false)
        updateScollsToTopProperty()
    }
    
    func updateScollsToTopProperty() {
        currentIndex = currentIndex < controllers.count ? currentIndex:0
        guard currentIndex < controllers.count else {
            return
        }
        let currentVC = controllers[currentIndex]
        controllers.forEach { (controller) in
            if controller == currentVC {
                controller.contentScollerView?.scrollsToTop = true
            } else {
                controller.contentScollerView?.scrollsToTop = false
            }
        }
    }
    
}

extension ScrollPageViewController: MenuItemViewDelegate {
    
    func tapMenuWithIndex(index: Int) {
        forbidTouchToAdjustPosition = true
        currentIndex = index
        menuView.moveToCurrentIndex(currentIndex)
        moveToCurrentController(index: index)
        (currentChildController as? BaseViewController)?.trackViewDidAppear()
    }
    
    func showExtraView() {

    }
}

extension ScrollPageViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        historyX = scrollView.contentOffset.x
        // 不是点击事件
        forbidTouchToAdjustPosition = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 如果为点击事件 return
        if forbidTouchToAdjustPosition {
            return
        }
        let scrollPercent: CGFloat = scrollView.contentOffset.x / scrollView.frame.width
        var percent: CGFloat = 0
        var willToIndex: Int = 0
        let isSwipeToRight = historyX < scrollView.contentOffset.x
        percent = scrollPercent - floor(scrollPercent)
        if isSwipeToRight {
            if percent == 0 {
                return
            }
            currentIndex = Int(floor(scrollPercent))
            willToIndex = currentIndex + 1
            if willToIndex >= controllers.count {
                willToIndex = controllers.count - 1
                return
            }
        } else {
            willToIndex = Int(floor(scrollPercent))
            currentIndex = willToIndex + 1
            if currentIndex >= controllers.count {
                currentIndex = controllers.count - 1
                return
            }
            percent = 1 - percent
        }
        historyX = scrollView.contentOffset.x
        menuView.adjustUIWithPercent(percent, oldIndex: currentIndex, currentIndex: willToIndex)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        currentIndex = index
        menuView.moveToCurrentIndex(currentIndex)
        updateScollsToTopProperty()
    }
    
}
