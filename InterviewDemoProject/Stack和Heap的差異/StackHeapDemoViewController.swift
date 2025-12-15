//
//  StackHeapDemoViewController.swift
//  InterviewDemoProject
//
//  Demonstrates the differences between Stack and Heap memory allocation
//  展示 Stack 和 Heap 記憶體分配的差異
//

import UIKit

// MARK: - Value Type (Stored on Stack)
// 值型別 - 存儲在 Stack 上
struct Point {
    var x: Double
    var y: Double
}

struct Rectangle {
    var origin: Point
    var width: Double
    var height: Double
}

// MARK: - Reference Type (Stored on Heap)
// 引用型別 - 存儲在 Heap 上
class HeapPerson {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
        print("Person '\(name)' allocated on Heap")
    }
    
    deinit {
        print("Person '\(name)' deallocated from Heap")
    }
}

// MARK: - Mixed Type
// 混合型別 - 展示 Stack 和 Heap 的混合使用
struct Employee {
    var id: Int              // Stack (as part of struct)
    var position: String     // Stack (pointer), actual string may be on Heap
    var manager: HeapPerson?     // Stack (pointer), HeapPerson instance on Heap
}

class HeapCompany {
    var name: String         // Heap (as part of class instance)
    var address: Point       // Heap (as part of class instance, even though Point is a struct)
    
    init(name: String, address: Point) {
        self.name = name
        self.address = address
        print("Company '\(name)' allocated on Heap")
    }
    
    deinit {
        print("Company '\(name)' deallocated from Heap")
    }
}

