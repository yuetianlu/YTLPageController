//
//  MenuScrollView.swift
//  collectionView
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import UIKit

class MenuScrollView: UIView {
    
    var menuStyle: MenuStyle
    var titles: [String]
    fileprivate let screenWidth = UIScreen.main.bounds.width
    fileprivate var lineViewY: CGFloat = 0
    fileprivate var labelArray: [CustomLabel] = [CustomLabel]()
    fileprivate var titlesLabelWidth: [CGFloat] = [CGFloat]()
    fileprivate var scrollWidth: CGFloat = 0
    fileprivate var currentIndex = 0
    fileprivate var beforeIndex = 0
    fileprivate var scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.scrollsToTop = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        scrollview.bounces = false
        return scrollview
    }()
    fileprivate var extraButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_nav_menu"), for: .normal)
        return btn
    }()
    var rightBarMaskView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.image = UIImage(named: "Rectangle")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        return view
    }()
    fileprivate var lineView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        return view
    }()
    weak var delegate: MenuItemViewDelegate?
    fileprivate var channelData: [CategoryBarEntity] = [CategoryBarEntity]()
    
    fileprivate let reddot: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ic_nav_point")
        return view
    }()
    
    fileprivate let reddotDemension: CGFloat = 8.0
    fileprivate let reddotBorderWidth: CGFloat = 2.0
    fileprivate var scrollerviewContentWidth: CGFloat = 0
    
    init(frame: CGRect, menuStyle: MenuStyle, titles: [String]) {
        self.menuStyle = menuStyle
        self.titles = titles
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.frame = CGRect(x: 0, y: menuStyle.menuTop, width: screenWidth, height: menuStyle.menuHeight)
        self.lineViewY = bounds.size.height - menuStyle.lineViewHeight - 7
        addSubview(scrollView)
        extraButton.addTarget(self, action: #selector(self.clickExtraAction), for:.touchUpInside)
        constructLabels()
        setLabelPosition(currentIndex)
        addSubview(rightBarMaskView)
        rightBarMaskView.addSubview(extraButton)
        rightBarMaskView.addSubview(reddot)
        reddot.isHidden = true
        rightBarMaskView.isHidden = !menuStyle.showExtraOption
    }
    
    func setRightBarMaskViewUpdateState(_ hasNew: Bool) {
        reddot.isHidden = !hasNew
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var extraWidth: CGFloat = 0
        if menuStyle.showExtraOption {
            rightBarMaskView.isHidden = false
            extraWidth = 50
            rightBarMaskView.frame = CGRect(x: screenWidth - extraWidth, y: 0, width: extraWidth, height: bounds.size.height)
            extraButton.frame = CGRect(x: 0, y: 0, width: extraWidth, height: bounds.size.height)
            var reddotFrame = reddot.frame
            reddotFrame.origin.x = rightBarMaskView.frame.width - reddotDemension - 10
            reddotFrame.origin.y = 10
            reddotFrame.size.width = reddotDemension
            reddotFrame.size.height = reddotDemension
            reddot.frame = reddotFrame
            scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth - 30, height: bounds.size.height)
        } else {
            rightBarMaskView.frame = CGRect.zero
            extraButton.frame = CGRect.zero
            scrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bounds.size.height)
        }
    }
    
    // MARK: Action
    
    @objc func titleLabelClick(_ tap: UITapGestureRecognizer) {
        guard (tap.view as? UILabel) != nil else {
            return
        }
        if let view = tap.view as? CustomLabel {
            currentIndex = labelArray.index(of: view) ?? 0
        }
        moveToCurrentIndex(currentIndex)
        delegate?.tapMenuWithIndex(index: currentIndex)
    }
    
    @objc func clickExtraAction() {
        delegate?.showExtraView()
    }
    
}

extension MenuScrollView {
    
