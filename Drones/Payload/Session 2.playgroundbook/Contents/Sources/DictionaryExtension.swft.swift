//
//  DictionaryExtension.swft.swift
//  LiveViewTestApp
//
//  Created by XIAOWEI WANG on 2018/11/16.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral, Value:Any {
    
    func toJSON(excludeKeys: [String]? = nil) -> String? {
        var result: String? = nil
        do {
            let data = try JSONSerialization.data(withJSONObject: self as AnyObject, options: .prettyPrinted)
            result = String(data: data, encoding: String.Encoding.utf8)
        } catch _ {
            
        }
        return result
    }
    
    func has(_ key: Key) -> Bool {
        return index(forKey: key) != nil
    }
}

extension Array {
    
    public func toJSON() -> String? {
        var result: String? = nil
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            result = String(data: data, encoding: String.Encoding.utf8)
        } catch _ {
            
        }
        return result
    }
}

extension String {
    public func toDict<Key: Hashable>() -> Dictionary<Key, Any?>? {
        var ret: Dictionary<Key, Any?>? = nil
        if let data = self.data(using: .utf8) {
            do {
                ret = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<Key, Any?>
            } catch {
                
            }
        }
        return ret
    }
}
