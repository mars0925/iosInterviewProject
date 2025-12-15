//
//  GCDDemoViewController.swift
//  InterviewDemoProject
//
//  Demonstrates the usage of GCD (Grand Central Dispatch)
//  including Serial Queue, Concurrent Queue, and Main Queue
//

import UIKit

class GCDDemoViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let outputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Properties
    
    // Create a serial queue - executes tasks one at a time in order
    private let serialQueue = DispatchQueue(label: "com.example.serialQueue")
    
    // Create a concurrent queue - can execute multiple tasks simultaneously
    private let concurrentQueue = DispatchQueue(label: "com.example.concurrentQueue", attributes: .concurrent)
    
    // Counter for demonstrating thread safety
    private var counter = 0
    
    // Thread-safe counter using serial queue
    private var safeCounter = 0
    private let counterQueue = DispatchQueue(label: "com.example.counterQueue")
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "GCD Demo"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
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
        
        // Add demo buttons
        addButton(title: "1. Serial Queue Demo", action: #selector(serialQueueDemo))
        addButton(title: "2. Concurrent Queue Demo", action: #selector(concurrentQueueDemo))
        addButton(title: "3. Main Queue Demo", action: #selector(mainQueueDemo))
        addButton(title: "4. Sync vs Async Demo", action: #selector(syncVsAsyncDemo))
        addButton(title: "5. Background Task + UI Update", action: #selector(backgroundTaskDemo))
        addButton(title: "6. Thread Safety Demo", action: #selector(threadSafetyDemo))
        addButton(title: "7. DispatchGroup Demo", action: #selector(dispatchGroupDemo))
        addButton(title: "8. Barrier Demo", action: #selector(barrierDemo))
        addButton(title: "9. Clear Output", action: #selector(clearOutput))
        
        // Add output text view
        contentStackView.addArrangedSubview(outputTextView)
        NSLayoutConstraint.activate([
            outputTextView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func addButton(title: String, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        contentStackView.addArrangedSubview(button)
    }
    
    // MARK: - Demo Methods
    
    /// Demo 1: Serial Queue - tasks execute one at a time in order
    @objc private func serialQueueDemo() {
        clearOutput()
        appendOutput("=== Serial Queue Demo ===\n")
        appendOutput("Tasks will execute one by one in order\n\n")
        
        // Submit 5 tasks to serial queue
        for i in 1...5 {
            serialQueue.async {
                let threadInfo = Thread.current.isMainThread ? "Main Thread" : "Background Thread"
                self.appendOutput("Task \(i) started on \(threadInfo)")
                Thread.sleep(forTimeInterval: 0.5) // Simulate work
                self.appendOutput("Task \(i) finished\n")
            }
        }
    }
    
    /// Demo 2: Concurrent Queue - multiple tasks can execute simultaneously
    @objc private func concurrentQueueDemo() {
        clearOutput()
        appendOutput("=== Concurrent Queue Demo ===\n")
        appendOutput("Tasks can execute simultaneously\n\n")
        
        // Submit 5 tasks to concurrent queue
        for i in 1...5 {
            concurrentQueue.async {
                let threadInfo = Thread.current.isMainThread ? "Main Thread" : "Background Thread"
                self.appendOutput("Task \(i) started on \(threadInfo)")
                Thread.sleep(forTimeInterval: 0.5) // Simulate work
                self.appendOutput("Task \(i) finished\n")
            }
        }
    }
    
    /// Demo 3: Main Queue - all tasks execute on the main thread
    @objc private func mainQueueDemo() {
        clearOutput()
        appendOutput("=== Main Queue Demo ===\n")
        appendOutput("All tasks execute on main thread\n\n")
        
        // Submit tasks to main queue asynchronously
        for i in 1...3 {
            DispatchQueue.main.async {
                let threadInfo = Thread.current.isMainThread ? "Main Thread" : "Background Thread"
                self.appendOutput("Task \(i) executed on \(threadInfo)\n")
            }
        }
        
        appendOutput("\nNote: Never use sync on main queue from main thread (causes deadlock!)\n")
    }
    
    /// Demo 4: Sync vs Async execution
    @objc private func syncVsAsyncDemo() {
        clearOutput()
        appendOutput("=== Sync vs Async Demo ===\n\n")
        
        appendOutput("Starting async task...\n")
        serialQueue.async {
            Thread.sleep(forTimeInterval: 1)
            self.appendOutput("Async task completed\n")
        }
        appendOutput("Async call returned immediately (non-blocking)\n\n")
        
        // Wait a bit before showing sync example
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.appendOutput("Starting sync task...\n")
            // Use background queue to avoid blocking main thread
            DispatchQueue.global().async {
                self.serialQueue.sync {
                    Thread.sleep(forTimeInterval: 1)
                    self.appendOutput("Sync task completed\n")
                }
                self.appendOutput("Sync call returned after task completed (blocking)\n")
            }
        }
    }
    
    /// Demo 5: Common pattern - background task then UI update
    @objc private func backgroundTaskDemo() {
        clearOutput()
        appendOutput("=== Background Task + UI Update Demo ===\n\n")
        appendOutput("Starting heavy task in background...\n")
        
        // Perform heavy task in background with appropriate QoS
        DispatchQueue.global(qos: .userInitiated).async {
            // Simulate heavy computation
            Thread.sleep(forTimeInterval: 2)
            let result = "Task Result: \(Int.random(in: 1...100))"
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.appendOutput("Heavy task completed!\n")
                self.appendOutput("\(result)\n")
                self.appendOutput("UI updated on main thread\n")
            }
        }
    }
    
    /// Demo 6: Thread Safety - demonstrating race condition and solution
    @objc private func threadSafetyDemo() {
        clearOutput()
        appendOutput("=== Thread Safety Demo ===\n\n")
        
        // Reset counters
        counter = 0
        safeCounter = 0
        
        appendOutput("Incrementing counters 1000 times with concurrent queue...\n\n")
        
        let group = DispatchGroup()
        
        // Unsafe counter - race condition
        for _ in 0..<1000 {
            group.enter()
            concurrentQueue.async {
                self.counter += 1 // Not thread-safe!
                group.leave()
            }
        }
        
        // Safe counter - using serial queue
        for _ in 0..<1000 {
            group.enter()
            counterQueue.async {
                self.safeCounter += 1 // Thread-safe
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.appendOutput("Unsafe Counter Result: \(self.counter) (should be 1000)\n")
            self.appendOutput("Safe Counter Result: \(self.safeCounter) (should be 1000)\n\n")
            self.appendOutput("Notice: Unsafe counter may have race condition!\n")
            self.appendOutput("Safe counter uses serial queue for protection.\n")
        }
    }
    
    /// Demo 7: DispatchGroup - wait for multiple tasks to complete
    @objc private func dispatchGroupDemo() {
        clearOutput()
        appendOutput("=== DispatchGroup Demo ===\n")
        appendOutput("Waiting for multiple tasks to complete...\n\n")
        
        let group = DispatchGroup()
        
        // Task 1
        group.enter()
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1)
            self.appendOutput("Task 1 completed\n")
            group.leave()
        }
        
        // Task 2
        group.enter()
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1.5)
            self.appendOutput("Task 2 completed\n")
            group.leave()
        }
        
        // Task 3
        group.enter()
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.5)
            self.appendOutput("Task 3 completed\n")
            group.leave()
        }
        
        // Notify when all tasks complete
        group.notify(queue: .main) {
            self.appendOutput("\nAll tasks completed!\n")
            self.appendOutput("Now we can proceed with next operation.\n")
        }
    }
    
    /// Demo 8: Barrier - ensure exclusive access for write operations
    @objc private func barrierDemo() {
        clearOutput()
        appendOutput("=== Barrier Demo ===\n")
        appendOutput("Demonstrating thread-safe read/write with barrier...\n\n")
        
        var sharedArray: [Int] = []
        let barrierQueue = DispatchQueue(label: "com.example.barrier", attributes: .concurrent)
        
        // Multiple read operations (can execute concurrently)
        for i in 1...3 {
            barrierQueue.async {
                Thread.sleep(forTimeInterval: 0.5)
                self.appendOutput("Read operation \(i): array count = \(sharedArray.count)\n")
            }
        }
        
        // Write operation with barrier (executes exclusively)
        barrierQueue.async(flags: .barrier) {
            Thread.sleep(forTimeInterval: 0.5)
            sharedArray.append(100)
            self.appendOutput("\n⚠️ WRITE with barrier: added 100 to array\n\n")
        }
        
        // More read operations after write
        for i in 4...6 {
            barrierQueue.async {
                Thread.sleep(forTimeInterval: 0.5)
                self.appendOutput("Read operation \(i): array count = \(sharedArray.count)\n")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.appendOutput("\nBarrier ensures write completes before subsequent reads.\n")
        }
    }
    
    // MARK: - Helper Methods
    
    @objc private func clearOutput() {
        DispatchQueue.main.async {
            self.outputTextView.text = ""
        }
    }
    
    private func appendOutput(_ text: String) {
        DispatchQueue.main.async {
            self.outputTextView.text += text
            
            // Auto-scroll to bottom
            let range = NSRange(location: self.outputTextView.text.count - 1, length: 1)
            self.outputTextView.scrollRangeToVisible(range)
        }
    }
}

// MARK: - Quality of Service (QoS) Examples

/*
 Quality of Service (QoS) levels from highest to lowest priority:
 
 1. .userInteractive
    - Highest priority
    - Use for: UI updates, animations, event handling
    - Example: DispatchQueue.global(qos: .userInteractive).async { }
 
 2. .userInitiated
    - High priority
    - Use for: User-initiated tasks that need immediate results
    - Example: Loading data when user taps a button
 
 3. .default
    - Default priority
    - Use for: General tasks
 
 4. .utility
    - Lower priority
    - Use for: Long-running tasks with user-visible progress
    - Example: Downloads, imports
 
 5. .background
    - Lowest priority
    - Use for: Tasks user is not aware of
    - Example: Sync, backups, maintenance
 
 6. .unspecified
    - No QoS specified, system decides
 */

// MARK: - Common Deadlock Scenarios to Avoid

/*
 ❌ DEADLOCK 1: Sync on main queue from main thread
 
 DispatchQueue.main.sync {
     // This will deadlock!
     // Main thread is blocked waiting for this task
     // But this task needs main thread to execute
 }
 
 ❌ DEADLOCK 2: Nested sync on same serial queue
 
 serialQueue.sync {
     serialQueue.sync {
         // This will deadlock!
         // Outer task waiting for inner task
         // Inner task waiting for outer task to complete
     }
 }
 
 ✅ SOLUTION: Use async or different queues
 
 DispatchQueue.main.async {
     // This is safe
 }
 */





