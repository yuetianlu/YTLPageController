//
//  CategoryCollectionViewCell.swift
//  collectionView
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let categoryCellWidth: CGFloat = (UIScreen.main.bounds.width - 34 - 4 * 3) / 4
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.08)
            titleLabel.font = BasicConst.Font.systemFont14
            titleLabel.layer.cornerRadius = 4
            titleLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var iconButton: CustomeHitAreaButton! {
        didSet {
            iconButton.hitTestEdgeInsets = UIEdgeInsets(top: -30, left: -CategoryCollectionViewCell.categoryCellWidth + 30, bottom: -35, right: -20)
        }
    }
    
    @IBOutlet weak var tagImageView: UIImageView!
    
    let borderLayer = CAShapeLayer.init()
    var model: CategoryBarEntity?
    var didClickDeleteClosure: ((CategoryBarEntity) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func deleteButtonClick(_ sender: Any) {
        if let model = model {
            didClickDeleteClosure?(model)
        }
    }
    
    func setData(_ num: String, status: Bool, index: Int, currentIndex: Int, style: CollectStyle) {
        iconButton.isHidden = true
        titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        titleLabel.textColor = BasicConst.Color.Color_262626
        if index == currentIndex {
            titleLabel.textColor = BasicConst.Color.Color_F95355
        }
        if status && style.editDelete {
            iconButton.isHidden = false
            tagImageView.isHidden = true
        }
        for item in style.fixItems where index == item {
            iconButton.isHidden = true
            titleLabel.backgroundColor = UIColor.clear
        }
        titleLabel.text = "\(num)"
    }
    
    func setData(_ text: String) {
        iconButton.isHidden = true
        titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        titleLabel.textColor = BasicConst.Color.Color_262626
        titleLabel.text = text
        tagImageView.isHidden = true
    }
    
    func setHotImageView(data: CategoryBarEntity) {
        if data.isHot {
            tagImageView.image = UIImage(named: "tag_hot")
            tagImageView.isHidden = false
        } else if !data.isRead, data.isNew {
            tagImageView.image = UIImage(named: "tag_new")
            tagImageView.isHidden = false
        } else {
            tagImageView.isHidden = true
        }
    }
    
    func setBackgroundView(index: Int, style: CollectStyle) {
        titleLabel.text = ""
        titleLabel.backgroundColor = UIColor.clear
        iconButton.isHidden = true
        let labelWidth: CGFloat = (UIScreen.main.bounds.width - 40 - 30) / 3
        let labelHeight: CGFloat = 32
        borderLayer.bounds = CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight)
        borderLayer.position = CGPoint(x: labelWidth / 2, y: labelHeight / 2)
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: labelHeight / 2).cgPath
        borderLayer.lineWidth = 1
        for item in style.fixItems where index == item {
            borderLayer.lineWidth = 0
        }
        borderLayer.lineDashPattern = [2, 1]
        borderLayer.strokeColor = BasicConst.Color.Color_999CA0.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        titleLabel.layer.addSublayer(borderLayer)
        tagImageView.isHidden = true
    }
    
    func changeLabelBackgroundWithStatus(status: Bool) {
        if status {
            titleLabel.backgroundColor = UIColor.white
        } else {
            titleLabel.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        }
    }
}
