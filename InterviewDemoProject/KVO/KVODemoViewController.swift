//
//  KVODemoViewController.swift
//  KVO Demo
//
//  演示KVO的各種使用方式
//

import UIKit

class KVODemoViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 被觀察的Person對象
    private let person = Person(name: "張三", age: 25, occupation: "iOS工程師", salary: 50000)
    
    /// 公司對象 - 用於演示手動KVO
    private let company = Company(name: "科技公司", employeeCount: 100)
    
    /// 銀行帳戶 - 用於演示依賴鍵
    private let bankAccount = BankAccount()
    
    /// 現代KVO觀察者（自動管理生命週期）
    private var nameObservation: NSKeyValueObservation?
    private var ageObservation: NSKeyValueObservation?
    private var salaryObservation: NSKeyValueObservation?
    private var cityObservation: NSKeyValueObservation?
    private var companyObservation: NSKeyValueObservation?
    private var balanceObservation: NSKeyValueObservation?
    private var totalValueObservation: NSKeyValueObservation?
    
    /// Context用於區分不同的觀察（傳統KVO方式）
    private var occupationContext = 0
    
    /// 控制台輸出視圖
    private let consoleTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = UIColor.black
        textView.textColor = UIColor.green
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    /// 滾動視圖包含所有按鈕
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKVO()
        logMessage("🎯 KVO Demo 啟動")
        logMessage("準備觀察 Person, Company, BankAccount 對象")
    }
    
    deinit {
        // 移除傳統方式的觀察者
        removeTraditionalObservers()
        logMessage("✅ ViewController 釋放，所有觀察者已移除")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "KVO Demo"
        view.backgroundColor = .systemBackground
        
        view.addSubview(consoleTextView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // 設置約束
        NSLayoutConstraint.activate([
            consoleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            consoleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            consoleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            consoleTextView.heightAnchor.constraint(equalToConstant: 200),
            
            scrollView.topAnchor.constraint(equalTo: consoleTextView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // 添加按鈕
        addSectionLabel("基本屬性觀察")
        addButton(title: "改變姓名 (現代KVO)", action: #selector(changeNameTapped))
        addButton(title: "增加年齡 (現代KVO)", action: #selector(increaseAgeTapped))
        addButton(title: "改變職業 (傳統KVO)", action: #selector(changeOccupationTapped))
        addButton(title: "調整薪水 (現代KVO)", action: #selector(adjustSalaryTapped))
        
        addSectionLabel("嵌套KeyPath觀察")
        addButton(title: "設置地址", action: #selector(setAddressTapped))
        addButton(title: "改變城市 (嵌套觀察)", action: #selector(changeCityTapped))
        
        addSectionLabel("手動KVO控制")
        addButton(title: "增加員工 (手動KVO)", action: #selector(addEmployeesTapped))
        
        addSectionLabel("依賴鍵KVO")
        addButton(title: "存款 (觸發totalValue)", action: #selector(depositTapped))
        addButton(title: "調整利率 (觸發totalValue)", action: #selector(adjustInterestRateTapped))
        
        addSectionLabel("其他操作")
        addButton(title: "查看Person狀態", action: #selector(showPersonStateTapped))
        addButton(title: "清空控制台", action: #selector(clearConsoleTapped))
    }
    
    private func addSectionLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .systemBlue
        contentStackView.addArrangedSubview(label)
    }
    
    private func addButton(title: String, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        contentStackView.addArrangedSubview(button)
    }
    
    // MARK: - Setup KVO
    
    private func setupKVO() {
        // 設置初始地址
        person.address = Address(city: "台北", street: "信義路", zipCode: "100")
        bankAccount.balance = 10000
        bankAccount.interestRate = 0.02
        
        // 方式1: 使用現代Swift KVO (NSKeyValueObservation) - 推薦方式
        setupModernKVO()
        
        // 方式2: 使用傳統KVO (addObserver) - 需要手動管理
        setupTraditionalKVO()
    }
    
    /// 現代Swift KVO - 類型安全，自動管理生命週期
    private func setupModernKVO() {
        logMessage("\n📱 設置現代KVO (NSKeyValueObservation)")
        
        // 觀察姓名變化
        nameObservation = person.observe(\.name, options: [.new, .old]) { [weak self] person, change in
            let oldValue = change.oldValue ?? "nil"
            let newValue = change.newValue ?? "nil"
            self?.logMessage("👤 [現代KVO] 姓名變化: \(oldValue) -> \(newValue)")
        }
        
        // 觀察年齡變化 - 包含初始值通知
        ageObservation = person.observe(\.age, options: [.new, .old, .initial]) { [weak self] person, change in
            let oldValue = change.oldValue.map { String($0) } ?? "nil"
            let newValue = change.newValue.map { String($0) } ?? "nil"
            self?.logMessage("🎂 [現代KVO] 年齡變化: \(oldValue) -> \(newValue)")
        }
        
        // 觀察薪水變化
        salaryObservation = person.observe(\.salary, options: [.new, .old]) { [weak self] person, change in
            let oldValue = change.oldValue.map { String(format: "%.0f", $0) } ?? "nil"
            let newValue = change.newValue.map { String(format: "%.0f", $0) } ?? "nil"
            self?.logMessage("💰 [現代KVO] 薪水變化: \(oldValue) -> \(newValue)")
        }
        
        // 觀察嵌套屬性 - KeyPath: address.city
        cityObservation = person.observe(\.address?.city, options: [.new, .old]) { [weak self] person, change in
            let oldValue = change.oldValue ?? "nil"
            let newValue = change.newValue ?? "nil"
            self?.logMessage("🏙️ [現代KVO - 嵌套] 城市變化: \(oldValue) -> \(newValue)")
        }
        
        // 觀察公司員工數
        companyObservation = company.observe(\.employeeCount, options: [.new, .old]) { [weak self] company, change in
            let oldValue = change.oldValue.map { String($0) } ?? "nil"
            let newValue = change.newValue.map { String($0) } ?? "nil"
            self?.logMessage("🏢 [手動KVO] 員工數變化: \(oldValue) -> \(newValue)")
        }
        
        // 觀察銀行帳戶餘額
        balanceObservation = bankAccount.observe(\.balance, options: [.new]) { [weak self] account, change in
            let newValue = change.newValue.map { String(format: "%.0f", $0) } ?? "nil"
            self?.logMessage("💵 [依賴鍵] 餘額變化: \(newValue)")
        }
        
        // 觀察總價值（依賴於balance和interestRate）
        totalValueObservation = bankAccount.observe(\.totalValue, options: [.new]) { [weak self] account, change in
            let newValue = change.newValue.map { String(format: "%.2f", $0) } ?? "nil"
            self?.logMessage("📊 [依賴鍵] 總價值變化: \(newValue)")
        }
    }
    
    /// 傳統KVO - 需要手動移除觀察者
    private func setupTraditionalKVO() {
        logMessage("\n📱 設置傳統KVO (addObserver)")
        
        // 使用context來區分不同的觀察
        person.addObserver(self, 
                          forKeyPath: #keyPath(Person.occupation), 
                          options: [.new, .old], 
                          context: &occupationContext)
    }
    
    /// 移除傳統KVO觀察者
    private func removeTraditionalObservers() {
        person.removeObserver(self, forKeyPath: #keyPath(Person.occupation), context: &occupationContext)
    }
    
    // MARK: - Traditional KVO Callback
    
    /// 傳統KVO的回調方法
    /// 所有使用addObserver添加的觀察都會調用這個方法
    override func observeValue(forKeyPath keyPath: String?,
                              of object: Any?,
                              change: [NSKeyValueChangeKey : Any]?,
                              context: UnsafeMutableRawPointer?) {
        
        // 使用context來判斷是哪個觀察
        if context == &occupationContext {
            let oldValue = change?[.oldKey] as? String ?? "nil"
            let newValue = change?[.newKey] as? String ?? "nil"
            logMessage("💼 [傳統KVO] 職業變化: \(oldValue) -> \(newValue)")
        } else {
            // 如果不是我們的context，傳遞給父類處理
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func changeNameTapped() {
        let names = ["李四", "王五", "趙六", "張三"]
        let newName = names.randomElement() ?? "張三"
        logMessage("\n🔄 執行: 改變姓名為 \(newName)")
        person.name = newName
    }
    
    @objc private func increaseAgeTapped() {
        logMessage("\n🔄 執行: 年齡+1")
        person.age += 1
    }
    
    @objc private func changeOccupationTapped() {
        let occupations = ["iOS工程師", "Android工程師", "全端工程師", "架構師"]
        let newOccupation = occupations.randomElement() ?? "iOS工程師"
        logMessage("\n🔄 執行: 改變職業為 \(newOccupation)")
        person.occupation = newOccupation
    }
    
    @objc private func adjustSalaryTapped() {
        let adjustment = Double.random(in: -5000...10000)
        logMessage("\n🔄 執行: 調整薪水 \(adjustment > 0 ? "+" : "")\(String(format: "%.0f", adjustment))")
        person.salary += adjustment
    }
    
    @objc private func setAddressTapped() {
        let cities = ["台北", "台中", "高雄", "台南"]
        let city = cities.randomElement() ?? "台北"
        logMessage("\n🔄 執行: 設置新地址")
        person.address = Address(city: city, street: "中正路", zipCode: "100")
    }
    
    @objc private func changeCityTapped() {
        guard let address = person.address else {
            logMessage("⚠️ 請先設置地址")
            return
        }
        let cities = ["台北", "台中", "高雄", "台南"]
        let newCity = cities.randomElement() ?? "台北"
        logMessage("\n🔄 執行: 改變城市為 \(newCity)")
        address.city = newCity
    }
    
    @objc private func addEmployeesTapped() {
        let count = Int.random(in: 1...10)
        logMessage("\n🔄 執行: 批量增加 \(count) 名員工")
        company.addEmployees(count: count)
    }
    
    @objc private func depositTapped() {
        let amount = Double.random(in: 1000...5000)
        logMessage("\n🔄 執行: 存款 \(String(format: "%.0f", amount))")
        bankAccount.balance += amount
        // 注意：改變balance會自動觸發totalValue的KVO通知（依賴鍵）
    }
    
    @objc private func adjustInterestRateTapped() {
        let newRate = Double.random(in: 0.01...0.05)
        logMessage("\n🔄 執行: 調整利率為 \(String(format: "%.2f%%", newRate * 100))")
        bankAccount.interestRate = newRate
        // 注意：改變interestRate會自動觸發totalValue的KVO通知（依賴鍵）
    }
    
    @objc private func showPersonStateTapped() {
        logMessage("\n📋 當前Person狀態:")
        logMessage("姓名: \(person.name)")
        logMessage("年齡: \(person.age)")
        logMessage("職業: \(person.occupation)")
        logMessage("薪水: \(String(format: "%.0f", person.salary))")
        if let address = person.address {
            logMessage("地址: \(address.city) - \(address.street)")
        }
        logMessage("\n📋 當前Company狀態:")
        logMessage("公司: \(company.companyName)")
        logMessage("員工數: \(company.employeeCount)")
        logMessage("\n📋 當前BankAccount狀態:")
        logMessage("餘額: \(String(format: "%.0f", bankAccount.balance))")
        logMessage("利率: \(String(format: "%.2f%%", bankAccount.interestRate * 100))")
        logMessage("總價值: \(String(format: "%.2f", bankAccount.totalValue))")
    }
    
    @objc private func clearConsoleTapped() {
        consoleTextView.text = ""
    }
    
    // MARK: - Helper Methods
    
    private func logMessage(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logText = "[\(timestamp)] \(message)\n"
        
        DispatchQueue.main.async { [weak self] in
            self?.consoleTextView.text += logText
            
            // 自動滾動到底部
            let range = NSRange(location: (self?.consoleTextView.text.count ?? 0) - 1, length: 1)
            self?.consoleTextView.scrollRangeToVisible(range)
        }
    }
}

// MARK: - KVO實現原理演示擴展

extension KVODemoViewController {
    
    /// 演示KVO的內部實現原理
    /// 通過Runtime API查看KVO動態創建的子類
    func demonstrateKVOImplementation() {
        logMessage("\n🔍 KVO實現原理演示:")
        
        let normalPerson = Person(name: "Normal", age: 20, occupation: "Developer", salary: 50000)
        let observedPerson = Person(name: "Observed", age: 25, occupation: "Engineer", salary: 60000)
        
        // 添加觀察前的類名
        let classNameBefore = String(describing: type(of: observedPerson))
        logMessage("觀察前的類名: \(classNameBefore)")
        
        // 添加觀察者
        let observation = observedPerson.observe(\.name, options: [.new]) { _, _ in }
        
        // 添加觀察後的類名（Runtime動態創建的子類）
        let classNameAfter = String(describing: type(of: observedPerson))
        logMessage("觀察後的類名: \(classNameAfter)")
        
        // 比較普通對象和被觀察對象的類名
        logMessage("普通Person的類名: \(String(describing: type(of: normalPerson)))")
        logMessage("被觀察Person的類名: \(classNameAfter)")
        
        // 注意：實際的isa已經改變為NSKVONotifying_Person
        // 但class方法被重寫，返回原始類名來隱藏實現
        
        _ = observation // 保持觀察者存活
    }
}

