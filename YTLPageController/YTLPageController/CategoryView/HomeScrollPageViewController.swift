//
//  HomeScrollPageViewController.swift
//  Client
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import UIKit
import Foundation

public let screenWidth = UIScreen.main.bounds.width
public let screenHeight = UIScreen.main.bounds.height

class HomeScrollPageViewController: UIViewController {
    
    fileprivate var headerView: HeaderView = HeaderView()
    var collectView: MoveCategoryViewController!
    fileprivate var menuStyle: MenuStyle = MenuStyle()
    var titles: [String] = ["关注", "推荐"]
    fileprivate var historyX: CGFloat = 0
    fileprivate var forbidTouchToAdjustPosition: Bool = false
    fileprivate var tabbarFrame = CGRect.zero
    fileprivate var signTaskTipFrame = CGRect.zero
    var currentIndex: Int = 0
    var channelData: [CategoryBarEntity] = [CategoryBarEntity]()
    var collectStyle = CollectStyle()
    var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.scrollsToTop = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.isPagingEnabled = true
        view.bounces = false
//        view.panGestureRecognizer.delegate = view
        return view
    }()
    var menuView: MenuScrollView = MenuScrollView(frame: CGRect.zero, menuStyle: MenuStyle(), titles: [""])
    var previousVC: UIViewController?
    var currentVC: UIViewController?
    var nextVC: UIViewController?
    enum `Type`: Int {
        case previous = -1
        case current = 0
        case next = 1
    }
    var previousX: CGFloat = 0
    
    var topGuideHeight: CGFloat {
        let navH = navigationController?.navigationBar.bounds.size.height ?? 0
        let nsHeight = navH + UIApplication.shared.statusBarFrame.size.height
        return nsHeight
    }
    public final var currentChildController: UIViewController? {
        return currentVC
    }
    
    init(data: [CategoryBarEntity], menuStyle: MenuStyle = MenuStyle()) {
        channelData = data
        self.menuStyle = menuStyle
        if menuStyle.setCenterLayout {
            self.menuStyle.titleFontSize = 15
        } else {
            self.menuStyle.selectedTitleColor = UIColor.black
            self.menuStyle.normalTitleColor = UIColor.gray
        }
        menuView = MenuScrollView(frame: CGRect.zero, menuStyle: self.menuStyle, titles: titles)
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(data: [CategoryBarEntity], initialIndex: Int, menuStyle: MenuStyle = MenuStyle()) {
        self.init(data: data, menuStyle: menuStyle)
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
    
        scrollView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: screenWidth, height: screenHeight - menuView.frame.maxY)
        scrollView.delegate = self
        setScrollViewContentSize()
        view.addSubview(scrollView)
        
        collectStyle.viewAlpha = 0.98
        collectStyle.editDelete = true
        collectStyle.headerY = menuView.frame.origin.y
        collectStyle.headerHeight = menuView.bounds.height
        collectStyle.fixItems = [0, 1]
        collectStyle.viewFrame = CGRect(x: 0.0, y: -screenHeight, width: view.bounds.size.width, height: screenHeight - menuView.frame.maxY)
        collectView = MoveCategoryViewController(data: titles, selectIndex: currentIndex, collectStyle: collectStyle)
        collectView.delegate = self
        addChild(collectView)
        collectView.didMove(toParent: self)
        view.addSubview(collectView.view)
        headerView = HeaderView(frame: CGRect(x: 0, y: menuView.frame.minY, width: screenWidth, height: menuView.bounds.height))
        headerView.layer.shadowOpacity = 0.06
        headerView.layer.shadowColor = UIColor.gray.cgColor
        headerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        headerView.didClickExtraButton = { [weak self] in
            self?.collectView.clickExtraButton()
        }
        headerView.didClickDeleteButton = { [weak self] in
            guard let self = self else {
                return
            }
            self.collectView.clickDeleteButton(isLongPress: false)
            self.headerView.isEdit = !self.collectView.clickItem
        }
        view.addSubview(headerView)
        
        view.addSubview(menuView)
        initControllers()
        menuView.moveToCurrentIndex(currentIndex)
    }
    
    func initControllers() {
        if !channelData.isEmpty {
            updateChannelListData(data: channelData)
        }
    }
    
    fileprivate func setupTitles() {
        if channelData.isEmpty {
            titles = ["关注", "推荐"]
        } else {
            titles.removeAll()
            for entity in channelData {
                titles.append(entity.name)
            }
        }
    }
    
    func updateChannelListData(data: [CategoryBarEntity]) {
        guard !data.isEmpty else {
            return
        }
        channelData = data
        setupTitles()
        setScrollViewContentSize()
        var index = 0
        if currentIndex < data.count {
            index = currentIndex
        }
        currentIndex = index
        if collectView != nil {
            collectView.updateData(titles: titles, data: data, index: currentIndex)
        }
        reloadControllersWithNewData(data: channelData, index: index)
        menuView.reloadTitlesWithNewTitles(titles, data: channelData, index: index)
        setRightBarMaskViewUpdateState()
    }
    
    fileprivate func setScrollViewContentSize() {
        let count: Int = channelData.isEmpty ? titles.count:channelData.count
        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(count), height: 0)
    }
    
    //刷新控制器
    fileprivate func reloadControllersWithNewData(data: [CategoryBarEntity], index: Int) {
        clickAndMoveControllerPosition(index: index)
        moveToCurrentController(index: index)
    }
    
    // 定位controller
    // 主动 定位 vc 时，请用 func tapMenuWithIndex(index: Int)
    func moveToCurrentController(index: Int) {
        scrollView.setContentOffset(CGPoint(x: screenWidth * CGFloat(index), y: 0), animated: false)
        updateScollsToTopProperty()
    }
    
    fileprivate func updateScollsToTopProperty() {
//        previousVC?.contentScollerView?.scrollsToTop = false
//        nextVC?.contentScollerView?.scrollsToTop = false
//        currentVC?.contentScollerView?.scrollsToTop = true
    }

    func actionCanDoWhenShowExtraView() {
        self.menuView.alpha = 0
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideAudioBar"), object: nil)
        if let frame = tabBarController?.tabBar.frame {
            tabbarFrame = frame
            tabBarController?.tabBar.frame = CGRect(x: 0, y: screenHeight, width: frame.width, height: frame.height)
        }
    }
    
    func actionCanDoWhenHideExtraView() {
        if collectView.hasChangeChannelOrder {
            hasChangeChannelOrder()
        }
        tabBarController?.tabBar.frame = CGRect(x: 0, y: screenHeight - tabbarFrame.height, width: tabbarFrame.width, height: tabbarFrame.height)
    }
    
    func setRightBarMaskViewUpdateState() {
       
    }
    
    func setRightBarMaskViewData() {

    }
    
    func saveListData() {
       // CategoryManager.manager.updateChannelListData(data: channelData)
    }
    // 修改过频道
    func hasChangeChannelOrder() {
        
    }
    
}

