//
//  Student.swift
//  InterviewDemoProject
//
//  Created by MarsChang on 2025/12/5.
//

import Foundation

class Student: NSObject  {
    var name: String
    @objc dynamic var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
}
