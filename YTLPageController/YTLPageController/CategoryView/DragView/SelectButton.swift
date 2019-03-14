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
        view.backgroundColor = UIColor.red
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
        setTitleColor(UIColor.gray, for: .normal)
        setTitleColor(UIColor.red, for: .selected)
        titleLabel?.font = UIFont.systemFont(ofSize: 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineView.frame = CGRect(x: 0, y: self.frame.height - 2, width: self.frame.width, height: 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
