//
//  Alamofire+JsonToModel.swift
//  EFOOD7
//
//  Created by 森泓投资 on 2018/4/8.
//  Copyright © 2018年 EFOOD7. All rights reserved.
//

import Foundation
import Alamofire
//import SwiftyJSON

extension DataRequest {
    @discardableResult
    public func dzy_responseObject<T: Codable>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (T?, Error?) -> ())
        -> Self
    {
        return responseData(queue: queue, completionHandler: { (response ) in
            switch response.result {
            case .success(let data):
//                let json = JSON(data: data)
//                if let dict = json.dictionaryObject {
//                    print(dict)
//                }
                if let model = self.dataToModel(data, T.self) {
                    completionHandler(model, nil)
                }else {
                    completionHandler(nil, nil)
                }
            case .failure(let error):
                dzy_log(error)
                completionHandler(nil, error)
            }
        })
    }
    
    fileprivate func dataToModel<T: Codable>(_ jsonData: Data, _ type: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(type, from: jsonData)
            return result
        }catch {
            return nil
        }
    }
    
    fileprivate func strToModel<T: Codable>(_ jsonStr: String, _ type: T.Type) -> T? {
        if let jsonData = jsonStr.data(using: .utf8) {
            return dataToModel(jsonData, type)
        }else {
            return nil
        }
    }
}

public struct ObjectModel<Value: Codable>: Codable {
    var code:   Int?
    var msg:    String?
    var data:   Value?
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case msg  = "Msg"
        case data = "Data"
    }
}

public struct EasyObjectModel: Codable {
    var code:   Int?
    var msg:    String?
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case msg  = "Msg"
    }
}