// MARK: - Main View Controller
class StackHeapDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let outputTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Add navigation bar button to run all demos
        // 添加導航欄按鈕以運行所有演示
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Run Demos",
            style: .plain,
            target: self,
            action: #selector(runAllDemos)
        )
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Stack vs Heap Demo"
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup output text view
        // 設置輸出文字視圖
        outputTextView.translatesAutoresizingMaskIntoConstraints = false
        outputTextView.isEditable = false
        outputTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        outputTextView.backgroundColor = .systemGray6
        outputTextView.layer.cornerRadius = 8
        outputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        contentView.addSubview(outputTextView)
        
        // Setup demo buttons
        // 設置演示按鈕
        let buttonTitles = [
            "1. Stack Memory Demo",
            "2. Heap Memory Demo",
            "3. Value vs Reference",
            "4. Copy Behavior",
            "5. Memory Lifecycle",
            "6. Performance Test",
            "7. Mixed Types",
            "Clear Output"
        ]
        
        var previousButton: UIButton?
        
        for (index, title) in buttonTitles.enumerated() {
            let button = createButton(title: title, tag: index)
            contentView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                button.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            if let previous = previousButton {
                button.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 12).isActive = true
            } else {
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
            }
            
            previousButton = button
        }
        
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
            
            outputTextView.topAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: 20),
            outputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            outputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            outputTextView.heightAnchor.constraint(equalToConstant: 300),
            outputTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Button Actions
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0: demo1_StackMemory()
        case 1: demo2_HeapMemory()
        case 2: demo3_ValueVsReference()
        case 3: demo4_CopyBehavior()
        case 4: demo5_MemoryLifecycle()
        case 5: demo6_PerformanceTest()
        case 6: demo7_MixedTypes()
        case 7: outputTextView.text = ""
        default: break
        }
    }
    
    @objc private func runAllDemos() {
        outputTextView.text = ""
        let demos = [
            demo1_StackMemory,
            demo2_HeapMemory,
            demo3_ValueVsReference,
            demo4_CopyBehavior,
            demo5_MemoryLifecycle,
            demo6_PerformanceTest,
            demo7_MixedTypes
        ]
        
        for demo in demos {
            demo()
            log("") // Empty line between demos
        }
    }
    
    // MARK: - Demo 1: Stack Memory
    // Stack 記憶體特性演示
    private func demo1_StackMemory() {
        log("=== Demo 1: Stack Memory ===")
        log("Stack stores value types (struct, enum, tuples)")
        log("")
        
        // Simple value types on stack
        // 簡單的值型別存儲在 Stack
        let number: Int = 42                    // Stored on Stack
        let decimal: Double = 3.14              // Stored on Stack
        let flag: Bool = true                   // Stored on Stack
        
        log("Simple values on Stack:")
        log("  number: \(number)")
        log("  decimal: \(decimal)")
        log("  flag: \(flag)")
        log("")
        
        // Struct on stack
        // Struct 存儲在 Stack
        let point = Point(x: 10, y: 20)
        let rect = Rectangle(origin: point, width: 100, height: 50)
        
        log("Structs on Stack:")
        log("  point: (\(point.x), \(point.y))")
        log("  rect: origin(\(rect.origin.x), \(rect.origin.y)), size(\(rect.width), \(rect.height))")
        log("")
        
        // All these are automatically cleaned up when function ends
        // 當函數結束時，這些變量會自動從 Stack 清理
        log("✓ All stack variables will be automatically cleaned up when scope ends")
        log("✓ No ARC overhead, no memory management needed")
        log("✓ Extremely fast allocation and deallocation")
    }
    
    // MARK: - Demo 2: Heap Memory
    // Heap 記憶體特性演示
    private func demo2_HeapMemory() {
        log("=== Demo 2: Heap Memory ===")
        log("Heap stores reference types (class instances)")
        log("")
        
        // Class instance on heap
        // Class 實例存儲在 Heap
        log("Creating Person instances on Heap:")
        let person1 = HeapPerson(name: "Alice", age: 30)
        let person2 = HeapPerson(name: "Bob", age: 25)
        
        log("")
        log("Person instances info:")
        log("  person1: \(person1.name), age \(person1.age)")
        log("  person2: \(person2.name), age \(person2.age)")
        log("")
        
        // The variables person1, person2 are pointers on Stack
        // But the actual Person objects are on Heap
        // 變量 person1, person2 是 Stack 上的指針
        // 但實際的 Person 對象在 Heap 上
        log("Memory layout:")
        log("  Stack: person1 (pointer) -> Heap: Person('Alice')")
        log("  Stack: person2 (pointer) -> Heap: Person('Bob')")
        log("")
        
        log("✓ Heap memory is managed by ARC")
        log("✓ Slower allocation compared to Stack")
        log("✓ Objects persist until no references remain")
    }
    
    // MARK: - Demo 3: Value vs Reference Semantics
    // 值語義 vs 引用語義
    private func demo3_ValueVsReference() {
        log("=== Demo 3: Value vs Reference Semantics ===")
        log("")
        
        // Value type (Stack) - Copy semantics
        // 值型別（Stack）- 複製語義
        log("Value Type (Struct on Stack):")
        var point1 = Point(x: 10, y: 20)
        var point2 = point1  // Creates a copy
        point2.x = 999
        
        log("  point1: (\(point1.x), \(point1.y))")
        log("  point2: (\(point2.x), \(point2.y))")
        log("  ✓ Changing point2 doesn't affect point1 (separate copies)")
        log("")
        
        // Reference type (Heap) - Reference semantics
        // 引用型別（Heap）- 引用語義
        log("Reference Type (Class on Heap):")
        let person1 = HeapPerson(name: "Charlie", age: 35)
        let person2 = person1  // Shares the same instance
        person2.age = 40
        
        log("  person1.age: \(person1.age)")
        log("  person2.age: \(person2.age)")
        log("  ✓ Changing person2 affects person1 (same instance)")
        log("")
        
        // Identity check
        // 身份檢查
        log("Identity check:")
        log("  person1 === person2: \(person1 === person2)")
        log("  (They reference the same object in Heap)")
    }
    
    // MARK: - Demo 4: Copy Behavior
    // 複製行為演示
    private func demo4_CopyBehavior() {
        log("=== Demo 4: Copy Behavior ===")
        log("")
        
        // Stack allocation and copy
        // Stack 分配與複製
        log("Stack: Creating and copying a Rectangle")
        let startTime1 = CFAbsoluteTimeGetCurrent()
        
        var rect1 = Rectangle(
            origin: Point(x: 0, y: 0),
            width: 100,
            height: 200
        )
        
        // This creates a full copy of the struct
        // 這會創建 struct 的完整副本
        var rect2 = rect1
        rect2.width = 999
        
        let endTime1 = CFAbsoluteTimeGetCurrent()
        
        log("  rect1.width: \(rect1.width)")
        log("  rect2.width: \(rect2.width)")
        log("  Time: \((endTime1 - startTime1) * 1_000_000) μs")
        log("  ✓ Full copy made, independent instances")
        log("")
        
        // Heap allocation and reference copy
        // Heap 分配與引用複製
        log("Heap: Creating and copying a Person")
        let startTime2 = CFAbsoluteTimeGetCurrent()
        
        let person1 = HeapPerson(name: "Diana", age: 28)
        
        // This only copies the pointer, not the object
        // 這只複製指針，不複製對象
        let person2 = person1
        
        let endTime2 = CFAbsoluteTimeGetCurrent()
        
        log("  Reference count increased for same object")
        log("  Time: \((endTime2 - startTime2) * 1_000_000) μs")
        log("  ✓ Only pointer copied, shared instance")
        log("")
        
        log("Performance note:")
        log("  Stack copy: Copies all data (fast for small structs)")
        log("  Heap copy: Only copies pointer (always fast, but has ARC overhead)")
    }
    
    // MARK: - Demo 5: Memory Lifecycle
    // 記憶體生命週期演示
    private func demo5_MemoryLifecycle() {
        log("=== Demo 5: Memory Lifecycle ===")
        log("")
        
        log("Stack lifecycle:")
        log("Creating inner scope...")
        
        do {
            let stackValue = Point(x: 100, y: 200)
            log("  Inside scope: point exists on Stack")
            log("  point: (\(stackValue.x), \(stackValue.y))")
        }
        // stackValue is automatically removed from Stack here
        // stackValue 在這裡自動從 Stack 移除
        
        log("  After scope: point automatically removed from Stack")
        log("  ✓ No memory management needed")
        log("")
        
        log("Heap lifecycle:")
        log("Creating Person in inner scope...")
        
        do {
            let heapObject = HeapPerson(name: "Eve", age: 32)
            log("  Inside scope: Person instance on Heap, pointer on Stack")
            log("  Reference count: 1")
        }
        // Pointer removed from Stack, but Person object remains in Heap
        // until ARC determines it's no longer needed
        // 指針從 Stack 移除，但 Person 對象保留在 Heap 中
        // 直到 ARC 確定不再需要它
        
        log("  After scope: Pointer removed from Stack")
        log("  Reference count becomes 0")
        log("  ARC will deallocate Person from Heap")
        log("  (See deinit message above)")
        log("")
        
        log("Key difference:")
        log("  Stack: Immediate cleanup when scope ends")
        log("  Heap: Cleanup when reference count reaches 0")
    }
    
    // MARK: - Demo 6: Performance Test
    // 性能測試
    private func demo6_PerformanceTest() {
        log("=== Demo 6: Performance Comparison ===")
        log("Testing allocation/deallocation speed...")
        log("")
        
        let iterations = 100_000
        
        // Test Stack allocation (struct)
        // 測試 Stack 分配（struct）
        let stackStart = CFAbsoluteTimeGetCurrent()
        for i in 0..<iterations {
            let _ = Point(x: Double(i), y: Double(i * 2))
            // Automatically deallocated immediately
            // 自動立即釋放
        }
        let stackEnd = CFAbsoluteTimeGetCurrent()
        let stackTime = (stackEnd - stackStart) * 1000
        
        log("Stack allocation (\(iterations) iterations):")
        log("  Time: \(String(format: "%.3f", stackTime)) ms")
        log("  Average: \(String(format: "%.6f", stackTime * 1000 / Double(iterations))) μs per allocation")
        log("")
        
        // Test Heap allocation (class)
        // 測試 Heap 分配（class）
        let heapStart = CFAbsoluteTimeGetCurrent()
        for i in 0..<iterations {
            let _ = HeapPerson(name: "Person\(i)", age: i)
            // Will be deallocated by ARC later
            // 稍後會被 ARC 釋放
        }
        let heapEnd = CFAbsoluteTimeGetCurrent()
        let heapTime = (heapEnd - heapStart) * 1000
        
        log("Heap allocation (\(iterations) iterations):")
        log("  Time: \(String(format: "%.3f", heapTime)) ms")
        log("  Average: \(String(format: "%.6f", heapTime * 1000 / Double(iterations))) μs per allocation")
        log("")
        
        let ratio = heapTime / stackTime
        log("Performance ratio:")
        log("  Heap is ~\(String(format: "%.1f", ratio))x slower than Stack")
        log("")
        log("Reasons for Heap overhead:")
        log("  • Memory allocation search")
        log("  • Reference counting (ARC)")
        log("  • Thread synchronization")
        log("  • Indirect memory access")
    }
    
    // MARK: - Demo 7: Mixed Types
    // 混合型別演示
    private func demo7_MixedTypes() {
        log("=== Demo 7: Mixed Types (Stack + Heap) ===")
        log("")
        
        // Struct containing a class reference
        // 包含 class 引用的 Struct
        log("Employee struct (Stack) with Person reference (Heap):")
        let manager = HeapPerson(name: "Manager Frank", age: 45)
        var employee = Employee(id: 1001, position: "Developer", manager: manager)
        
        log("  employee.id: \(employee.id) (on Stack)")
        log("  employee.position: \(employee.position) (pointer on Stack)")
        log("  employee.manager: \(employee.manager?.name ?? "nil") (pointer on Stack -> Person on Heap)")
        log("")
        
        // Class containing a struct
        // 包含 struct 的 Class
        log("Company class (Heap) with Point struct:")
        let office = HeapCompany(name: "Tech Corp", address: Point(x: 123.45, y: 678.90))
        
        log("  company.name: \(office.name) (on Heap)")
        log("  company.address: (\(office.address.x), \(office.address.y)) (on Heap as part of Company)")
        log("")
        
        log("Memory layout explanation:")
        log("  Employee (struct):")
        log("    - Employee instance: Stack")
        log("    - id field: Stack (part of struct)")
        log("    - position string pointer: Stack")
        log("    - manager pointer: Stack -> Person instance on Heap")
        log("")
        log("  Company (class):")
        log("    - Company pointer: Stack")
        log("    - Company instance: Heap")
        log("    - name field: Heap (part of instance)")
        log("    - address field: Heap (embedded in instance)")
        log("")
        log("Key insight:")
        log("  Where a struct lives depends on its container:")
        log("  • Standalone struct -> Stack")
        log("  • Struct in class -> Heap (as part of class)")
        log("  • Class always -> Heap")
    }
    
    // MARK: - Helper Methods
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let newText = "[\(timestamp)] \(message)\n"
        outputTextView.text += newText
        
        // Auto-scroll to bottom
        // 自動滾動到底部
        let range = NSRange(location: outputTextView.text.count - 1, length: 1)
        outputTextView.scrollRangeToVisible(range)
    }
}


