//
//  RuntimeDemoViewController.swift
//  InterviewDemoProject
//
//  Runtime 數據結構演示
//

import UIKit

class RuntimeDemoViewController: UIViewController {
    
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
        label.text = "Runtime 數據結構演示"
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
        title = "Runtime 數據結構"
        
        // Setup scrollView
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup contentStackView
        scrollView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Add title
        contentStackView.addArrangedSubview(titleLabel)
        
        // Add output textView
        contentStackView.addArrangedSubview(outputTextView)
        outputTextView.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    private func setupButtons() {
        let buttonTitles = [
            "1. 獲取類的基本信息",
            "2. 獲取方法列表",
            "3. 獲取屬性列表",
            "4. 獲取成員變量列表",
            "5. 動態添加方法",
            "6. 方法交換 (Method Swizzling)",
            "7. 獲取類的繼承鏈",
            "8. 演示 isa 指針關係",
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
            demonstrateClassInfo()
        case 1:
            demonstrateMethodList()
        case 2:
            demonstratePropertyList()
        case 3:
            demonstrateIvarList()
        case 4:
            demonstrateDynamicMethodAddition()
        case 5:
            demonstrateMethodSwizzling()
        case 6:
            demonstrateClassHierarchy()
        case 7:
            demonstrateIsaPointer()
        case 8:
            outputText = ""
        default:
            break
        }
    }
    
    // MARK: - Runtime Demonstrations
    
    /// 1. 獲取類的基本信息
    private func demonstrateClassInfo() {
        appendOutput("=== 獲取類的基本信息 ===\n")
        
        let person = RuntimePerson(name: "張三", age: 25)
        
        // 獲取類名
        let className = NSStringFromClass(type(of: person))
        appendOutput("類名: \(className)")
        
        // 獲取父類
        if let superClass = class_getSuperclass(RuntimePerson.self) {
            let superClassName = NSStringFromClass(superClass)
            appendOutput("父類: \(superClassName)")
        }
        
        // 獲取實例大小
        let instanceSize = class_getInstanceSize(RuntimePerson.self)
        appendOutput("實例大小: \(instanceSize) bytes")
        
        // 判斷是否是元類
        let isMetaClass = class_isMetaClass(RuntimePerson.self)
        appendOutput("是否為元類: \(isMetaClass)")
        
        // 獲取元類
        if let metaClass = objc_getMetaClass(className.cString(using: .utf8)!) as? AnyClass {
            let metaClassName = NSStringFromClass(metaClass)
            appendOutput("元類: \(metaClassName)")
        }
        
        appendOutput("\n✅ 說明: objc_class 結構包含了類的基本信息，如類名、父類、實例大小等。")
    }
    
    /// 2. 獲取方法列表
    private func demonstrateMethodList() {
        appendOutput("=== 獲取方法列表 ===\n")
        
        var methodCount: UInt32 = 0
        guard let methods = class_copyMethodList(RuntimePerson.self, &methodCount) else {
            appendOutput("無法獲取方法列表")
            return
        }
        
        appendOutput("RuntimePerson 類共有 \(methodCount) 個實例方法:\n")
        
        for i in 0..<Int(methodCount) {
            let method = methods[i]
            
            // 獲取方法選擇器 (SEL)
            let selector = method_getName(method)
            let methodName = NSStringFromSelector(selector)
            
            // 獲取方法實現 (IMP)
            let imp = method_getImplementation(method)
            
            // 獲取方法類型編碼
            if let typeEncoding = method_getTypeEncoding(method) {
                let encoding = String(cString: typeEncoding)
                appendOutput("\(i+1). \(methodName)")
                appendOutput("   SEL: \(selector)")
                appendOutput("   IMP: \(imp)")
                appendOutput("   Type: \(encoding)")
            }
        }
        
        free(methods)
        
        // 獲取類方法
        appendOutput("\n--- 類方法 ---\n")
        var classMethodCount: UInt32 = 0
        if let metaClass = objc_getMetaClass("RuntimePerson") as? AnyClass,
           let classMethods = class_copyMethodList(metaClass, &classMethodCount) {
            appendOutput("共有 \(classMethodCount) 個類方法:\n")
            for i in 0..<Int(classMethodCount) {
                let method = classMethods[i]
                let selector = method_getName(method)
                let methodName = NSStringFromSelector(selector)
                appendOutput("\(i+1). \(methodName)")
            }
            free(classMethods)
        }
        
        appendOutput("\n✅ 說明: method_t 結構包含 SEL(方法選擇器)、IMP(方法實現) 和類型編碼。")
    }
    
