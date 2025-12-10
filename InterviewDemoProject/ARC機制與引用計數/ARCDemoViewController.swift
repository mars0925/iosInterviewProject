//
//  ARCDemoViewController.swift
//  InterviewDemoProject
//
//  Demonstrates ARC mechanism and reference counting
//

import UIKit

// MARK: - Demo Classes for ARC

/// Person class to demonstrate reference counting
class Person {
    let name: String
    var apartment: Apartment?
    
    init(name: String) {
        self.name = name
        print("✅ Person '\(name)' 被初始化，引用計數 = 1")
    }
    
    deinit {
        print("❌ Person '\(name)' 被釋放，引用計數降到 0")
    }
}

/// Apartment class demonstrating strong reference
class Apartment {
    let unit: String
    var tenant: Person?  // Strong reference - will cause retain cycle
    
    init(unit: String) {
        self.unit = unit
        print("✅ Apartment '\(unit)' 被初始化")
    }
    
    deinit {
        print("❌ Apartment '\(unit)' 被釋放")
    }
}

// MARK: - Classes with Weak Reference

/// Dog class using weak reference to avoid retain cycle
class Dog {
    let name: String
    weak var owner: PersonWithDog?  // Weak reference - breaks retain cycle
    
    init(name: String) {
        self.name = name
        print("✅ Dog '\(name)' 被初始化")
    }
    
    deinit {
        print("❌ Dog '\(name)' 被釋放")
    }
}

/// Person class with dog property
class PersonWithDog {
    let name: String
    var dog: Dog?
    
    init(name: String) {
        self.name = name
        print("✅ PersonWithDog '\(name)' 被初始化")
    }
    
    deinit {
        print("❌ PersonWithDog '\(name)' 被釋放")
    }
}

// MARK: - Classes with Unowned Reference

/// Customer class for credit card demo
class Customer {
    let name: String
    var card: CreditCard?
    
    init(name: String) {
        self.name = name
        print("✅ Customer '\(name)' 被初始化")
    }
    
    deinit {
        print("❌ Customer '\(name)' 被釋放")
    }
}

/// CreditCard with unowned reference to customer
class CreditCard {
    let number: String
    unowned let customer: Customer  // Unowned reference - customer always exists
    
    init(number: String, customer: Customer) {
        self.number = number
        self.customer = customer
        print("✅ CreditCard '\(number)' 被創建給 '\(customer.name)'")
    }
    
    deinit {
        print("❌ CreditCard '\(number)' 被釋放")
    }
}

// MARK: - View Controller

class ARCDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let resultTextView = UITextView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "ARC 機制與引用計數"
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Result text view
        resultTextView.translatesAutoresizingMaskIntoConstraints = false
        resultTextView.isEditable = false
        resultTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        resultTextView.backgroundColor = .systemGray6
        resultTextView.layer.cornerRadius = 8
        resultTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        resultTextView.text = "點擊按鈕查看 ARC 運作結果\n"
        
        // Create buttons
        let strongRefButton = createButton(title: "1️⃣ Strong Reference 示範", action: #selector(demonstrateStrongReference))
        let retainCycleButton = createButton(title: "2️⃣ Retain Cycle 問題", action: #selector(demonstrateRetainCycle))
        let weakRefButton = createButton(title: "3️⃣ Weak Reference 解決循環引用", action: #selector(demonstrateWeakReference))
        let unownedRefButton = createButton(title: "4️⃣ Unowned Reference 示範", action: #selector(demonstrateUnownedReference))
        let closureRetainButton = createButton(title: "5️⃣ Closure 循環引用", action: #selector(demonstrateClosureRetainCycle))
        let clearButton = createButton(title: "🗑️ 清除結果", action: #selector(clearResults))
        clearButton.backgroundColor = .systemRed
        
        // Stack view for buttons
        let buttonStack = UIStackView(arrangedSubviews: [
            strongRefButton,
            retainCycleButton,
            weakRefButton,
            unownedRefButton,
            closureRetainButton,
            clearButton
        ])
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(buttonStack)
        contentView.addSubview(resultTextView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            buttonStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            resultTextView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            resultTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300),
            resultTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
    
    // MARK: - Demo Methods
    
    /// Demonstrates strong reference and reference counting
    @objc private func demonstrateStrongReference() {
        appendResult("\n=== Strong Reference 示範 ===\n")
        
        // Create person with RC = 1
        var person1: Person? = Person(name: "張三")
        
        // Add strong reference, RC = 2
        var person2: Person? = person1
        appendResult("📌 person2 = person1，引用計數 = 2\n")
        
        // Add another strong reference, RC = 3
        var person3: Person? = person1
        appendResult("📌 person3 = person1，引用計數 = 3\n")
        
        // Remove references one by one
        appendResult("\n開始移除引用...\n")
        person1 = nil
        appendResult("📌 person1 = nil，引用計數 = 2\n")
        
        person2 = nil
        appendResult("📌 person2 = nil，引用計數 = 1\n")
        
        person3 = nil
        appendResult("📌 person3 = nil，引用計數 = 0\n")
        appendResult("⚠️ 應該看到 deinit 被調用\n")
    }
    
    /// Demonstrates retain cycle problem
    @objc private func demonstrateRetainCycle() {
        appendResult("\n=== Retain Cycle 問題示範 ===\n")
        
        // Create person and apartment
        var person: Person? = Person(name: "李四")
        var apartment: Apartment? = Apartment(unit: "5A")
        
        // Create strong references between them
        person?.apartment = apartment
        apartment?.tenant = person
        appendResult("📌 建立雙向強引用：person ↔️ apartment\n")
        appendResult("   person.apartment = apartment\n")
        appendResult("   apartment.tenant = person\n")
        
        // Try to release
        appendResult("\n嘗試釋放...\n")
        person = nil
        apartment = nil
        appendResult("📌 person = nil, apartment = nil\n")
        appendResult("⚠️ 注意：沒有看到 deinit 被調用\n")
        appendResult("❌ 這是記憶體洩漏！兩個物件的引用計數都是 1\n")
    }
    
    /// Demonstrates weak reference to break retain cycle
    @objc private func demonstrateWeakReference() {
        appendResult("\n=== Weak Reference 解決循環引用 ===\n")
        
        // Create person and dog
        var person: PersonWithDog? = PersonWithDog(name: "王五")
        var dog: Dog? = Dog(name: "小黑")
        
        // Create references (dog.owner is weak)
        person?.dog = dog
        dog?.owner = person
        appendResult("📌 建立引用：person → dog (strong)\n")
        appendResult("   dog → owner (weak)\n")
        appendResult("   person 的 RC = 1\n")
        appendResult("   dog 的 RC = 1\n")
        
        // Release references
        appendResult("\n釋放引用...\n")
        person = nil
        appendResult("📌 person = nil\n")
        appendResult("✅ person 被正確釋放（weak 不增加引用計數）\n")
        
        dog = nil
        appendResult("📌 dog = nil\n")
        appendResult("✅ dog 也被正確釋放\n")
    }
    
    /// Demonstrates unowned reference
    @objc private func demonstrateUnownedReference() {
        appendResult("\n=== Unowned Reference 示範 ===\n")
        
        // Create customer
        var customer: Customer? = Customer(name: "趙六")
        
        // Create credit card for customer
        if let customer = customer {
            customer.card = CreditCard(number: "1234-5678", customer: customer)
            appendResult("📌 建立 Customer 和 CreditCard\n")
            appendResult("   card.customer 使用 unowned 引用\n")
            appendResult("   customer 的 RC = 1 (unowned 不增加計數)\n")
        }
        
        // Release customer
        appendResult("\n釋放 customer...\n")
        customer = nil
        appendResult("✅ Customer 和 CreditCard 都被正確釋放\n")
        appendResult("⚠️ CreditCard 總是和 Customer 一起存在\n")
    }
    
    /// Demonstrates closure retain cycle
    @objc private func demonstrateClosureRetainCycle() {
        appendResult("\n=== Closure 循環引用示範 ===\n")
        
        // Example class with closure
        class ViewController {
            var name = "首頁"
            var closure: (() -> Void)?
            
            init() {
                print("✅ ViewController 被初始化")
            }
            
            // BAD: Closure captures self strongly
            func setupBadClosure() {
                closure = {
                    print("頁面名稱：\(self.name)")  // Strong capture
                }
            }
            
            // GOOD: Using weak self
            func setupGoodClosure() {
                closure = { [weak self] in
                    guard let self = self else { return }
                    print("頁面名稱：\(self.name)")
                }
            }
            
            deinit {
                print("❌ ViewController 被釋放")
            }
        }
        
        // Demonstrate bad closure (retain cycle)
        appendResult("❌ 錯誤示範：Closure 強引用 self\n")
        var badVC: ViewController? = ViewController()
        badVC?.setupBadClosure()
        appendResult("   VC → closure (strong)\n")
        appendResult("   closure → self (strong)\n")
        badVC = nil
        appendResult("   badVC = nil，但 ViewController 沒有被釋放\n\n")
        
        // Demonstrate good closure (using weak self)
        appendResult("✅ 正確示範：使用 [weak self]\n")
        var goodVC: ViewController? = ViewController()
        goodVC?.setupGoodClosure()
        appendResult("   VC → closure (strong)\n")
        appendResult("   closure → self (weak)\n")
        goodVC = nil
        appendResult("   goodVC = nil，ViewController 被正確釋放\n")
    }
    
    @objc private func clearResults() {
        resultTextView.text = "點擊按鈕查看 ARC 運作結果\n"
    }
    
    // MARK: - Helper Methods
    
    private func appendResult(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.resultTextView.text += text
            
            // Auto scroll to bottom
            let range = NSRange(location: (self?.resultTextView.text.count ?? 0) - 1, length: 1)
            self?.resultTextView.scrollRangeToVisible(range)
        }
    }
    
    deinit {
        print("❌ ARCDemoViewController 被釋放")
    }
}


