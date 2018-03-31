//
//  UTType.swift
//  Qapular
//
//  Created by Volodymyr Pavliukevych.
//  Copyright © 2014 Volodymyr Pavliukevych. All rights reserved.
//

import Foundation
import CoreServices

extension String {

    func conformsUTI(string: String) -> Bool {
        
        let cfSelfString : CFString = self as CFString
        let cfConformingString : CFString = string as CFString
        
        return UTTypeConformsTo(cfSelfString, cfConformingString)
        
    }

}


extension MutableCollectionType where Generator.Element == String {
    
    func conformsUTI(pattern : String) -> [Generator.Element]{
       let result = self.filter({ (string: String) -> Bool in
            return string.conformsUTI(pattern)
        })
        return result
    }
    
    func containsUTI(pattern : String) -> [Generator.Element]{
        let result = self.filter({ (string: String) -> Bool in
            return pattern.conformsUTI(string)
        })
        return result
    }
    
    
    func orderedContainsUTI(pattern : String) -> [Generator.Element]{
        var result = self.containsUTI(pattern);
        if result.count < 2{
            return result;
        }
        
        var shouldOrder : Bool = true

        while shouldOrder {
            for index in 0..<result.count - 1 {
                guard index.successor() != result.count else {
                    continue
                }
                
                if result[index].conformsUTI(result[index.successor()]) {
                    swap(&result[index], &result[index.successor()])
                    shouldOrder = true
                    break
                }else {
                    shouldOrder = false
                }
            }
        }
        return result
    }
    
    
    
}
