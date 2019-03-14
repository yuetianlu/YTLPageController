//
//  CategoryManager.swift
//  Client
//
//  Created by yuetianlu on 2019/3/14.
//  Copyright © 2019年 yuetianlu. All rights reserved.
//

import Foundation

class CategoryManager {
    
    static var manager: CategoryManager {
        struct StructWrapper {
            static var instance = CategoryManager()
        }
        return StructWrapper.instance
    }
    var totalChannelData: [CategoryBarEntity] = [CategoryBarEntity]()
    var totalDic: [Int: CategoryBarEntity] = [:]
    
//    func compareData(oldData: [CategoryBarEntity], newData: [CategoryBarEntity]) -> ([CategoryBarEntity], Bool) {
//        let nowResult = deleteOldChannelData(oldData: oldData, newData: newData)
//        let result = updateTitle(newData: newData, oldData: nowResult.0)
//        let needRefresh = result.1 || nowResult.1
//        return (result.0, needRefresh)
//    }
    
    // 更新本地数据的信息
//    func updateTitle(newData: [CategoryBarEntity], oldData: [CategoryBarEntity]) -> ([CategoryBarEntity], Bool) {
//        var oldData: [CategoryBarEntity] = oldData
//        var needRefresh = false
//        var dic: [Int: CategoryBarEntity] = [:]
//        for entity in newData {
//            if let id = entity.categoryId {
//                dic[id] = entity
//            }
//        }
//        for (index, model) in oldData.enumerated() {
//            var entity: CategoryBarEntity = model
//            if let id = entity.categoryId, let item = dic[id] {
//                if entity.mark != nil {
//                    if entity.publishedAt != item.publishedAt {
//                        if let id = entity.categoryId {
//                            ChannelReadState.markAsUnReadForNewsID(id)
//                        }
//                        entity.publishedAt = item.publishedAt
//                        needRefresh = true
//                    }
//                    if item.isHot != entity.isHot {
//                        entity.mark = item.mark
//                        needRefresh = true
//                    }
//                } else {
//                    entity.mark = item.mark
//                    entity.publishedAt = item.publishedAt
//                    needRefresh = true
//                }
//                if let newName = item.name, let oldName = entity.name, newName != oldName {
//                    entity.name = newName
//                    needRefresh = true
//                }
//                oldData[index] = entity
//            }
//        }
//        return (oldData, needRefresh)
//    }
    
    /// 删除oldData中已下线的数据
    ///
    /// - Parameters:
    ///   - oldData: 从数据库中取到的数据
    ///   - newData: 从网络获取的数据
    /// - Returns: （移除下线频道的老数据，是否需要刷新）
//    fileprivate func deleteOldChannelData(oldData: [CategoryBarEntity], newData: [CategoryBarEntity]) -> ([CategoryBarEntity], Bool) {
//        var oldDatas: [CategoryBarEntity] = oldData
//        var needRefresh = false
//        var dic: [Int: CategoryBarEntity] = [:]
//        for entity in newData {
//            if let id = entity.categoryId {
//                dic[id] = entity
//            }
//        }
//        for entity in oldData {
//            if let item = oldDatas.first(where: { (item) -> Bool in
//                return item.categoryId == entity.categoryId
//            }), let index = oldDatas.index(of: item), let id = entity.categoryId {
//                if dic[id] == nil {
//                    needRefresh = true
//                    ChannelReadState.markAsUnReadForNewsID(id)
//                    oldDatas.remove(at: index)
//                }
//            }
//        }
//        return (oldDatas, needRefresh)
//    }
    
    
    /// 在老频道数据中添加新增频道
    ///
    /// - Parameters:
    ///   - oldData: 本地数据
    ///   - newData: 服务端数据
    /// - Returns: 拼接的完整数据
//    func insertNewCannel(oldData: [CategoryBarEntity], newData: [CategoryBarEntity]) -> [CategoryBarEntity] {
//        // 再插入新增的频道
//        var oldData: [CategoryBarEntity] = oldData
//        for (index, item) in newData.enumerated() {
//            if !oldData.contains(item) {
//                if oldData.isEmpty {
//                    oldData.append(item)
//                } else {
//                    oldData.insert(item, at: index)
//                }
//            }
//        }
//        return oldData
//    }
    
//    func setHotTagWithData(totalData: [CategoryBarEntity], type: ChannelType = .system) {
//        func setUserDefaultValue() {
//            if type == .system {
//                UserDefaultManager.manager.hasNewsChannelRecentlyDays = true
//            } else {
//                UserDefaultManager.manager.hasNewsVCChannelRecentlyDays = true
//            }
//        }
//
//        var dic: [Int: CategoryBarEntity] = [:]
//        var data: [CategoryBarEntity] = [CategoryBarEntity]()
//        if type == .system {
//            let totalResult = DatabaseManager.manager.retrieveObjects(ChannelTotalEntity.self)
//            if let channelEntity = totalResult?.first, let datas = channelEntity.entityValue {
//                data = datas
//            }
//        } else {
//            let totalResult = DatabaseManager.manager.retrieveObjects(ChannelVCTotalEntity.self)
//            if let channelEntity = totalResult?.first, let datas = channelEntity.entityValue {
//                data = datas
//            }
//        }
//        if !data.isEmpty {
//            for entity in data {
//                if let id = entity.categoryId {
//                    dic[id] = entity
//                }
//            }
//            if type == .system {
//                self.totalDic = dic
//            } else {
//                self.totalVCDic = dic
//            }
//
//            for entity in totalData {
//                // 新上频道
//                if let id = entity.categoryId, dic[id] == nil, entity.isNew {
//                    setUserDefaultValue()
//                    break
//                }
//                // 先下线后重新上线
//                if let id = entity.categoryId, let model = dic[id], entity.isNew, model.publishedAt != entity.publishedAt {
//                    setUserDefaultValue()
//                    break
//                }
//
//                // 先设热门频道后发布
//                if let id = entity.categoryId, dic[id] == nil, entity.isHot {
//                    setUserDefaultValue()
//                    break
//                }
//
//                // 先发布后设成热门频道
//                if let id = entity.categoryId, let model = dic[id], !model.isHot, entity.isHot {
//                    setUserDefaultValue()
//                    break
//                }
//
//                // 先上线再下线不展示红点
//                if let id = entity.categoryId, let ID = totalData.last?.categoryId, id == ID {
//                    if type == .system {
//                        UserDefaultManager.manager.hasNewsChannelRecentlyDays = false
//                    } else {
//                        UserDefaultManager.manager.hasNewsVCChannelRecentlyDays = false
//                    }
//                }
//            }
//        } else {
//            for entity in totalData {
//                if entity.isNew || entity.isHot {
//                    setUserDefaultValue()
//                    break
//                }
//            }
//        }
//    }
    