    fileprivate func constructLabels() {
        for title in titles {
            let label = CustomLabel()
            label.text = title
            label.textColor = menuStyle.normalTitleColor
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: menuStyle.titleFontSize)
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.titleLabelClick(_:)))
            label.addGestureRecognizer(tap)
            let size = (title as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font], context: nil)
            titlesLabelWidth.append(size.width)
            labelArray.append(label)
            scrollView.addSubview(label)
        }
        if menuStyle.showLineView {
            lineView.backgroundColor = menuStyle.lineViewColor
            scrollView.addSubview(lineView)
        }
    }
    
    //设置label的位置
    fileprivate func setLabelPosition(_ index: Int) {
        guard index < labelArray.count else {
            return
        }
        var titleX: CGFloat = 0
        let titleY: CGFloat = 0
        var titleW: CGFloat = 0
        scrollWidth = menuStyle.titleMargin
        let indexLabel = labelArray[index]
        if menuStyle.setCenterLayout {
            // 多于两个title平均分布
            let itemWidth = screenWidth / CGFloat(labelArray.count)
            for (index, label) in labelArray.enumerated() {
                titleW = titlesLabelWidth[index]
                titleX = itemWidth * CGFloat(index) + (itemWidth - titleW) / 2
                label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: bounds.size.height)
                scrollWidth += titleW + menuStyle.titleMargin
            }
            
        } else {
            for (index, label) in labelArray.enumerated() {
                titleW = titlesLabelWidth[index]
                titleX = menuStyle.titleMargin
                if index != 0 {
                    let lastLabel = labelArray[index - 1]
                    titleX = lastLabel.frame.maxX + menuStyle.titleMargin
                }
                label.frame = CGRect(x: titleX, y: titleY, width: titleW, height: bounds.size.height)
                scrollWidth += titleW + menuStyle.titleMargin
            }
        }
        if menuStyle.changeTitleSize {
            indexLabel.currentTransformSx = menuStyle.titleBigScale
        }
        if menuStyle.showLineView {
            lineView.frame = CGRect(x: indexLabel.center.x - menuStyle.lineViewWidth / 2, y: lineViewY, width: menuStyle.lineViewWidth, height: menuStyle.lineViewHeight)
        }
        indexLabel.textColor = menuStyle.selectedTitleColor
        if let lastLabel = labelArray.last {
            scrollerviewContentWidth = lastLabel.frame.maxX + menuStyle.titleMargin
            scrollView.contentSize = CGSize(width: lastLabel.frame.maxX + menuStyle.titleMargin, height: 0)
        }
    }
    
}

extension MenuScrollView {
    
    // 动态改变label
    func adjustUIWithPercent(_ percent: CGFloat, oldIndex: Int, currentIndex: Int) {
        guard oldIndex < labelArray.count, currentIndex < labelArray.count else {
            return
        }
        beforeIndex = currentIndex
        let oldLabel = labelArray[oldIndex]
        let currentLabel = labelArray[currentIndex]
        oldLabel.textColor = updateColor(menuStyle.selectedTitleColor, toColor: menuStyle.normalTitleColor, percent: percent)
        currentLabel.textColor = updateColor(menuStyle.normalTitleColor, toColor: menuStyle.selectedTitleColor, percent: percent)
        let startX: CGFloat = ceil(oldLabel.center.x - menuStyle.lineViewWidth / 2)
        let endX: CGFloat = ceil(currentLabel.center.x - menuStyle.lineViewWidth / 2)
        if menuStyle.showLineView {
            if oldIndex < currentIndex {
                let detalWidth = endX - startX
                if percent <= 0.5 {
                    lineView.frame = CGRect(x: startX, y: lineViewY, width: menuStyle.lineViewWidth + detalWidth * (percent / 0.5), height: menuStyle.lineViewHeight)
                } else {
                    lineView.frame = CGRect(x: startX + detalWidth * ((percent - 0.5) / 0.5), y: lineViewY, width: menuStyle.lineViewWidth + detalWidth - detalWidth * ((percent - 0.5) / 0.5), height: menuStyle.lineViewHeight)
                }
            } else {
                let detalWidth = startX - endX
                if percent <= 0.5 {
                    lineView.frame = CGRect(x: startX - detalWidth * (percent / 0.5), y: lineViewY, width: menuStyle.lineViewWidth + detalWidth * (percent / 0.5), height: menuStyle.lineViewHeight)
                } else {
                    lineView.frame = CGRect(x: endX, y: lineViewY, width: menuStyle.lineViewWidth + detalWidth - detalWidth * ((percent - 0.5) / 0.5), height: menuStyle.lineViewHeight)
                }
            }
        }
        if menuStyle.changeLineViewColor && !menuStyle.setCenterLayout {
            var normalColor = menuStyle.lineViewColor
            var selectColor = menuStyle.lineViewColor
            normalColor = menuStyle.lineViewColors[oldIndex % menuStyle.lineViewColors.count]
            selectColor = menuStyle.lineViewColors[currentIndex % menuStyle.lineViewColors.count]
            lineView.backgroundColor = updateColor(normalColor, toColor: selectColor, percent: percent)
        }
        if menuStyle.changeTitleSize {
            let deltaScale = (menuStyle.titleBigScale - menuStyle.titleOriginalScale)
            oldLabel.currentTransformSx = menuStyle.titleBigScale - deltaScale * percent
            currentLabel.currentTransformSx = menuStyle.titleOriginalScale + deltaScale * percent
        }
    }
    
