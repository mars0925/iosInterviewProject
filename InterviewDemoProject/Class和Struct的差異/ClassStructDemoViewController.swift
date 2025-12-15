import UIKit

// MARK: - Struct Definition (值類型)
struct PersonStruct {
    var name: String
    var age: Int
    
    // Struct automatically generates memberwise initializer
    // Struct 自動生成成員初始化器
    
    // Mutating method - required for methods that modify properties
    // 修改屬性的方法需要標記為 mutating
    mutating func haveBirthday() {
        age += 1
    }
}

// MARK: - Class Definition (引用類型)
class PersonClass {
    var name: String
    var age: Int
    
    // Class requires explicit initializer
    // Class 需要明確定義初始化器
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    // No 'mutating' keyword needed for class methods
    // Class 的方法不需要 mutating 關鍵字
    func haveBirthday() {
        age += 1
    }
    
    // Deinitializer - only available in classes
    // 反初始化器 - 只有 class 可以使用
    deinit {
        print("PersonClass \(name) is being deinitialized")
    }
}

// MARK: - Reference Counting Example (Class only)
// 引用計數範例（僅 Class）
class Animal {
    let name: String
    
    init(name: String) {
        self.name = name
        print("🐾 Animal \(name) is initialized")
    }
    
    deinit {
        print("💀 Animal \(name) is deinitialized")
    }
}

// MARK: - Inheritance Example (Class only)
// 繼承範例（僅 Class）
class Vehicle {
    var speed: Int = 0
    
    func describe() -> String {
        return "Moving at \(speed) km/h"
    }
}

class Car: Vehicle {
    var brand: String
    
    init(brand: String) {
        self.brand = brand
        super.init()
    }
    
    // Override parent method
    // 覆寫父類方法
    override func describe() -> String {
        return "\(brand) car: \(super.describe())"
    }
}