    func channelListData(completion: @escaping (([CategoryBarEntity]) -> Void)) {
        var data: [CategoryBarEntity] = [CategoryBarEntity]()
        let titles: [String] = ["关注", "推荐", "视频", "音频", "医疗", "教育", "金融", "科技", "区块链", "生活", "热榜", "职场", "深度", "人物", "时尚", "城市", "热闻", "风尚", "出行", "支付", ]
        for (index, item) in titles.enumerated() {
            var model = CategoryBarEntity()
            model.categoryId = index + 1
            model.name = item
            data.append(model)
        }
        completion(data)
//        var oldData: [CategoryBarEntity] = [CategoryBarEntity]()
//        var newData: [CategoryBarEntity] = [CategoryBarEntity]()
//        _ = NetworkManager.manager.request(CategoryBarAPI.categoryBar(type: .system), success: { (result: ListResponse <CategoryBarEntity>,originString: String?) in
//            guard result.code == 0, let data = result.data, !data.isEmpty else {
//                SwiftyBeaver.error("获取频道异常：code=\(result.code),data=\(originString ?? "")")
//                return
//            }
//            let categoryCountFromServer = data.count
//            let completionWithLog = {(data: [CategoryBarEntity],localData: String?) in
//                //处理后数据为空
//                if data.count < categoryCountFromServer {
//                    SwiftyBeaver.error("频道数据处理异常，originString:\(originString ?? ""),localString:\(localData ?? "")")
//                }
//                completion(data)
//            }
//            self.totalChannelData = data
//            newData = data
//            self.setHotTagWithData(totalData: data)
//            let result = DatabaseManager.manager.retrieveObjects(ChannelEntity.self)
//            if let channelEntity = result?.first, let data = channelEntity.entityValue {
//                oldData = data
//                if UserDefaultManager.object(forKey: UserDefaultsKeys.Home.didChangeChannelListOrder, defaultValue: false) {
//                    let result = self.compareData(oldData: oldData, newData: newData)
//                    let datas = self.setOrderAndDatas(data: result.0)
//                    if result.1 || datas.1 {
//                        completionWithLog(datas.0, channelEntity.JSONString)
//                    }
//                } else {
//                    // 未调整顺序
//                    let result = self.updateIndex(data: newData)
//                    if result.0 != oldData {
//                        let datas = self.setOrderAndDatas(data: result.0)
//                        completionWithLog(datas.0,channelEntity.JSONString)
//                    }
//                }
//            } else {
//                // 没有缓存
//                let datas = self.setOrderAndDatas(data: newData)
//                completionWithLog(datas.0,nil)
//            }
//        }, failure: { (error) in
//            let totalResult = DatabaseManager.manager.retrieveObjects(ChannelTotalEntity.self)
//            if let channelEntity = totalResult?.first, let datas = channelEntity.entityValue {
//                self.totalChannelData = datas
//            }
//        })
    }
    
//    func setOrderAndDatas(data: [CategoryBarEntity]) -> ([CategoryBarEntity], Bool) {
//        var datas = data
//        let result = updateIndex(data: datas)
//        datas = readStateTransform(result.0)
//        if !datas.isEmpty {
//            saveChannelListData(data: datas)
//        }
//        return (datas, result.1)
//    }
    