    func moveToCurrentIndex(_ currentIndex: Int) {
        guard currentIndex < labelArray.count else {
            return
        }
        let currentLabel = labelArray[currentIndex]
        if !menuStyle.setCenterLayout {
            var offsetX = currentLabel.center.x - screenWidth / 2
            if offsetX < 0 {
                offsetX = 0
            }
            var maxOffsetX = scrollView.contentSize.width - (screenWidth - extraButton.frame.size.width + menuStyle.titleMargin)
            if maxOffsetX < 0 {
                maxOffsetX = 0
            }
            if offsetX > maxOffsetX {
                offsetX = maxOffsetX
            }
            // 解决banner导航滑动卡顿问题
            UIView.animate(withDuration: 0.4, animations: {
                self.scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
            })
        }
        if menuStyle.changeLineViewColor && !menuStyle.setCenterLayout {
            lineView.backgroundColor = menuStyle.lineViewColors[currentIndex % menuStyle.lineViewColors.count]
        }
        if currentIndex == beforeIndex {
            return
        }
        if beforeIndex < labelArray.count {
            let oldLabel = labelArray[beforeIndex]
            UIView.animate(withDuration: 0.3, animations: {
                oldLabel.textColor = self.menuStyle.normalTitleColor
                currentLabel.textColor = self.menuStyle.selectedTitleColor
                if self.menuStyle.changeTitleSize {
                    oldLabel.currentTransformSx = self.menuStyle.titleOriginalScale
                    currentLabel.currentTransformSx = self.menuStyle.titleBigScale
                }
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                currentLabel.textColor = self.menuStyle.selectedTitleColor
                if self.menuStyle.changeTitleSize {
                    currentLabel.currentTransformSx = self.menuStyle.titleBigScale
                }
            })
        }
        if menuStyle.showLineView {
            lineView.frame = CGRect(x: currentLabel.center.x - menuStyle.lineViewWidth / 2, y: lineViewY, width: menuStyle.lineViewWidth, height: menuStyle.lineViewHeight)
        }
        beforeIndex = currentIndex
    }
    
    fileprivate func updateColor(_ fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromR: CGFloat = 0
        var fromG: CGFloat = 0
        var fromB: CGFloat = 0
        var fromA: CGFloat = 0
        fromColor.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        var toR: CGFloat = 0
        var toG: CGFloat = 0
        var toB: CGFloat = 0
        var toA: CGFloat = 0
        toColor.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        let currentR: CGFloat = fromR + percent * (toR - fromR)
        let currentG: CGFloat = fromG + percent * (toG - fromG)
        let currentB: CGFloat = fromB + percent * (toB - fromB)
        let currentA: CGFloat = fromA + percent * (toA - fromA)
        return UIColor(red: currentR, green: currentG, blue: currentB, alpha: currentA)
    }
    
    //刷新title
    func reloadTitlesWithNewTitles(_ labelTitles: [String], data: [CategoryBarEntity], index: Int) {
        guard labelTitles.count == data.count, index < data.count else {
            return
        }
        channelData = data
        currentIndex = index
        scrollView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        titlesLabelWidth.removeAll()
        labelArray.removeAll()
        titles = labelTitles
        constructLabels()
        setLabelPosition(index)
        moveToCurrentIndex(index)
    }
}

protocol MenuItemViewDelegate: NSObjectProtocol {
    func tapMenuWithIndex(index: Int)
    func showExtraView()
}

public struct MenuStyle {
    
    public var titleMargin: CGFloat = 23
    public var titleFontSize: CGFloat = 16
    public var titleBigScale: CGFloat = 1.3
    public let titleOriginalScale: CGFloat = 1.0
    public var normalTitleColor = UIColor.gray
    public var selectedTitleColor = UIColor.red
    public var showExtraOption: Bool = false
    public var setCenterLayout: Bool = false
    public var changeTitleSize: Bool = false
    public var showLineView: Bool = true
    public var lineViewHeight: CGFloat = 2
    public var lineViewWidth: CGFloat = 10
    public var lineViewColor: UIColor = UIColor.blue
    public var menuTop: CGFloat = 0
    public var menuHeight: CGFloat = 45
    public var hadTabbar: Bool = false
    public var lineViewColors: [UIColor] = [UIColor.red, UIColor.purple, UIColor.orange]
    public var changeLineViewColor: Bool = false
    
    public init() {
        
    }
}

open class CustomLabel: UILabel {
    /// 用来记录当前label的缩放比例
    open var currentTransformSx: CGFloat = 1.0 {
        didSet {
            transform = CGAffineTransform(scaleX: currentTransformSx, y: currentTransformSx)
        }
    }
}