// MARK: - Demo View Controller
class ClassStructDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Class vs Struct Demo"
        view.backgroundColor = .systemBackground
        
        setupUI()
        runDemos()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup stack view
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    // MARK: - Demo Execution
    private func runDemos() {
        demo1_ValueVsReferenceType()
        demo2_MutabilityDifference()
        demo3_MemoryAndLifecycle()
        demo4_InheritanceClassOnly()
        demo5_PerformanceConsiderations()
    }
    
    // MARK: - Demo 1: Value Type vs Reference Type
    // 演示 1: 值類型 vs 引用類型
    private func demo1_ValueVsReferenceType() {
        let titleLabel = createTitleLabel("1️⃣ Value Type vs Reference Type")
        stackView.addArrangedSubview(titleLabel)
        
        var output = ""
        
        // Struct - Value Type
        output += "=== Struct (值類型) ===\n"
        var person1 = PersonStruct(name: "Alice", age: 25)
        var person2 = person1  // Creates a complete copy
        person2.name = "Bob"
        person2.age = 30
        
        output += "person1: \(person1.name), age: \(person1.age)\n"
        output += "person2: \(person2.name), age: \(person2.age)\n"
        output += "結果: person1 和 person2 是完全獨立的副本\n\n"
        
        // Class - Reference Type
        output += "=== Class (引用類型) ===\n"
        let person3 = PersonClass(name: "Charlie", age: 35)
        let person4 = person3  // Only copies the reference
        person4.name = "David"
        person4.age = 40
        
        output += "person3: \(person3.name), age: \(person3.age)\n"
        output += "person4: \(person4.name), age: \(person4.age)\n"
        output += "結果: person3 和 person4 指向同一個實例\n"
        
        let resultLabel = createResultLabel(output)
        stackView.addArrangedSubview(resultLabel)
    }
    
    // MARK: - Demo 2: Mutability Difference
    // 演示 2: 可變性差異
    private func demo2_MutabilityDifference() {
        let titleLabel = createTitleLabel("2️⃣ Mutability Difference")
        stackView.addArrangedSubview(titleLabel)
        
        var output = ""
        
        // Struct with let - completely immutable
        output += "=== Struct with let ===\n"
        let structPerson = PersonStruct(name: "Emma", age: 28)
        // structPerson.age = 29  // ❌ Compile error
        output += "let 聲明的 struct: 完全不可變\n\n"
        
        // Struct with var - can modify properties
        output += "=== Struct with var ===\n"
        var mutableStructPerson = PersonStruct(name: "Frank", age: 32)
        mutableStructPerson.age = 33
        output += "var 聲明的 struct: 可以修改屬性\n"
        output += "Updated age: \(mutableStructPerson.age)\n\n"
        
        // Class with let - can still modify properties
        output += "=== Class with let ===\n"
        let classPerson = PersonClass(name: "Grace", age: 45)
        classPerson.age = 46  // ✅ This works!
        output += "let 聲明的 class: 引用不可變，但屬性可變\n"
        output += "Updated age: \(classPerson.age)\n"
        
        let resultLabel = createResultLabel(output)
        stackView.addArrangedSubview(resultLabel)
    }
    
    // MARK: - Demo 3: Memory and Lifecycle
    // 演示 3: 記憶體和生命週期
    private func demo3_MemoryAndLifecycle() {
        let titleLabel = createTitleLabel("3️⃣ Memory & Lifecycle")
        stackView.addArrangedSubview(titleLabel)
        
        var output = ""
        
        // Class has deinitializer
        output += "=== Class Lifecycle ===\n"
        output += "Creating animal1...\n"
        
        do {
            let animal1 = Animal(name: "Lion")
            output += "animal1 exists in this scope\n"
            
            let animal2 = animal1  // Reference count increases
            output += "animal2 = animal1 (引用計數增加)\n"
            // Reference count is 2 here
        } // animal1 and animal2 go out of scope, object is deallocated
        
        output += "Scope ended, check console for deinit message\n\n"
        
        // Struct has no reference counting
        output += "=== Struct (無引用計數) ===\n"
        output += "Struct 在堆疊上分配，離開作用域自動釋放\n"
        output += "無需 ARC 管理，無 deinit 方法\n"
        
        let resultLabel = createResultLabel(output)
        stackView.addArrangedSubview(resultLabel)
    }
    
    // MARK: - Demo 4: Inheritance (Class Only)
    // 演示 4: 繼承（僅 Class）
    private func demo4_InheritanceClassOnly() {
        let titleLabel = createTitleLabel("4️⃣ Inheritance (Class Only)")
        stackView.addArrangedSubview(titleLabel)
        
        var output = ""
        
        output += "=== Class 支援繼承 ===\n"
        let vehicle = Vehicle()
        vehicle.speed = 60
        output += "Vehicle: \(vehicle.describe())\n\n"
        
        let car = Car(brand: "Tesla")
        car.speed = 120
        output += "Car: \(car.describe())\n\n"
        
        output += "=== Struct 不支援繼承 ===\n"
        output += "Struct 可以遵循 Protocol，\n"
        output += "但不能繼承其他 struct\n"
        
        let resultLabel = createResultLabel(output)
        stackView.addArrangedSubview(resultLabel)
    }
    
    // MARK: - Demo 5: Performance Considerations
    // 演示 5: 效能考量
    private func demo5_PerformanceConsiderations() {
        let titleLabel = createTitleLabel("5️⃣ Performance Considerations")
        stackView.addArrangedSubview(titleLabel)
        
        var output = ""
        
        output += "=== 記憶體分配 ===\n"
        output += "• Struct: 堆疊 (Stack)\n"
        output += "  - 更快的分配和釋放\n"
        output += "  - 有大小限制\n\n"
        
        output += "• Class: 堆積 (Heap)\n"
        output += "  - 較慢的分配和釋放\n"
        output += "  - 需要 ARC 管理\n"
        output += "  - 可以更大\n\n"
        
        output += "=== 複製開銷 ===\n"
        output += "• Struct: 複製整個值\n"
        output += "  - 小型 struct 快速\n"
        output += "  - 大型 struct 可能較慢\n\n"
        
        output += "• Class: 只複製引用\n"
        output += "  - 固定開銷（8 bytes on 64-bit）\n"
        output += "  - 大型對象更有效率\n\n"
        
        output += "=== 使用建議 ===\n"
        output += "✅ 使用 Struct:\n"
        output += "  • 簡單資料模型\n"
        output += "  • 需要值語義\n"
        output += "  • 不需要繼承\n\n"
        
        output += "✅ 使用 Class:\n"
        output += "  • 需要繼承\n"
        output += "  • 需要引用語義\n"
        output += "  • 複雜對象模型\n"
        output += "  • UIKit 組件\n"
        
        let resultLabel = createResultLabel(output)
        stackView.addArrangedSubview(resultLabel)
    }
    
    // MARK: - Helper Methods
    private func createTitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.textColor = .systemBlue
        return label
    }
    
    private func createResultLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .label
        
        // Add background and padding
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        
        // Create container view for padding
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return label
    }
}

// MARK: - Protocol Example
// 演示 Struct 和 Class 都可以遵循 Protocol

protocol Describable {
    func describe() -> String
}

struct DescribablePoint: Describable {
    var x: Double
    var y: Double
    
    func describe() -> String {
        return "Point at (\(x), \(y))"
    }
}

class Circle: Describable {
    var radius: Double
    
    init(radius: Double) {
        self.radius = radius
    }
    
    func describe() -> String {
        return "Circle with radius \(radius)"
    }
}