    // 关注和推荐的数据位置固定
//    func updateIndex(data: [CategoryBarEntity]) -> ([CategoryBarEntity], Bool) {
//        var datas: [CategoryBarEntity] = data
//        var needRefresh = false
//        if datas.count >= 2 {
//            let model = datas[0]
//            let entity = datas[1]
//            if let key = model.key, key == ChannelKey.dynamic.rawValue, let recommendKey = entity.key, recommendKey == ChannelKey.recommend.rawValue {
//                return (datas, needRefresh)
//            }
//        }
//        var dynamic: Bool = false
//        var recommend: Bool = false
//        var dynamicModel: CategoryBarEntity?
//        var recommendmodel: CategoryBarEntity?
//
//        for entity in data {
//            if let key = entity.key, key == ChannelKey.dynamic.rawValue, let num = datas.index(of: entity) {
//                datas.remove(at: num)
//                dynamic = true
//                dynamicModel = entity
//            }
//            if let key = entity.key, key == ChannelKey.recommend.rawValue, let num = datas.index(of: entity) {
//                datas.remove(at: num)
//                recommend = true
//                recommendmodel = entity
//            }
//
//            if dynamic && recommend {
//                break
//            }
//        }
//
//        if let recommendEntity = recommendmodel {
//            needRefresh = true
//            datas.insert(recommendEntity, at: 0)
//        }
//
//        if let dynamicEntity = dynamicModel {
//            needRefresh = true
//            datas.insert(dynamicEntity, at: 0)
//        }
//
//        return (datas, needRefresh)
//    }
    
//    fileprivate func saveChannelListData(data: [CategoryBarEntity]) {
//
//        DatabaseManager.manager.deleteObjects({ () -> Results<ChannelEntity>? in
//            return DatabaseManager.manager.retrieveObjects(ChannelEntity.self)
//        }, completion: nil)
//
//        let entity = ChannelEntity()
//        entity.JSONString = data.toJSONString()
//        DatabaseManager.manager.saveObjects({ () -> [ChannelEntity] in
//            return [entity]
//        }, completion: {
//
//        })
//    }
//
//    func updateChannelListData(data: [CategoryBarEntity]) {
//        saveChannelListData(data: data)
//    }
    
    // 所有的频道数据
//    func saveChannelTotalListData() {
//
//        DatabaseManager.manager.deleteObjects({ () -> Results<ChannelTotalEntity>? in
//            return DatabaseManager.manager.retrieveObjects(ChannelTotalEntity.self)
//        }, completion: nil)
//
//        let entity = ChannelTotalEntity()
//        entity.JSONString = totalChannelData.toJSONString()
//        DatabaseManager.manager.saveObjects({ () -> [ChannelTotalEntity] in
//            return [entity]
//        }, completion: {
//
//        })
//    }
    
//    func readStateTransform(_ items: [CategoryBarEntity]) -> [CategoryBarEntity] {
//        // 设置已读状态
//        return items.map({ (item) -> CategoryBarEntity in
//            var copy = item
//            if let ID = item.categoryId {
//                copy.isRead = ChannelReadState.isReadForNewsID(ID)
//            }
//            return copy
//        })
//    }
    
    // 获取当前频道位置  返回参数为（线上是否有此频道、是否需要刷新、此频道位置）
//    func getAnyChannel(_ categoryId: Int, data: [CategoryBarEntity]) -> ChannelInfo {
//        var channelInfo = ChannelInfo()
//        guard !data.isEmpty else {
//            return channelInfo
//        }
//        if totalDic.isEmpty {
//            var dic: [Int: CategoryBarEntity] = [:]
//            for entity in data {
//                if let id = entity.categoryId {
//                    dic[id] = entity
//                }
//            }
//            totalDic = dic
//        }
//        let item = totalDic[categoryId]
//        // 如果线上存在此频道
//        guard let currentEntity = item else {
//            return channelInfo
//        }
//        channelInfo.existOnLine = true
//        for (index, entity) in data.enumerated() {
//            if let id = entity.categoryId, id == categoryId {
//                channelInfo.existInLocal = true
//                channelInfo.index = index
//                break
//            }
//        }
//        if !channelInfo.existInLocal {
//            var newData = data
//            newData.append(currentEntity)
//            channelInfo.index = newData.count - 1
//            channelInfo.newData = newData
//            saveChannelListData(data: newData)
//        }
//        return channelInfo
//    }
    
}

