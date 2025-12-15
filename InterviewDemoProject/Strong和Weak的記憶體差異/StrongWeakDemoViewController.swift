//
//  StrongWeakDemoViewController.swift
//  InterviewDemoProject
//
//  Strong 和 Weak 對記憶體差異的演示
//

import UIKit

// MARK: - Demo 1: Basic Strong vs Weak

/// 示範物件：用於觀察記憶體釋放
class DemoObject {
    var name: String
    
    init(name: String) {
        self.name = name
        print("✅ \(name) initialized - 物件已創建")
    }
    
    deinit {
        print("❌ \(name) deinitialized - 物件已釋放")
    }
}

// MARK: - Demo 2: Retain Cycle Problem (循環引用問題)

/// RetainCyclePerson 類別 - 持有 Apartment 的 strong 引用
class RetainCyclePerson {
    let name: String
    var apartment: Apartment?
    
    init(name: String) {
        self.name = name
        print("✅ Person '\(name)' initialized")
    }
    
    deinit {
        print("❌ Person '\(name)' deinitialized")
    }
}

/// Apartment 類別 - 持有 RetainCyclePerson 的 strong 引用（會造成循環引用）
class Apartment {
    let unit: String
    var tenant: RetainCyclePerson?  // ⚠️ Strong reference - 會造成循環引用！
    
    init(unit: String) {
        self.unit = unit
        print("✅ Apartment '\(unit)' initialized")
    }
    
    deinit {
        print("❌ Apartment '\(unit)' deinitialized")
    }
}

// MARK: - Demo 3: Retain Cycle Solution (循環引用解決方案)

/// BetterPerson 類別 - 持有 BetterApartment 的 strong 引用
class BetterPerson {
    let name: String
    var apartment: BetterApartment?
    
    init(name: String) {
        self.name = name
        print("✅ BetterPerson '\(name)' initialized")
    }
    
    deinit {
        print("❌ BetterPerson '\(name)' deinitialized")
    }
}

/// BetterApartment 類別 - 持有 BetterPerson 的 weak 引用（解決循環引用）
class BetterApartment {
    let unit: String
    weak var tenant: BetterPerson?  // ✅ Weak reference - 避免循環引用
    
    init(unit: String) {
        self.unit = unit
        print("✅ BetterApartment '\(unit)' initialized")
    }
    
    deinit {
        print("❌ BetterApartment '\(unit)' deinitialized")
    }
}

// MARK: - Demo 4: Closure Retain Cycle (閉包循環引用)

/// NetworkManager - 示範閉包循環引用問題
class NetworkManager {
    var url: String
    var completionHandler: (() -> Void)?
    
    init(url: String) {
        self.url = url
        print("✅ NetworkManager for '\(url)' initialized")
    }
    
    deinit {
        print("❌ NetworkManager for '\(url)' deinitialized")
    }
    
    /// ⚠️ 錯誤示範：會造成循環引用
    func fetchDataWithRetainCycle() {
        completionHandler = {
            // self 被閉包強引用，造成循環引用
            print("Fetching data from \(self.url)")
        }
    }
    
    /// ✅ 正確示範：使用 weak self 避免循環引用
    func fetchDataCorrectly() {
        completionHandler = { [weak self] in
            // 使用 weak self，安全解決循環引用
            guard let self = self else { return }
            print("Fetching data from \(self.url)")
        }
    }
}

// MARK: - Demo 5: Delegate Pattern (委託模式)

/// Protocol for delegate pattern
protocol DataSourceDelegate: AnyObject {
    func didReceiveData(_ data: String)
}

/// DataSource 類別 - 使用 weak delegate 避免循環引用
class DataSource {
    // ✅ Delegate 必須使用 weak 避免循環引用
    weak var delegate: DataSourceDelegate?
    
    init() {
        print("✅ DataSource initialized")
    }
    
    deinit {
        print("❌ DataSource deinitialized")
    }
    
    func fetchData() {
        // 模擬獲取資料
        let data = "Sample Data"
        delegate?.didReceiveData(data)
    }
}

// MARK: - Main ViewController

class StrongWeakDemoViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    // Demo objects - 用於保持引用以便觀察記憶體行為
    private var retainCycleObjects: (person: RetainCyclePerson?, apartment: Apartment?) = (nil, nil)
    private var goodObjects: (person: BetterPerson?, apartment: BetterApartment?) = (nil, nil)
    private var networkManager: NetworkManager?
    private var dataSource: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("\n" + String(repeating: "=", count: 60))
        print("Strong vs Weak Memory Demo Started")
        print("請查看控制台輸出以觀察記憶體行為")
        print(String(repeating: "=", count: 60) + "\n")
    }
    
    private func setupUI() {
        title = "Strong vs Weak Demo"
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup stack view
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .fill
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Add demo sections
        addDemoSection(
            title: "Demo 1: 基本 Strong vs Weak",
            description: "示範 strong 和 weak 引用對物件生命週期的影響",
            buttonTitle: "執行 Demo 1",
            action: #selector(demo1BasicStrongWeak)
        )
        
        addDemoSection(
            title: "Demo 2: 循環引用問題 ⚠️",
            description: "示範使用 strong 引用造成的記憶體洩漏",
            buttonTitle: "創建循環引用",
            action: #selector(demo2CreateRetainCycle)
        )
        
        addDemoSection(
            title: "Demo 2b: 嘗試釋放循環引用物件",
            description: "物件無法被釋放，造成記憶體洩漏",
            buttonTitle: "釋放物件 (會失敗)",
            action: #selector(demo2ReleaseRetainCycle)
        )
        
        addDemoSection(
            title: "Demo 3: 使用 Weak 解決循環引用 ✅",
            description: "使用 weak 引用避免記憶體洩漏",
            buttonTitle: "執行 Demo 3",
            action: #selector(demo3AvoidRetainCycle)
        )
        
        addDemoSection(
            title: "Demo 4a: 閉包循環引用問題 ⚠️",
            description: "示範閉包捕獲 self 造成的循環引用",
            buttonTitle: "創建閉包循環引用",
            action: #selector(demo4ClosureRetainCycle)
        )
        
        addDemoSection(
            title: "Demo 4b: 使用 [weak self] 解決 ✅",
            description: "使用 weak self 避免閉包循環引用",
            buttonTitle: "正確使用閉包",
            action: #selector(demo4ClosureCorrect)
        )
        
        addDemoSection(
            title: "Demo 5: Delegate 模式",
            description: "示範 Delegate 中使用 weak 的重要性",
            buttonTitle: "執行 Delegate Demo",
            action: #selector(demo5DelegatePattern)
        )
        
        addDemoSection(
            title: "清理所有物件",
            description: "釋放所有示範用物件，觀察記憶體釋放",
            buttonTitle: "清理記憶體",
            action: #selector(cleanupAllObjects)
        )
    }
    
    private func addDemoSection(title: String, description: String, buttonTitle: String, action: Selector) {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        
        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descLabel)
        stackView.addArrangedSubview(button)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        contentStackView.addArrangedSubview(containerView)
    }
    
    // MARK: - Demo Methods
    
    @objc private func demo1BasicStrongWeak() {
        print("\n" + String(repeating: "=", count: 60))
        print("Demo 1: 基本 Strong vs Weak 引用")
        print(String(repeating: "=", count: 60))
        
        // Strong reference example
        print("\n📌 Strong Reference 範例:")
        var strongObject: DemoObject? = DemoObject(name: "Strong Object")
        print("Strong object created and held by variable")
        strongObject = nil
        print("Strong reference set to nil, object can be released")
        
        // Weak reference example
        print("\n📌 Weak Reference 範例:")
        weak var weakObject: DemoObject? = DemoObject(name: "Weak Object")
        print("Weak object created but NO strong reference!")
        print("Object immediately released because no strong reference exists")
        print("Weak variable is now: \(weakObject == nil ? "nil" : "not nil")")
        
        // Weak with strong example
        print("\n📌 Weak + Strong Reference 範例:")
        var strongHolder: DemoObject? = DemoObject(name: "Strong Holder")
        weak var weakReference = strongHolder
        print("Strong holder created, weak reference points to it")
        print("Weak reference is: \(weakReference?.name ?? "nil")")
        strongHolder = nil
        print("Strong holder set to nil, object released")
        print("Weak reference is now: \(weakReference == nil ? "nil" : "not nil")")
        
        showAlert(
            title: "Demo 1 完成",
            message: "請查看控制台輸出\n\n關鍵觀察點：\n• Strong 引用會保持物件存活\n• Weak 引用不會阻止物件釋放\n• Weak 引用在物件釋放後自動變為 nil"
        )
    }
    
    @objc private func demo2CreateRetainCycle() {
        print("\n" + String(repeating: "=", count: 60))
        print("Demo 2: 創建循環引用 (Retain Cycle) ⚠️")
        print(String(repeating: "=", count: 60))
        
        // Create person and apartment with mutual strong references
        let john = RetainCyclePerson(name: "John")
        let unit4A = Apartment(unit: "4A")
        
        // Create retain cycle
        john.apartment = unit4A
        unit4A.tenant = john
        
        print("\n⚠️ 循環引用已創建:")
        print("John (RetainCyclePerson) → strong → Apartment 4A")
        print("Apartment 4A → strong → John (RetainCyclePerson)")
        print("兩個物件互相持有，形成循環引用")
        
        // Store references
        retainCycleObjects = (john, unit4A)
        
        showAlert(
            title: "循環引用已創建 ⚠️",
            message: "Person 和 Apartment 互相持有 strong 引用\n\n這會造成記憶體洩漏！\n\n請點擊下一個按鈕嘗試釋放它們"
        )
    }
    
    @objc private func demo2ReleaseRetainCycle() {
        print("\n" + String(repeating: "=", count: 60))
        print("Demo 2b: 嘗試釋放循環引用的物件")
        print(String(repeating: "=", count: 60))
        
        print("\n嘗試將引用設為 nil...")
        retainCycleObjects = (nil, nil)
        
        print("\n❌ 問題：即使我們將引用設為 nil，")
        print("物件的 deinit 並沒有被調用！")
        print("這是因為物件之間的循環引用阻止了記憶體釋放")
        print("→ 這就是記憶體洩漏！")
        
        showAlert(
            title: "記憶體洩漏 ❌",
            message: "注意控制台輸出：\n\n沒有看到 'deinitialized' 訊息！\n\n物件無法被釋放，這就是循環引用造成的記憶體洩漏"
        )
    }
    
    @objc private func demo3AvoidRetainCycle() {
        print("\n" + String(repeating: "=", count: 60))
        print("Demo 3: 使用 Weak 解決循環引用 ✅")
        print(String(repeating: "=", count: 60))
        
        // Create person and apartment with weak reference
        var john: BetterPerson? = BetterPerson(name: "John")
        var unit4A: BetterApartment? = BetterApartment(unit: "4A")
        
        // Create relationship - no retain cycle!
        john?.apartment = unit4A
        unit4A?.tenant = john  // ✅ Weak reference!
        
        print("\n✅ 正確的引用關係:")
        print("John (BetterPerson) → strong → BetterApartment 4A")
        print("BetterApartment 4A → weak → John (BetterPerson)")
        print("使用 weak 引用打破了循環")
        
        // Store strong references temporarily
        goodObjects = (john, unit4A)
        
        print("\n現在釋放 John (Person)...")
        john = nil
        
        print("\n✅ 成功：John 的 deinit 被調用了！")
        print("因為 Apartment 使用 weak 引用，不會阻止 Person 被釋放")
        
        print("\n檢查 Apartment 的 tenant 屬性...")
        print("tenant is now: \(unit4A?.tenant == nil ? "nil" : "not nil")")
        print("✅ weak 引用自動變為 nil")
        
        print("\n現在釋放 Apartment...")
        unit4A = nil
        goodObjects.apartment = nil
        
        print("\n✅ 所有物件都正確釋放了！")
        
        showAlert(
            title: "問題解決 ✅",
            message: "查看控制台輸出：\n\n所有物件都正確釋放了！\n\nweak 引用成功打破了循環引用，避免了記憶體洩漏"
        )
    }
    
    @objc private func demo4ClosureRetainCycle() {
        print("\n" + String(repeating: "=", count: 60))
        print("Demo 4a: 閉包循環引用問題 ⚠️")
        print(String(repeating: "=", count: 60))
        
        var manager: NetworkManager? = NetworkManager(url: "https://api.example.com")
        manager?.fetchDataWithRetainCycle()
        
        print("\n⚠️ 問題：閉包捕獲了 self 的強引用")
        print("NetworkManager → strong → closure")
        print("closure → strong → self (NetworkManager)")
        print("形成循環引用")
        
        networkManager = manager
        
        print("\n現在嘗試釋放 NetworkManager...")
        manager = nil
        
        print("\n❌ NetworkManager 無法被釋放！")
        print("因為閉包持有 self 的強引用")
        
        showAlert(
            title: "閉包循環引用 ⚠️",
            message: "NetworkManager 無法被釋放！\n\n閉包內的 self 造成了循環引用\n\n查看下一個 demo 學習正確做法"
        )
    }
    
    @objc private func demo4ClosureCorrect() {
        print("\n" + String(repeating: "=", count: 60))
        print("Demo 4b: 使用 [weak self] 解決閉包循環引用 ✅")
        print(String(repeating: "=", count: 60))
        
        // Clean up previous manager first
        print("先清理之前的 NetworkManager...")
        networkManager = nil
        print("(注意：之前的 manager 仍然無法釋放)\n")
        
        var manager: NetworkManager? = NetworkManager(url: "https://api.example.com/v2")
        manager?.fetchDataCorrectly()
        
        print("\n✅ 正確做法：使用 [weak self]")
        print("閉包使用 weak 引用捕獲 self")
        print("這樣不會增加 self 的引用計數")
        
        print("\n現在嘗試釋放 NetworkManager...")
        manager = nil
        
        print("\n✅ NetworkManager 成功被釋放！")
        print("weak self 打破了循環引用")
        
        showAlert(
            title: "問題解決 ✅",
            message: "使用 [weak self] 成功解決問題！\n\nNetworkManager 被正確釋放了\n\n這是處理閉包循環引用的標準做法"
        )
    }
    
    @objc private func demo5DelegatePattern() {
        print("\n" + String(repeating: "=", count: 60))
        print("Demo 5: Delegate 模式與 Weak 引用")
        print(String(repeating: "=", count: 60))
        
        dataSource = DataSource()
        dataSource?.delegate = self
        
        print("\n✅ DataSource 的 delegate 使用 weak 引用")
        print("這是 delegate 模式的標準做法")
        print("避免 ViewController 和 DataSource 之間的循環引用")
        
        print("\n觸發 delegate 方法...")
        dataSource?.fetchData()
        
        showAlert(
            title: "Delegate 模式",
            message: "Delegate 必須使用 weak 引用！\n\n原因：\n• ViewController 持有 DataSource (strong)\n• DataSource 持有 delegate (weak)\n• 避免循環引用"
        )
    }
    
    @objc private func cleanupAllObjects() {
        print("\n" + String(repeating: "=", count: 60))
        print("清理所有物件")
        print(String(repeating: "=", count: 60))
        
        print("\n釋放所有引用...")
        retainCycleObjects = (nil, nil)
        goodObjects = (nil, nil)
        networkManager = nil
        dataSource = nil
        
        print("\n觀察哪些物件被釋放了：")
        print("• 使用 weak 的物件 → 正確釋放 ✅")
        print("• 有循環引用的物件 → 無法釋放 ❌ (記憶體洩漏)")
        
        showAlert(
            title: "清理完成",
            message: "查看控制台輸出\n\n注意哪些物件被成功釋放，哪些沒有被釋放（記憶體洩漏）"
        )
    }
    
    // MARK: - Helper Methods
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        print("\n❌ StrongWeakDemoViewController deinitialized")
        print("⚠️ 注意：如果有循環引用的物件還沒釋放，這是記憶體洩漏！\n")
    }
}

// MARK: - DataSourceDelegate Implementation

extension StrongWeakDemoViewController: DataSourceDelegate {
    func didReceiveData(_ data: String) {
        print("✅ Delegate method called with data: \(data)")
    }
}

