//
//  MiddleSelectViewCell.swift
//  Client
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import UIKit

class MiddleSelectViewCell: UICollectionViewCell {
    static let cellHeight: CGFloat = 50
    fileprivate let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = BasicConst.Color.Color_E7E7E7
        return view
    }()

    var systemButton: SelectButton = {
        let button = SelectButton()
        button.setTitle("默认频道", for: .normal)
        return button
    }()
    
    var industryButton: SelectButton = {
        let button = SelectButton()
        button.setTitle("行业频道", for: .normal)
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = BasicConst.Color.Color_4F5054
        label.font = BasicConst.Font.systemFont16
        label.text = "点击添加更多频道"
        return label
    }()

    var didClickSystemClosure: (() -> Void)?
    var didClickIndustryClosure: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addSubview(systemButton)
//        addSubview(industryButton)
//        systemButton.isSelected = true
//        industryButton.isSelected = false
//        systemButton.addTarget(self, action: #selector(clickSystem), for: .touchUpInside)
//        industryButton.addTarget(self, action: #selector(clickIndustry), for: .touchUpInside)
//        systemButton.sizeToFit()
//        systemButton.bottom = MiddleSelectViewCell.cellHeight - Constants.Layout.onePixel
//        systemButton.right = (Constants.Layout.screenWidth - 40) / 2 - 20
//        industryButton.sizeToFit()
//        industryButton.left = (Constants.Layout.screenWidth - 40) / 2 + 20
//        industryButton.bottom = systemButton.bottom
        addSubview(lineView)
        addSubview(titleLabel)
        titleLabel.sizeToFit()
        titleLabel.left = 0
        titleLabel.width = width
        titleLabel.bottom = MiddleSelectViewCell.cellHeight - 8
        lineView.left = 0
        lineView.height = BasicConst.Layout.onePixel
        lineView.width = width
        lineView.bottom = MiddleSelectViewCell.cellHeight
    }
    
    func clickSystem() {
        systemButton.isSelected = true
        industryButton.isSelected = false
        didClickSystemClosure?()
    }
    
    func clickIndustry() {
        industryButton.isSelected = true
        systemButton.isSelected = false
        didClickIndustryClosure?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum SelectChannelType {
    case system
    case industry
}
