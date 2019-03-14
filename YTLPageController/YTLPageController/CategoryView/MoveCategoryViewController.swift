//
//  MoveCategoryViewController.swift
//  collectionView
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import UIKit

public struct CollectStyle {
    
    public var viewAlpha: CGFloat = 1
    public var editDelete: Bool = false
    public var headerY: CGFloat = 0
    public var headerHeight: CGFloat = 45
    public var viewFrame: CGRect = CGRect.zero
    public var fixItems: [Int] = [0]
    var selectType: ChannelType = .system

    public init() {
        
    }
}

class MoveCategoryViewController: UIViewController {
    
    var collectStyle: CollectStyle = CollectStyle()
    var data: [String] = ["关注", "推荐"]
    var currentIndex: Int = 0
    fileprivate var collectionView: UICollectionView?
    fileprivate var showFrame = CGRect.zero
    fileprivate var hideFrame = CGRect.zero
    fileprivate var newcell = UIView()
    fileprivate var hasNewCell: Bool = false
    fileprivate var originalIndex: IndexPath?
    fileprivate var fixRect: CGRect?
    var channelData: [CategoryBarEntity] = [CategoryBarEntity]()
    weak var delegate: MoveViewDelegate?
    var longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    var dismissClosure: (() -> Void)?
    var clickItem: Bool = true {
        didSet {
            longPressGesture.minimumPressDuration = clickItem ? 0.2:0.1
            if clickItem {
                hasNewCell = false
            }
        }
    }
    var detlaX: CGFloat = 0
    var detlaY: CGFloat = 0
    fileprivate enum SectionType {
        case topView
        case middleView
        case bottomView
    }
    fileprivate let sectionTypes: [SectionType] = [.topView, .middleView, .bottomView]
    fileprivate var hasFinished: Bool = false
    fileprivate var totalData: [CategoryBarEntity] = [CategoryBarEntity]()
    fileprivate var channelDic: [Int: CategoryBarEntity] = [:]
    fileprivate var unselectedData: [CategoryBarEntity] = [CategoryBarEntity]()
    fileprivate var totalDic: [Int: CategoryBarEntity] = [:]
    var hasChangeChannelOrder: Bool = false
    
    deinit {
        collectionView?.delegate = nil
        collectionView?.dataSource = nil
    }
    
