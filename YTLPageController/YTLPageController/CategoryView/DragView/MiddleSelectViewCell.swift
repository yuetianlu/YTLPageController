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
        view.backgroundColor = UIColor.gray
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
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "点击添加更多频道"
        return label
    }()

    var didClickSystemClosure: (() -> Void)?
    var didClickIndustryClosure: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(lineView)
        addSubview(titleLabel)
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - 8)
        lineView.frame = CGRect(x: 0, y: self.frame.height - 1, width: self.frame.width, height: 1)
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