    /// 3. 獲取屬性列表
    private func demonstratePropertyList() {
        appendOutput("=== 獲取屬性列表 ===\n")
        
        var propertyCount: UInt32 = 0
        guard let properties = class_copyPropertyList(RuntimePerson.self, &propertyCount) else {
            appendOutput("無法獲取屬性列表")
            return
        }
        
        appendOutput("RuntimePerson 類共有 \(propertyCount) 個屬性:\n")
        
        for i in 0..<Int(propertyCount) {
            let property = properties[i]
            
            // 獲取屬性名
            let propertyName = String(cString: property_getName(property))
            
            // 獲取屬性特性
            if let attributes = property_getAttributes(property) {
                let attributesString = String(cString: attributes)
                appendOutput("\(i+1). \(propertyName)")
                appendOutput("   特性: \(attributesString)")
                
                // 解析屬性特性
                parsePropertyAttributes(attributesString)
            }
        }
        
        free(properties)
        
        appendOutput("\n✅ 說明: property_t 結構包含屬性名和屬性特性(如 T@\"NSString\",C,N,V_name)。")
    }
    
    /// 解析屬性特性
    private func parsePropertyAttributes(_ attributes: String) {
        let components = attributes.components(separatedBy: ",")
        for component in components {
            if component.hasPrefix("T") {
                appendOutput("   類型: \(component)")
            } else if component == "N" {
                appendOutput("   特性: nonatomic")
            } else if component == "&" {
                appendOutput("   特性: strong")
            } else if component == "C" {
                appendOutput("   特性: copy")
            } else if component.hasPrefix("V") {
                appendOutput("   成員變量名: \(component)")
            }
        }
    }
    
    /// 4. 獲取成員變量列表
    private func demonstrateIvarList() {
        appendOutput("=== 獲取成員變量列表 ===\n")
        
        var ivarCount: UInt32 = 0
        guard let ivars = class_copyIvarList(RuntimePerson.self, &ivarCount) else {
            appendOutput("無法獲取成員變量列表")
            return
        }
        
        appendOutput("RuntimePerson 類共有 \(ivarCount) 個成員變量:\n")
        
        for i in 0..<Int(ivarCount) {
            let ivar = ivars[i]
            
            // 獲取成員變量名
            if let ivarName = ivar_getName(ivar) {
                let name = String(cString: ivarName)
                
                // 獲取成員變量類型編碼
                if let typeEncoding = ivar_getTypeEncoding(ivar) {
                    let encoding = String(cString: typeEncoding)
                    
                    // 獲取偏移量
                    let offset = ivar_getOffset(ivar)
                    
                    appendOutput("\(i+1). \(name)")
                    appendOutput("   類型編碼: \(encoding)")
                    appendOutput("   偏移量: \(offset)")
                }
            }
        }
        
        free(ivars)
        
        appendOutput("\n✅ 說明: ivar_t 結構包含成員變量名、類型編碼、偏移量等信息。")
    }
    
    /// 5. 動態添加方法
    private func demonstrateDynamicMethodAddition() {
        appendOutput("=== 動態添加方法 ===\n")
        
        // 定義要添加的方法實現
        let dynamicMethodIMP: @convention(c) (AnyObject, Selector) -> Void = { (self, _cmd) in
            print("這是動態添加的方法!")
        }
        
        // 添加方法
        let selector = #selector(RuntimePerson.dynamicMethod)
        let success = class_addMethod(
            RuntimePerson.self,
            selector,
            unsafeBitCast(dynamicMethodIMP, to: IMP.self),
            "v@:"  // 返回值 void，參數 id self, SEL _cmd
        )
        
        if success {
            appendOutput("✅ 成功添加方法: dynamicMethod")
            
            // 調用動態添加的方法
            let person = RuntimePerson(name: "李四", age: 30)
            if person.responds(to: selector) {
                person.perform(selector)
                appendOutput("✅ 成功調用動態添加的方法")
            }
        } else {
            appendOutput("❌ 添加方法失敗（可能方法已存在）")
        }
        
        appendOutput("\n✅ 說明: 可以在運行時動態為類添加新方法，這是 Runtime 動態性的體現。")
    }
    
