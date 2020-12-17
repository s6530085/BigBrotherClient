//
//  BaseAlgorithm.swift
//  BigBrotherClient
//
//  Created by xiaomin on 2020/10/6.
//  Copyright © 2020 sunmin.me. All rights reserved.
//

import Foundation

class BaseAlgorithm {
    // 因为本身性质,所以随机自然是无重复数字并排好序了哈
    class func random(_ count :Int, min:Int, max:Int, prefers:[Int]?, excludes:[Int]?) ->[Int] {
        var r = [Int]()
        let pc = prefers == nil ? 0 : prefers!.count
        if (prefers != nil) {
            r.append(contentsOf: prefers!)
        }
        for _ in 0 ..< (count - pc) {
            while true {
                let i = Int.random(in: min...max)
                if (excludes == nil || (excludes != nil && !excludes!.contains(i))) {
                    if !r.contains(i) {
                        r.append(i)
                        break
                    }
                }
            }
        }
        
        return r.sorted()
    }
}