extension HomeScrollPageViewController: MenuItemViewDelegate {
    
    func tapMenuWithIndex(index: Int) {
        forbidTouchToAdjustPosition = true
        guard currentIndex != index else {
            return
        }
        currentIndex = index
        menuView.moveToCurrentIndex(currentIndex)
        reloadControllersWithNewData(data: channelData, index: index)
    }
    
    func showExtraView() {
        setRightBarMaskViewData()
        scrollView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: screenWidth, height: screenHeight - menuView.frame.maxY)
        //view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        headerView.isEdit = false
        UIView.animate(withDuration: 0.4, animations: {
            self.actionCanDoWhenShowExtraView()
        }, completion: nil)
        collectView.channelData = channelData
        collectView.show(index: currentIndex) {
            UIView.animate(withDuration: 0.4, animations: {
                self.menuView.alpha = CGFloat(1)
            }, completion: nil)
        }
    }
}

extension HomeScrollPageViewController: MoveViewDelegate {
    
    func didFinishWithDatas(datas: [String], index: Int, channel: [CategoryBarEntity]) {
        UIView.animate(withDuration: 0.4, animations: {[unowned self] in
            self.actionCanDoWhenHideExtraView()
            }, completion: nil)
        scrollView.frame = CGRect(x: 0, y: menuView.frame.maxY, width: screenWidth, height: screenHeight - menuView.frame.maxY)
        //view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        guard index < channel.count else {
            currentIndex = 0
            forbidTouchToAdjustPosition = true
            return
        }
        channelData = channel
        setupTitles()
        setScrollViewContentSize()
        currentIndex = index
        forbidTouchToAdjustPosition = true
        menuView.reloadTitlesWithNewTitles(titles, data: channel, index: currentIndex)
        reloadControllersWithNewData(data: channelData, index: index)
    }
    
    func handleLongGesture() {
        self.collectView.clickDeleteButton(isLongPress: true)
        self.headerView.isEdit = true
    }
}

