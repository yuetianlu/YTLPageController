//
//  SelectButton.swift
//  Client
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//


import UIKit

class SelectButton: UIButton {

    fileprivate let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = BasicConst.Color.Color_4285F4
        view.layer.cornerRadius = 2
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            lineView.isHidden = !isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lineView)
        setTitleColor(BasicConst.Color.Color_262626, for: .normal)
        setTitleColor(BasicConst.Color.Color_4285F4, for: .selected)
        titleLabel?.font = BasicConst.Font.systemFont16
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineView.frame = CGRect(x: 0, y: height - 2, width: width, height: 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