    /// 6. 方法交換 (Method Swizzling)
    private func demonstrateMethodSwizzling() {
        appendOutput("=== 方法交換 (Method Swizzling) ===\n")
        
        let person = RuntimePerson(name: "王五", age: 28)
        
        appendOutput("交換前:")
        person.sayHello()
        person.walk()
        
        // 獲取原始方法
        let originalSelector = #selector(RuntimePerson.sayHello)
        let swizzledSelector = #selector(RuntimePerson.walk)
        
        guard let originalMethod = class_getInstanceMethod(RuntimePerson.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(RuntimePerson.self, swizzledSelector) else {
            appendOutput("❌ 無法獲取方法")
            return
        }
        
        // 交換方法實現
        method_exchangeImplementations(originalMethod, swizzledMethod)
        
        appendOutput("\n交換後:")
        person.sayHello()  // 實際會調用 walk 的實現
        person.walk()      // 實際會調用 sayHello 的實現
        
        // 恢復原狀（再次交換）
        method_exchangeImplementations(originalMethod, swizzledMethod)
        
        appendOutput("\n✅ 說明: Method Swizzling 通過交換兩個方法的 IMP 來改變方法的實現。")
        appendOutput("⚠️ 注意: 實際應用中需謹慎使用，避免造成難以調試的問題。")
    }
    
    /// 7. 獲取類的繼承鏈
    private func demonstrateClassHierarchy() {
        appendOutput("=== 類的繼承鏈 ===\n")
        
        var currentClass: AnyClass? = RuntimePerson.self
        var level = 0
        
        appendOutput("RuntimePerson 的繼承鏈:\n")
        
        while currentClass != nil {
            let className = NSStringFromClass(currentClass!)
            let indent = String(repeating: "  ", count: level)
            appendOutput("\(indent)↓ \(className)")
            
            currentClass = class_getSuperclass(currentClass!)
            level += 1
        }
        
        appendOutput("\n✅ 說明: objc_class 結構中的 superclass 指針形成了類的繼承鏈。")
    }
    
    /// 8. 演示 isa 指針關係
    private func demonstrateIsaPointer() {
        appendOutput("=== isa 指針關係 ===\n")
        
        let person = RuntimePerson(name: "趙六", age: 35)
        
        // 獲取對象的類
        let objectClass = type(of: person)
        appendOutput("1. 實例對象: person")
        appendOutput("   person.isa → \(NSStringFromClass(objectClass))\n")
        
        // 獲取類的元類
        let className = NSStringFromClass(objectClass)
        if let metaClass = objc_getMetaClass(className.cString(using: .utf8)!) as? AnyClass {
            appendOutput("2. 類: \(className)")
            appendOutput("   RuntimePerson.isa → \(NSStringFromClass(metaClass))\n")
        }
        
        appendOutput("isa 指針鏈:")
        appendOutput("實例對象 → 類 → 元類 → 根元類 → 根元類自己\n")
        
        appendOutput("說明:")
        appendOutput("• 實例對象的 isa 指向類")
        appendOutput("• 類的 isa 指向元類")
        appendOutput("• 元類的 isa 指向根元類")
        appendOutput("• 根元類的 isa 指向自己")
        appendOutput("\n• 實例方法存儲在類中")
        appendOutput("• 類方法存儲在元類中")
        
        appendOutput("\n✅ 說明: isa 指針是 objc_object 結構的核心，連接了對象、類、元類。")
    }
    
    // MARK: - Helper Methods
    
    private func appendOutput(_ text: String) {
        outputText += text + "\n"
    }
}

// MARK: - RuntimePerson Extension for Dynamic Method

extension RuntimePerson {
    @objc dynamic func dynamicMethod() {
        // 這個方法會被動態添加的實現替換
    }
}