extension HomeScrollPageViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        historyX = scrollView.contentOffset.x
        previousX = scrollView.contentOffset.x
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
            if willToIndex >= titles.count {
                willToIndex = titles.count - 1
                return
            }
        } else {
            willToIndex = Int(floor(scrollPercent))
            currentIndex = willToIndex + 1
            if currentIndex >= titles.count {
                currentIndex = titles.count - 1
                return
            }
            percent = 1 - percent
        }
        historyX = scrollView.contentOffset.x
        let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        menuView.moveToCurrentIndex(index)
        menuView.adjustUIWithPercent(percent, oldIndex: currentIndex, currentIndex: willToIndex)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        if previousX != scrollView.contentOffset.x && abs(previousX - scrollView.contentOffset.x) == scrollView.frame.width {
            scrollToNext(index: index)
        } else {
            currentIndex = index
            if index < channelData.count {
                reloadControllersWithNewData(data: channelData, index: index)
            }
        }
        menuView.moveToCurrentIndex(index)
        currentIndex = index
        updateScollsToTopProperty()
    }
    
}

extension HomeScrollPageViewController {
    
    // 点击title时对VC的操作
    fileprivate func clickAndMoveControllerPosition(index: Int) {
        if !channelData.isEmpty {
            if index + Type.current.rawValue < channelData.count {
                let model = channelData[index + Type.current.rawValue]
                insertControllerToScrollView(vc: currentVC, model: model, type: .current)
            }
            if index + Type.previous.rawValue >= 0 && index + Type.previous.rawValue < channelData.count {
                let model = channelData[index + Type.previous.rawValue]
                insertControllerToScrollView(vc: previousVC, model: model, type: .previous)
            }
            if index + Type.next.rawValue < channelData.count {
                let model = channelData[index + Type.next.rawValue]
                insertControllerToScrollView(vc: nextVC, model: model, type: .next)
            }
            scrollerToMargin(index: index)
        } else {
            if index == 0 {
                nextVC = currentVC
                currentVC = previousVC
                previousVC = nil
            } else if index == 1 {
                previousVC = currentVC
                currentVC = nextVC
                nextVC = nil
            }
        }
    }
    
    // 滑动时对VC的操作
    fileprivate func scrollToNext(index: Int) {
        if !channelData.isEmpty && index < channelData.count {
            if index < currentIndex {
                // 向左滑
                removeViewController(controller: nextVC)
                nextVC = currentVC
                currentVC = previousVC
                currentIndex = index
                previousVC = nil
                if index + Type.previous.rawValue >= 0 && index + Type.previous.rawValue < channelData.count {
                    let model = channelData[index + Type.previous.rawValue]
                    insertControllerToScrollView(vc: previousVC, model: model, type: .previous)
                }
            } else if index > currentIndex {
                // 向右滑
                removeViewController(controller: previousVC)
                previousVC = currentVC
                currentVC = nextVC
                currentIndex = index
                nextVC = nil
                if index + Type.next.rawValue < channelData.count {
                    let model = channelData[index + Type.next.rawValue]
                    insertControllerToScrollView(vc: nextVC, model: model, type: .next)
                }
            }
            scrollerToMargin(index: index)
            clickAndMoveControllerPosition(index: index)
        } else {
            // channelData 为空
            if index < currentIndex {
                nextVC = currentVC
                currentVC = previousVC
                previousVC = nil
            } else if index > currentIndex {
                previousVC = currentVC
                currentVC = nextVC
                nextVC = nil
            }
        }
    }
    
    // 滑动到边缘
    fileprivate func scrollerToMargin(index: Int) {
        if index == 0 {
            removeViewController(controller: previousVC)
            previousVC = nil
        } else if index == channelData.count - 1 {
            removeViewController(controller: nextVC)
            nextVC = nil
        }
    }

