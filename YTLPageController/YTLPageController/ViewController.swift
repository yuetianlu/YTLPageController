//
//  ViewController.swift
//  YTLPageController
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var topGuideHeight: CGFloat {
        let navH = navigationController?.navigationBar.bounds.size.height ?? 0
        let nsHeight = navH + UIApplication.shared.statusBarFrame.size.height
        return nsHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            var style = MenuStyle()
            style.showExtraOption = true
            style.changeLineViewColor = true
            style.hadTabbar = true
            style.menuTop = self.topGuideHeight
            
            CategoryManager.manager.channelListData { [weak self] (data) in
                let vc = ContainerViewController(data: data, initialIndex: 1, menuStyle: style)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }

}

