//
//  ChildViewController.swift
//  YTLPageController
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {

    var categoryId: Int = 0
    var categoryData: CategoryBarEntity = CategoryBarEntity()
    let label: UILabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)
        label.frame = CGRect(x: 0, y: 300, width: screenWidth, height: 100)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.text = categoryData.name
        
        view.backgroundColor = UIColor.randomColor
        // Do any additional setup after loading the view.
    }
}

extension UIColor {
    //返回随机颜色
    open class var randomColor:UIColor{
        get
        {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
