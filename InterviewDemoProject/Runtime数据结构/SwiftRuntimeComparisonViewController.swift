//
//  SwiftRuntimeComparisonViewController.swift
//  InterviewDemoProject
//
//  演示 Swift 純類 vs NSObject 子類在 Runtime 上的區別
//

import UIKit

// MARK: - 純 Swift 類（不支持 OC Runtime）
class PureSwiftPerson {
    var name: String
    var age: Int
    private var hobby: String?
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func sayHello() {
        print("Hello from Pure Swift!")
    }
    
    func walk() {
        print("\(name) is walking")
    }
}

// MARK: - NSObject 子類（支持 OC Runtime）
@objcMembers class ObjCSwiftPerson: NSObject {
    var name: String
    var age: Int
    private var hobby: String?
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
        super.init()
    }
    
    func sayHello() {
        print("Hello from ObjC Swift!")
    }
    
    @objc dynamic func walk() {
        print("\(name) is walking")
    }
}

// MARK: - View Controller
class SwiftRuntimeComparisonViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Swift Runtime 對比演示"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let outputTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 8
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return textView
    }()
    
    private var outputText = "" {
        didSet {
            outputTextView.text = outputText
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtons()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Swift Runtime 對比"
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(outputTextView)
        outputTextView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    }
    
    private func setupButtons() {
        let buttonTitles = [
            "1. 對比：獲取方法列表",
            "2. 對比：獲取屬性列表",
            "3. 對比：Method Swizzling",
            "4. Swift Mirror API 演示",
            "5. 方法派發機制對比",
            "6. 性能測試對比",
            "清空輸出"
        ]
        
        for (index, title) in buttonTitles.enumerated() {
            let button = createButton(title: title, tag: index)
            contentStackView.addArrangedSubview(button)
        }
    }
    
    private func createButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.tag = tag
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    // MARK: - Button Actions
    
    @objc private func buttonTapped(_ sender: UIButton) {
        outputText = ""
        
        switch sender.tag {
        case 0:
            compareMethodList()
        case 1:
            comparePropertyList()
        case 2:
            compareMethodSwizzling()
        case 3:
            demonstrateMirrorAPI()
        case 4:
            compareDispatchMechanism()
        case 5:
            comparePerformance()
        case 6:
            outputText = ""
        default:
            break
        }
    }
    
    // MARK: - Demonstrations
    
    /// 1. 對比獲取方法列表
    private func compareMethodList() {
        appendOutput("=== 對比：獲取方法列表 ===\n")
        
        // 純 Swift 類
        appendOutput("【純 Swift 類】PureSwiftPerson:")
        var pureSwiftMethodCount: UInt32 = 0
        let pureSwiftMethods = class_copyMethodList(PureSwiftPerson.self, &pureSwiftMethodCount)
        
        if pureSwiftMethodCount == 0 || pureSwiftMethods == nil {
            appendOutput("❌ 無法獲取方法列表")
            appendOutput("原因: 純 Swift 類不使用 Objective-C Runtime\n")
        } else {
            appendOutput("✅ 獲取到 \(pureSwiftMethodCount) 個方法\n")
            free(pureSwiftMethods)
        }
        
        // NSObject 子類
        appendOutput("【NSObject 子類】ObjCSwiftPerson:")
        var objcMethodCount: UInt32 = 0
        guard let objcMethods = class_copyMethodList(ObjCSwiftPerson.self, &objcMethodCount) else {
            appendOutput("❌ 無法獲取方法列表\n")
            return
        }
        
        appendOutput("✅ 獲取到 \(objcMethodCount) 個方法:")
        for i in 0..<Int(objcMethodCount) {
            let method = objcMethods[i]
            let selector = method_getName(method)
            let methodName = NSStringFromSelector(selector)
            appendOutput("  \(i+1). \(methodName)")
        }
        free(objcMethods)
        
        appendOutput("\n📌 結論:")
        appendOutput("• 純 Swift 類使用自己的元數據，OC Runtime API 無效")
        appendOutput("• NSObject 子類橋接到 OC Runtime，可以使用所有 Runtime API")
    }
    
    /// 2. 對比獲取屬性列表
    private func comparePropertyList() {
        appendOutput("=== 對比：獲取屬性列表 ===\n")
        
        // 純 Swift 類
        appendOutput("【純 Swift 類】PureSwiftPerson:")
        var pureSwiftPropertyCount: UInt32 = 0
        let pureSwiftProperties = class_copyPropertyList(PureSwiftPerson.self, &pureSwiftPropertyCount)
        
        if pureSwiftPropertyCount == 0 || pureSwiftProperties == nil {
            appendOutput("❌ 無法獲取屬性列表")
            appendOutput("原因: 純 Swift 類的屬性不暴露給 OC Runtime\n")
        } else {
            appendOutput("✅ 獲取到 \(pureSwiftPropertyCount) 個屬性\n")
            free(pureSwiftProperties)
        }
        
        // NSObject 子類
        appendOutput("【NSObject 子類】ObjCSwiftPerson:")
        var objcPropertyCount: UInt32 = 0
        guard let objcProperties = class_copyPropertyList(ObjCSwiftPerson.self, &objcPropertyCount) else {
            appendOutput("❌ 無法獲取屬性列表\n")
            return
        }
        
        appendOutput("✅ 獲取到 \(objcPropertyCount) 個屬性:")
        for i in 0..<Int(objcPropertyCount) {
            let property = objcProperties[i]
            let propertyName = String(cString: property_getName(property))
            if let attributes = property_getAttributes(property) {
                let attributesString = String(cString: attributes)
                appendOutput("  \(i+1). \(propertyName) - \(attributesString)")
            }
        }
        free(objcProperties)
        
        appendOutput("\n📌 結論:")
        appendOutput("• @objcMembers 修飾符將所有屬性暴露給 OC Runtime")
        appendOutput("• 純 Swift 類需要使用 Mirror API 進行反射")
    }
    
    /// 3. 對比 Method Swizzling
    private func compareMethodSwizzling() {
        appendOutput("=== 對比：Method Swizzling ===\n")
        
        // 純 Swift 類嘗試
        appendOutput("【純 Swift 類】嘗試 Method Swizzling:")
        appendOutput("❌ 不支持 Method Swizzling")
        appendOutput("原因: 純 Swift 類使用虛表派發，不走消息派發機制\n")
        
        // NSObject 子類 + dynamic
        appendOutput("【NSObject 子類 + @objc dynamic】:")
        
        let person = ObjCSwiftPerson(name: "張三", age: 25)
        
        appendOutput("交換前:")
        person.walk()  // 輸出到控制台
        appendOutput("調用 walk() -> 輸出: '\(person.name) is walking'\n")
        
        // 獲取方法
        let originalSelector = #selector(ObjCSwiftPerson.walk)
        let swizzledSelector = #selector(ObjCSwiftPerson.swizzled_walk)
        
        // 動態添加交換方法
        let swizzledIMP: @convention(c) (ObjCSwiftPerson, Selector) -> Void = { (self, _cmd) in
            print("🔄 方法已被交換! \(self.name) 現在在跑步")
        }
        
        let didAdd = class_addMethod(
            ObjCSwiftPerson.self,
            swizzledSelector,
            unsafeBitCast(swizzledIMP, to: IMP.self),
            "v@:"
        )
        
        if didAdd {
            if let originalMethod = class_getInstanceMethod(ObjCSwiftPerson.self, originalSelector),
               let swizzledMethod = class_getInstanceMethod(ObjCSwiftPerson.self, swizzledSelector) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
                
                appendOutput("✅ Method Swizzling 成功!")
                appendOutput("交換後:")
                person.walk()  // 現在會調用交換後的實現
                appendOutput("調用 walk() -> 輸出: '🔄 方法已被交換!'\n")
                
                // 恢復原狀
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
        
        appendOutput("📌 結論:")
        appendOutput("• 必須同時滿足: 繼承 NSObject + @objc + dynamic")
        appendOutput("• dynamic 關鍵字強制使用消息派發")
        appendOutput("• 純 Swift 類無法進行 Method Swizzling")
    }
    
    /// 4. Swift Mirror API 演示
    private func demonstrateMirrorAPI() {
        appendOutput("=== Swift Mirror API 演示 ===\n")
        
        // 純 Swift 類也可以使用 Mirror
        appendOutput("【純 Swift 類】使用 Mirror API:")
        let pureSwiftPerson = PureSwiftPerson(name: "李四", age: 30)
        let pureMirror = Mirror(reflecting: pureSwiftPerson)
        
        appendOutput("類型: \(pureMirror.subjectType)")
        appendOutput("屬性列表:")
        for (index, child) in pureMirror.children.enumerated() {
            let label = child.label ?? "unknown"
            let value = child.value
            appendOutput("  \(index+1). \(label): \(value)")
        }
        
        appendOutput("\n【NSObject 子類】使用 Mirror API:")
        let objcPerson = ObjCSwiftPerson(name: "王五", age: 28)
        let objcMirror = Mirror(reflecting: objcPerson)
        
        appendOutput("類型: \(objcMirror.subjectType)")
        appendOutput("屬性列表:")
        for (index, child) in objcMirror.children.enumerated() {
            let label = child.label ?? "unknown"
            let value = child.value
            appendOutput("  \(index+1). \(label): \(value)")
        }
        
        appendOutput("\n📌 Mirror API 特點:")
        appendOutput("✅ 適用於所有 Swift 類型（包括 struct、enum）")
        appendOutput("✅ 可以讀取屬性值")
        appendOutput("❌ 只能讀取，不能修改")
        appendOutput("❌ 無法獲取方法列表")
        appendOutput("❌ 無法動態添加方法或屬性")
        appendOutput("❌ 性能較低")
    }
    
    /// 5. 方法派發機制對比
    private func compareDispatchMechanism() {
        appendOutput("=== 方法派發機制對比 ===\n")
        
        appendOutput("【1. 直接派發 (Direct Dispatch)】")
        appendOutput("• 用於: final 方法、static 方法、值類型")
        appendOutput("• 特點: 編譯時確定，最快")
        appendOutput("• 性能: 1.0x (基準)")
        appendOutput("• 示例:")
        appendOutput("  struct MyStruct {")
        appendOutput("    func method() { }  // 直接派發")
        appendOutput("  }\n")
        
        appendOutput("【2. 虛表派發 (Table Dispatch)】")
        appendOutput("• 用於: 純 Swift 類的方法")
        appendOutput("• 特點: 使用 vtable，運行時查表")
        appendOutput("• 性能: 1.1x")
        appendOutput("• 示例:")
        appendOutput("  class PureSwiftPerson {")
        appendOutput("    func sayHello() { }  // 虛表派發")
        appendOutput("  }\n")
        
        appendOutput("【3. 消息派發 (Message Dispatch)】")
        appendOutput("• 用於: NSObject 子類、@objc dynamic 方法")
        appendOutput("• 特點: objc_msgSend，最靈活")
        appendOutput("• 性能: 4.4x")
        appendOutput("• 示例:")
        appendOutput("  class ObjCSwiftPerson: NSObject {")
        appendOutput("    @objc dynamic func walk() { }  // 消息派發")
        appendOutput("  }\n")
        
        appendOutput("📌 如何選擇:")
        appendOutput("• 追求性能 → 使用純 Swift 類和 struct")
        appendOutput("• 需要動態性 → 使用 NSObject + @objc dynamic")
        appendOutput("• KVO/Method Swizzling → 必須使用消息派發")
    }
    
    /// 6. 性能測試對比
    private func comparePerformance() {
        appendOutput("=== 性能測試對比 ===\n")
        
        let iterations = 1_000_000
        
        // 測試純 Swift 類
        let pureSwiftPerson = PureSwiftPerson(name: "測試", age: 20)
        let pureSwiftStart = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            pureSwiftPerson.sayHello()
        }
        let pureSwiftTime = CFAbsoluteTimeGetCurrent() - pureSwiftStart
        
        // 測試 NSObject 子類
        let objcPerson = ObjCSwiftPerson(name: "測試", age: 20)
        let objcStart = CFAbsoluteTimeGetCurrent()
        for _ in 0..<iterations {
            objcPerson.sayHello()
        }
        let objcTime = CFAbsoluteTimeGetCurrent() - objcStart
        
        appendOutput("測試次數: \(iterations.formatted()) 次\n")
        
        appendOutput("【純 Swift 類】虛表派發:")
        appendOutput("耗時: \(String(format: "%.4f", pureSwiftTime)) 秒")
        appendOutput("速度: 1.0x (基準)\n")
        
        appendOutput("【NSObject 子類】消息派發:")
        appendOutput("耗時: \(String(format: "%.4f", objcTime)) 秒")
        appendOutput("速度: \(String(format: "%.2f", objcTime / pureSwiftTime))x")
        appendOutput("慢了 \(String(format: "%.1f", (objcTime / pureSwiftTime - 1) * 100))%\n")
        
        appendOutput("📌 結論:")
        if objcTime > pureSwiftTime {
            appendOutput("• 消息派發比虛表派發慢約 \(String(format: "%.0f", (objcTime / pureSwiftTime - 1) * 100))%")
        }
        appendOutput("• 在性能敏感的場景，優先使用純 Swift 類")
        appendOutput("• 需要動態性時才使用 NSObject 子類")
    }
    
    // MARK: - Helper Methods
    
    private func appendOutput(_ text: String) {
        outputText += text + "\n"
    }
}

// MARK: - ObjCSwiftPerson Extension for Swizzling

extension ObjCSwiftPerson {
    @objc dynamic func swizzled_walk() {
        // 這個方法用於 Method Swizzling 演示
    }
}

