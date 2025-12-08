//
//  Person.swift
//  KVO Demo
//
//  被觀察的Model類別
//  用於演示KVO機制
//

import Foundation

// MARK: - Person Model
/// 必須繼承自NSObject才能使用KVO
/// 屬性需要標記為 @objc dynamic 才能被觀察
class Person: NSObject {
    
    // MARK: - Properties
    
    /// 姓名 - 支援KVO
    @objc dynamic var name: String
    
    /// 年齡 - 支援KVO
    @objc dynamic var age: Int
    
    /// 職業 - 支援KVO
    @objc dynamic var occupation: String
    
    /// 薪水 - 支援KVO
    @objc dynamic var salary: Double
    
    /// 地址對象 - 用於演示嵌套KeyPath觀察
    @objc dynamic var address: Address?
    
    /// 技能列表 - 用於演示集合的KVO
    @objc dynamic var skills: [String]
    
    // MARK: - Initialization
    
    init(name: String, age: Int, occupation: String, salary: Double) {
        self.name = name
        self.age = age
        self.occupation = occupation
        self.salary = salary
        self.skills = []
        super.init()
    }
    
    // MARK: - Custom Description
    
    override var description: String {
        return """
        Person {
            name: \(name),
            age: \(age),
            occupation: \(occupation),
            salary: \(salary),
            address: \(address?.description ?? "nil"),
            skills: \(skills)
        }
        """
    }
}

// MARK: - Address Model
/// 地址類別 - 用於演示嵌套屬性的KVO
class Address: NSObject {
    
    @objc dynamic var city: String
    @objc dynamic var street: String
    @objc dynamic var zipCode: String
    
    init(city: String, street: String, zipCode: String) {
        self.city = city
        self.street = street
        self.zipCode = zipCode
        super.init()
    }
    
    override var description: String {
        return "\(street), \(city) \(zipCode)"
    }
}

// MARK: - Company Model with Manual KVO
/// 公司類別 - 演示手動控制KVO的通知
class Company: NSObject {
    
    /// 員工數量 - 禁用自動KVO
    private var _employeeCount: Int = 0
    
    @objc dynamic var employeeCount: Int {
        get {
            return _employeeCount
        }
        set {
            // 手動觸發KVO通知
            willChangeValue(forKey: "employeeCount")
            _employeeCount = newValue
            didChangeValue(forKey: "employeeCount")
        }
    }
    
    @objc dynamic var companyName: String
    
    init(name: String, employeeCount: Int) {
        self.companyName = name
        self._employeeCount = employeeCount
        super.init()
    }
    
    // MARK: - Disable Automatic KVO for specific property
    
    /// 對於employeeCount屬性，我們禁用自動KVO
    /// 這樣可以手動控制何時發送通知
    override class func automaticallyNotifiesObservers(forKey key: String) -> Bool {
        if key == "employeeCount" {
            return false  // 禁用自動KVO
        }
        return super.automaticallyNotifiesObservers(forKey: key)
    }
    
    /// 批量添加員工 - 只觸發一次KVO通知
    func addEmployees(count: Int) {
        willChangeValue(forKey: "employeeCount")
        _employeeCount += count
        didChangeValue(forKey: "employeeCount")
    }
}

// MARK: - BankAccount with Dependent Keys
/// 銀行帳戶 - 演示依賴鍵的KVO
class BankAccount: NSObject {
    
    @objc dynamic var balance: Double = 0.0
    @objc dynamic var interestRate: Double = 0.0
    
    /// 計算屬性 - 依賴於balance和interestRate
    /// 當balance或interestRate改變時，totalValue也會觸發KVO通知
    @objc dynamic var totalValue: Double {
        return balance * (1 + interestRate)
    }
    
    // MARK: - Dependent Keys
    
    /// 聲明totalValue依賴於balance和interestRate
    /// 當這兩個屬性改變時，totalValue的觀察者也會收到通知
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if key == "totalValue" {
            return ["balance", "interestRate"]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
}

