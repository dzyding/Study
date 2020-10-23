//
//  TopicDetailModel.swift
//  PPBody
//
//  Created by Nathan_he on 2018/7/11.
//  Copyright © 2018年 Nathan_he. All rights reserved.
//

import Foundation

class TopicDetailModel: NSObject
{
        
    var dataTopic = [[String:Any]]()
    {
        didSet{
            if dataTopic.count > oldValue.count && dataTopic.count != 0
            {
                print("collectionview reload")
                
                var paths = [IndexPath]()
                
                let num = self.collectionview?.numberOfItems(inSection: 0) ?? 0

                
                for item in oldValue.count...dataTopic.count-1
                {
                    if item >= num {
                       paths.append(IndexPath(row: item, section: 0))
                    }
                }
//                
//                print("oldValue",oldValue.count)
//                print("dataTopic",dataTopic.count)
//                print("numberOfItems",self.collectionview?.numberOfItems(inSection: 0) ?? 0)
            
                if paths.count > 0
                {
                    self.collectionview?.insertItems(at: paths)
                }
            }
        }
    }
    
    weak var collectionview:UICollectionView?
    
    var count:Int!{
        return dataTopic.count
    }
    
    func removeAll()
    {
        self.dataTopic.removeAll()
    }
    
    func appendArray(_ list:[[String:Any]])
    {
        self.dataTopic.append(contentsOf: list)
        self.collectionview?.reloadData()
    }
    
    func indexObjec(_ index: Int) -> [String:Any]
    {
        return self.dataTopic[index]
    }
    
    //点赞后修改数据体
    func supportForIndex(_ index: Int, isSelect: Bool)
    {
        var dic = self.dataTopic[index]
        
        if (dic["isSupport"] as? Int) != nil
        {
            dic["isSupport"] = isSelect ? 1 : 0
        }
        
        var supportNum = dic["supportNum"] as! Int
        
        if isSelect
        {
            supportNum += 1
        }else{
            supportNum -= 1
        }
        dic["supportNum"] = supportNum
        
        self.dataTopic[index] = dic
    }
    
    //评论数量+1
    func commentForIndex(_ index: Int)
    {
        var dic = self.dataTopic[index]
        var commentNum = dic["commentNum"] as! Int

        commentNum += 1
        dic["commentNum"] = commentNum
        
        self.dataTopic[index] = dic
    }
    
}