    // 创建VC，指定指针
    fileprivate func insertControllerToScrollView(vc: UIViewController?, model: CategoryBarEntity, type: Type) {
        var tmpVC: UIViewController?
        
        if let controller = vc {
            // VC是否是不同的
            if !isSameViewController(controller: controller, model: model) {
                removeViewController(controller: controller)
                tmpVC = setupViewController(model: model, type: type)
                addViewController(controller: tmpVC, type: type)
            } else {
                let index: CGFloat = CGFloat(currentIndex + type.rawValue)
                controller.view.frame = CGRect(x: index * screenWidth, y: 0, width: screenWidth, height: scrollView.frame.height)
                tmpVC = controller
            }
        } else {
            // 无前一个，创建
            tmpVC = setupViewController(model: model, type: type)
            addViewController(controller: tmpVC, type: type)
        }
        if let controller = tmpVC {
            switch type {
            case .previous:
                previousVC = controller
            case .current:
                currentVC = controller
            case .next:
                nextVC = controller
            }
        }
    }
    
    // 判断是否为相同的VC
    fileprivate func isSameViewController(controller: UIViewController, model: CategoryBarEntity) -> Bool {
        if let vc = controller as? ChildViewController {
            if vc.categoryId == model.categoryId {
                return true
            }
        }
        return false
    }
    
    fileprivate func setupViewController(model: CategoryBarEntity, type: Type) -> UIViewController? {
        switch type {
        case .previous:
            previousVC = nil
        case .current:
            currentVC = nil
        case .next:
            nextVC = nil
        }
        var controller: UIViewController?
        controller = ChildViewController()
        if let vc = controller as? ChildViewController {
            vc.title = model.name
            vc.categoryId = model.categoryId
            vc.categoryData = model
        }
        return controller
    }
    
    func addViewController(controller: UIViewController?, type: Type) {
        guard let controller = controller else {
            return
        }
        let index: CGFloat = CGFloat(currentIndex + type.rawValue)
        controller.view.frame = CGRect(x: index * screenWidth, y: 0, width: screenWidth, height: scrollView.frame.height)
        addChild(controller)
        controller.didMove(toParent: self)
        scrollView.addSubview(controller.view)
    }
    
    func removeViewController(controller: UIViewController?) {
        guard let controller = controller else {
            return
        }
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }

}

class HeaderView: UIView {
    
    fileprivate var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.text = "切换频道"
        return label
    }()
    
    fileprivate var deleteButton: UIButton = {
        let button = UIButton()
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 11
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitle("编辑", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        return button
    }()
    
    fileprivate var extraButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_nav_close_menu"), for: .normal)
        btn.setTitleColor(UIColor.gray, for: .normal)
        return btn
    }()
    
    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        //layer.colors = [BasicConst.Color.Color_83C3FF.cgColor, BasicConst.Color.Color_2E79F4.cgColor]
        layer.frame = CGRect(x: 0, y: 0, width: 57, height: 22)
        layer.cornerRadius = 11
        return layer
    }()
    
    var  isEdit: Bool = false {
        didSet {
            deleteButton.setTitleColor(UIColor.black, for: .normal)
            deleteButton.layer.borderColor = UIColor.black.cgColor
            if isEdit {
                deleteButton.setTitle("完成", for: .normal)
                titleLabel.text = "拖动排序"
            } else {
                deleteButton.setTitle("编辑", for: .normal)
                titleLabel.text = "切换频道"
            }
        }
    }
    var didClickExtraButton: (() -> Void)?
    var didClickDeleteButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        addSubview(titleLabel)
        addSubview(deleteButton)
        addSubview(extraButton)
        deleteButton.addTarget(self, action: #selector(self.deleteAction), for: .touchUpInside)
        extraButton.addTarget(self, action: #selector(self.extraAction), for: .touchUpInside)
        deleteButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc func deleteAction() {
        didClickDeleteButton?()
    }
    
    @objc func extraAction() {
        didClickExtraButton?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 20, y: 2.5, width: 80, height: 40)
        extraButton.frame = CGRect(x: bounds.size.width - 41, y: 0, width: 32, height: bounds.size.height)
        deleteButton.frame = CGRect(x: bounds.size.width - 113, y: (bounds.size.height - 22) / 2, width: 57, height: 22)
    }
    
}
