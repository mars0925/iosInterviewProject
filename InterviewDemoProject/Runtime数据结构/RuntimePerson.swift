//
//  RuntimePerson.swift
//  InterviewDemoProject
//
//  Runtime 演示用的 Model 類
//

import Foundation

// MARK: - RuntimePerson 類
/// 用於演示 Runtime 數據結構和 API 的示例類
@objcMembers class RuntimePerson: NSObject {
    
    // MARK: - Properties
    
    /// 姓名
    var name: String
    
    /// 年齡
    var age: Int
    
    /// 郵箱（私有屬性，用於演示獲取所有屬性）
    private var email: String?
    
    /// 電話號碼（私有屬性）
    private var phoneNumber: String?
    
    // MARK: - Initialization
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
        super.init()
    }
    
    // MARK: - Instance Methods
    
    /// 打招呼方法
    func sayHello() {
        print("Hello, my name is \(name), I'm \(age) years old.")
    }
    
    /// 走路方法
    func walk() {
        print("\(name) is walking.")
    }
    
    /// 私有方法，用於演示 Runtime 可以獲取私有方法
    private func privateMethod() {
        print("This is a private method.")
    }
    
    // MARK: - Class Methods
    
    /// 類方法示例
    class func classMethod() {
        print("This is a class method.")
    }
    
    /// 描述類的方法
    class func describe() {
        print("RuntimePerson class for Runtime demonstration.")
    }
}

// MARK: - Category Extension (模擬 Category)
/// 這個擴展用於演示 Category 的概念
extension RuntimePerson {
    
    /// 分類中添加的方法
    func categoryMethod() {
        print("This method is added in extension (like Category).")
    }
    
    /// 運動方法
    func exercise() {
        print("\(name) is exercising.")
    }
}