    init(data: [String], selectIndex: Int, collectStyle: CollectStyle) {
        self.data = data
        self.currentIndex = selectIndex
        self.collectStyle = collectStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = collectStyle.viewFrame
        showFrame = CGRect(x: 0, y: collectStyle.headerY, width: collectStyle.viewFrame.width, height: collectStyle.viewFrame.height)
        view.backgroundColor = UIColor.clear

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.width, height: view.height + 90)
        self.view.addSubview(blurView)
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 253 / 255.0, green: 253 / 255.0, blue: 253 / 255.0, alpha: 0.85)
        bgView.frame = CGRect(x: 0, y: collectStyle.headerHeight, width: UIScreen.main.bounds.width, height: collectStyle.viewFrame.height - collectStyle.headerHeight)
        bgView.alpha = collectStyle.viewAlpha
        view.addSubview(bgView)
        collectionView = initCollectionView()
        collectionView?.backgroundColor = UIColor.clear
        if let collectview = collectionView {
            bgView.addSubview(collectview)
        }
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        longPressGesture.minimumPressDuration = 0.2
        collectionView?.addGestureRecognizer(longPressGesture)
    }
    
    fileprivate func initCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionview.isPagingEnabled = false
        collectionview.scrollsToTop = false
        collectionview.backgroundColor = UIColor.clear
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionview.register(MiddleSelectViewCell.self, forCellWithReuseIdentifier: "MiddleSelectViewCell")
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: collectStyle.viewFrame.height - collectStyle.headerHeight - BasicConst.Layout.adjustInsetForIPhoneX.bottom)
        return collectionview
    }
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        if let selectedIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)), selectedIndexPath.section == 0, clickItem {
            if clickItem {
                delegate?.handleLongGesture()
                clickItem = false
                collectionView?.reloadData()
            }
        } else {
            changeState(gesture)
        }

    }
    
    func changeState(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.began:
            gestureBegan(gesture)
        case UIGestureRecognizerState.changed:
            gestureChanged(gesture)
        case UIGestureRecognizerState.ended:
            gestureEnded(gesture)
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
    
    func gestureBegan(_ gesture: UIGestureRecognizer) {
        if let selectedIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)), selectedIndexPath.section == 0, !collectStyle.fixItems.contains(selectedIndexPath.item) {
            originalIndex = selectedIndexPath
            if let cell = collectionView?.cellForItem(at: selectedIndexPath), let cateCell = cell as? CategoryCollectionViewCell {
                cateCell.changeLabelBackgroundWithStatus(status: true)
                cellSelectAtIndex(cell: cateCell)
                let location = gesture.location(in: collectionView)
                detlaX = location.x - cateCell.center.x
                detlaY = location.y - cateCell.center.y
                newcell.center = CGPoint(x: location.x - detlaX, y: location.y - detlaY)
                hasNewCell = true
            }
            collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
        }
    }
    
    func gestureChanged(_ gesture: UIGestureRecognizer) {
        if !hasNewCell {
            gestureBegan(gesture)
        }
        let location = gesture.location(in: collectionView)
        newcell.center = CGPoint(x: location.x - detlaX, y: location.y - detlaY)
        if let rect = fixRect {
            if location.x > rect.maxX || location.y > rect.maxY {
                collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            }
        }
    }
    
    func gestureEnded(_ gesture: UIGestureRecognizer) {
        if let selectedIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)), let cell = collectionView?.cellForItem(at: selectedIndexPath), let cateCell = cell as? CategoryCollectionViewCell, let original = originalIndex, let originalcell = collectionView?.cellForItem(at: original), let oldCell = originalcell as? CategoryCollectionViewCell, !collectStyle.fixItems.contains(selectedIndexPath.item) {
            
            newcell.removeFromSuperview()
            oldCell.isHidden = false
            cateCell.isHidden = false
            cateCell.changeLabelBackgroundWithStatus(status: false)
            collectionView?.endInteractiveMovement()
        } else {
            newcell.removeFromSuperview()
            collectionView?.endInteractiveMovement()
            collectionView?.reloadData()
        }
    }
    
    func cellSelectAtIndex(cell: CategoryCollectionViewCell) {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            cell.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot: UIImageView = UIImageView(image: image)
        snapshot.layer.shadowOffset = CGSize(width: 2, height: 2)
        snapshot.layer.shadowOpacity = 0.3
        snapshot.layer.shadowColor = UIColor.black.cgColor
        newcell = snapshot
        collectionView?.addSubview(newcell)
        cell.isHidden = true
    }
    
    func show(index: Int, dismissClosure: @escaping (() -> Void)) {
        clickItem = true
        currentIndex = index
        hasChangeChannelOrder = false
        loadData()
        self.dismissClosure = dismissClosure
        hideFrame = CGRect(x: 0.0, y: -showFrame.size.height, width: showFrame.size.width, height: showFrame.size.height)
        UIView.animate(withDuration: 0.4, animations: {
            self.view.frame = self.showFrame
            }, completion: nil)
    }
    
    func hidden() {
        let titleOrder = data.joined(separator: ",")
        if collectStyle.selectType == .system {
            TrackManager.track(event: TrackManager.Event.click, properties: ["media_event_value": "click_column_close", "columns": "\(titleOrder)"])
        } else {
            TrackManager.track(event: TrackManager.Event.click, properties: ["media_event_value": "click_investorchannel_done", "media_column_order": "\(titleOrder)"])
        }

        if !hasFinished {
            delegate?.didFinishWithDatas(datas: data, index: currentIndex, channel: channelData)
            hasFinished = true
        }
        dismissClosure?()
        UIView.animate(withDuration: 0.4, animations: {
            self.view.frame = self.hideFrame
        }) { (_) in
            self.hasFinished = false
        }
    }
    
    func updateData(titles: [String], data: [CategoryBarEntity], index: Int) {
        channelData = data
        self.data = titles
        currentIndex = index
        collectionView?.reloadData()
    }
    
    // MARK: Action
    func clickExtraButton() {
        hidden()
    }
    
    func clickDeleteButton(isLongPress: Bool) {
        if !clickItem {
            // 点击完成
            let titleOrder = data.joined(separator: ",")
            TrackManager.track(event: TrackManager.Event.editChannel, properties: ["columns": titleOrder])
            if !channelData.isEmpty {
                if collectStyle.selectType == .system {
                    CategoryManager.manager.updateChannelListData(data: channelData)
                } else {
                    CategoryManager.manager.saveVCChannelListData(data: channelData)
                }
            }
        }
        clickItem = !clickItem
        collectionView?.reloadData()
    }
    
    fileprivate func loadData() {
        channelDic = [:]
        for entity in self.channelData {
            if let id = entity.categoryId {
                channelDic[id] = entity
            }
        }
        if collectStyle.selectType == .system {
            totalData = CategoryManager.manager.readStateTransform(CategoryManager.manager.totalChannelData)
            totalDic = CategoryManager.manager.totalDic
        } else {
            totalData = CategoryManager.manager.readStateTransform(CategoryManager.manager.totalVCChannelData)
            totalDic = CategoryManager.manager.totalVCDic
        }
        _ = NetworkManager.manager.request(CategoryBarAPI.categoryBar(type: collectStyle.selectType), success: { (result: ListResponse <CategoryBarEntity>,_) in
            if result.code == 0, let datas = result.data, !datas.isEmpty {
                if !self.channelData.isEmpty {
                    self.unselectedData.removeAll()
                    for item in datas {
                        var model = item
                        var entity: CategoryBarEntity?
                        if let id = item.categoryId, self.channelDic[id] == nil {
                            entity = self.totalDic[id]
                            if entity?.publishedAt == model.publishedAt {
                                model.isRead = entity?.isRead ?? false
                            } else {
                                ChannelReadState.markAsUnReadForNewsID(id)
                                model.isRead = false
                            }
                            self.unselectedData.append(model)
                        }
                    }
                }
                self.collectionView?.reloadData()
            } else {
                self.getSystomAndIndustoryWhenFailure()
            }
        }, failure: { (_) in
            self.getSystomAndIndustoryWhenFailure()
        })
    }
    
    fileprivate func getSystomAndIndustoryWhenFailure() {
        unselectedData.removeAll()
        for entity in totalData {
            if let id = entity.categoryId, channelDic[id] == nil {
                unselectedData.append(entity)
            }
        }
        collectionView?.reloadData()
    }
    
    fileprivate func hasChangeChannelListOrder() {
        if collectStyle.selectType == .system {
            hasChangeChannelOrder = true
            UserDefaultManager.set(true, forKey: UserDefaultsKeys.Home.didChangeChannelListOrder)
        } else {
            UserDefaultManager.set(true, forKey: UserDefaultsKeys.VC.didChangeVCChannelListOrder)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol MoveViewDelegate: NSObjectProtocol {
    func didFinishWithDatas(datas: [String], index: Int, channel: [CategoryBarEntity])
    func handleLongGesture()
}

extension MoveCategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionTypes.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sectionTypes[section] {
        case .topView:
            if channelData.isEmpty {
                return data.count
            }
            return channelData.count
        case .middleView:
            if clickItem {
                return unselectedData.isEmpty ? 0 : 1
            }
            return 0
        case .bottomView:
            return clickItem ? unselectedData.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sectionTypes[indexPath.section] {
        case .topView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            if let cell = cell as? CategoryCollectionViewCell {
                if let num = collectStyle.fixItems.last, indexPath.row == num {
                    fixRect = cell.frame
                }
                var text: String = ""
                if channelData.isEmpty {
                    text = data[indexPath.item]
                } else {
                    text = channelData[indexPath.item].name ?? ""
                    cell.model = channelData[indexPath.item]
                    cell.setHotImageView(data: channelData[indexPath.item])
                }
                cell.isHidden = false
                cell.setData(text, status: !clickItem, index: indexPath.item, currentIndex: currentIndex, style: collectStyle)
                cell.didClickDeleteClosure = { [unowned self] (entity) in
                    guard let selectIndex = self.channelData.index(of: entity) else {
                        return
                    }
                    let num = self.currentIndex - selectIndex
                    self.currentIndex = num > 0 ? self.currentIndex - 1:(num == 0 ? 0:self.currentIndex)
                    let model = self.channelData[selectIndex]
                    self.channelData.remove(at: selectIndex)
                    self.data.remove(at: selectIndex)
                    self.unselectedData.insert(model, at: 0)
                    if let name = model.name {
                        TrackManager.track(event: TrackManager.Event.editChannel, properties: ["media_type": "delete", "columnname": "\(name)"])
                    }
                    self.hasChangeChannelListOrder()
                    let selectIndexPath = IndexPath(item: selectIndex, section: 0)

                    self.collectionView?.performBatchUpdates({
                        self.collectionView?.deleteItems(at: [selectIndexPath])
                    }, completion: { (_) in
                        self.collectionView?.reloadData()
                    })
                }
            }
            return cell
        case .bottomView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath)
            if let cell = cell as? CategoryCollectionViewCell {
                let text: String = unselectedData[indexPath.item].name ?? ""
                cell.isHidden = false
                cell.setData(text)
                if !channelData.isEmpty && indexPath.item < unselectedData.count {
                    cell.setHotImageView(data: unselectedData[indexPath.item])
                }
            }
            return cell
        case .middleView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MiddleSelectViewCell", for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch sectionTypes[indexPath.section] {
        case .topView, .bottomView:
            return CGSize(width: CategoryCollectionViewCell.categoryCellWidth, height: 52)
        case .middleView:
            return CGSize(width: BasicConst.Layout.screenWidth - 40, height: MiddleSelectViewCell.cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch sectionTypes[section] {
        case .topView:
            return UIEdgeInsets(top: 25, left: 20, bottom: 25, right: 14)
        case .middleView:
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        case .bottomView:
            return UIEdgeInsets(top: 20, left: 20, bottom: 25, right: 14)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if collectionView.isEqual(collectionView) {
            hasChangeChannelListOrder()
            switch sectionTypes[sourceIndexPath.section] {
            case .topView:
                let num = data[sourceIndexPath.item]
                data.remove(at: sourceIndexPath.item)
                data.insert(num, at: destinationIndexPath.item)
                if channelData.count == data.count {
                    let entity = channelData[sourceIndexPath.item]
                    channelData.remove(at: sourceIndexPath.item)
                    channelData.insert(entity, at: destinationIndexPath.item)
                }
                if sourceIndexPath.item == currentIndex {
                    currentIndex = destinationIndexPath.item
                } else if destinationIndexPath.item == currentIndex {
                    let num = currentIndex - sourceIndexPath.item
                    self.currentIndex = num > 0 ? self.currentIndex - 1:(num == 0 ? 0:self.currentIndex + 1)
                } else {
                    if currentIndex < sourceIndexPath.item && currentIndex > destinationIndexPath.item {
                        self.currentIndex += 1
                    } else if  currentIndex > sourceIndexPath.item && currentIndex < destinationIndexPath.item {
                        self.currentIndex -= 1
                    }
                }
            default:
                return
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(collectionView) {
            switch sectionTypes[indexPath.section] {
            case .topView:
                if clickItem {
                    currentIndex = indexPath.item
                    self.hidden()
                }
            case .middleView:
                return
            case .bottomView:
                let entity = unselectedData[indexPath.item]
                if let name = entity.name {
                    unselectedData.remove(at: indexPath.item)
                    channelData.append(entity)
                    data.append(name)
                    TrackManager.track(event: TrackManager.Event.editChannel, properties: ["media_type": "add", "columnname": "\(name)"])
                }
                hasChangeChannelListOrder()
                let toIndex = IndexPath(item: channelData.count - 1, section: 0)
                if unselectedData.isEmpty {
                    collectionView.reloadData()
                } else {
                    collectionView.moveItem(at: indexPath, to: toIndex)
                }
            }
        }
    }
}
