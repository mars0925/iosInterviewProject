//
//  SwiftUILifeCycleDemoView.swift
//  InterviewDemoProject
//
//  SwiftUI View 生命週期演示
//

import SwiftUI
import Combine

// MARK: - Lifecycle Observable View Model
/// 用於觀察和記錄生命週期的 ViewModel
class LifeCycleViewModel: ObservableObject {
    @Published var logs: [String] = []
    let viewName: String
    
    init(name: String) {
        self.viewName = name
        log("ViewModel init")
    }
    
    deinit {
        // 注意：deinit 的日誌可能看不到，因為 print 可能在對象釋放後執行
        print("[\(viewName)] ViewModel deinit")
    }
    
    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let logMessage = "[\(timestamp)] [\(viewName)] \(message)"
        logs.append(logMessage)
        print(logMessage)
    }
}

// MARK: - Lifecycle Demo View
/// 演示 SwiftUI View 生命週期的視圖
struct LifeCycleDemoView: View {
    @StateObject private var viewModel: LifeCycleViewModel
    @State private var appearCount = 0
    @State private var bodyRenderCount = 0
    @State private var counter = 0
    
    // 定時器
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(name: String) {
        // 注意：init 可能被多次調用
        print("[\(name)] View init called")
        _viewModel = StateObject(wrappedValue: LifeCycleViewModel(name: name))
    }
    
    var body: some View {
        // ⚠️ body 會被頻繁調用，不要在這裡執行副作用操作
        let _ = {
            bodyRenderCount += 1
            viewModel.log("body 被渲染 (第 \(bodyRenderCount) 次)")
        }()
        
        return ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(viewModel.viewName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("觀察控制台和日誌輸出")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Statistics
                VStack(spacing: 12) {
                    StatRow(title: "出現次數", value: "\(appearCount)")
                    StatRow(title: "Body 渲染次數", value: "\(bodyRenderCount)")
                    StatRow(title: "計數器", value: "\(counter)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        counter += 1
                        viewModel.log("計數器增加: \(counter)")
                    }) {
                        Text("增加計數器")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        viewModel.log("手動記錄日誌")
                    }) {
                        Text("記錄日誌")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Logs
                VStack(alignment: .leading, spacing: 8) {
                    Text("日誌輸出")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(viewModel.logs, id: \.self) { log in
                                Text(log)
                                    .font(.system(size: 11, design: .monospaced))
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 250)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("生命週期演示")
        .navigationBarTitleDisplayMode(.inline)
        // MARK: - Lifecycle Modifiers
        .onAppear {
            // ✅ View 出現時調用
            appearCount += 1
            viewModel.log("onAppear() 被調用 (第 \(appearCount) 次)")
        }
        .onDisappear {
            // ✅ View 消失時調用
            viewModel.log("onDisappear() 被調用")
        }
        .task {
            // ✅ View 出現時開始，消失時自動取消
            viewModel.log("task {} 開始執行")
            
            // 模擬異步操作
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                viewModel.log("task {} 異步操作完成")
            } catch {
                viewModel.log("task {} 被取消")
            }
        }
        .onChange(of: counter) { newValue in
            // ✅ 監聽 counter 的變化
            viewModel.log("onChange(of: counter) - 新值: \(newValue)")
        }
        .onReceive(timer) { _ in
            // ✅ 接收定時器事件
            // 注意：這會導致 body 頻繁重新渲染
            // viewModel.log("onReceive(timer)")
        }
    }
}

// MARK: - Stat Row Component
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.horizontal)
    }
}

// MARK: - Main Demo View
/// 主演示視圖
struct SwiftUILifeCycleDemoView: View {
    @State private var selectedDemo: DemoType?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("SwiftUI 生命週期演示")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("選擇下方場景來觀察 SwiftUI View 的生命週期")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    // Demo Scenarios
                    VStack(spacing: 12) {
                        DemoButton(
                            title: "基本生命週期",
                            description: "觀察 init, body, onAppear, onDisappear",
                            icon: "1.circle.fill",
                            color: .blue
                        ) {
                            selectedDemo = .basic
                        }
                        
                        DemoButton(
                            title: "狀態變化觀察",
                            description: "觀察狀態改變如何觸發 body 重新渲染",
                            icon: "2.circle.fill",
                            color: .green
                        ) {
                            selectedDemo = .stateChange
                        }
                        
                        DemoButton(
                            title: "Task 生命週期",
                            description: "演示 task 的自動取消機制",
                            icon: "3.circle.fill",
                            color: .orange
                        ) {
                            selectedDemo = .task
                        }
                        
                        DemoButton(
                            title: "多次出現/消失",
                            description: "觀察導航返回時的生命週期",
                            icon: "4.circle.fill",
                            color: .purple
                        ) {
                            selectedDemo = .navigation
                        }
                        
                        DemoButton(
                            title: "ViewModel 生命週期",
                            description: "觀察 @StateObject 的生命週期",
                            icon: "5.circle.fill",
                            color: .red
                        ) {
                            selectedDemo = .viewModel
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info Section
                    InfoSection()
                        .padding()
                }
                .padding(.vertical)
            }
            .navigationTitle("SwiftUI 生命週期")

        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let demo = selectedDemo {
            switch demo {
            case .basic:
                LifeCycleDemoView(name: "基本生命週期")
            case .stateChange:
                StateChangeDemoView()
            case .task:
                TaskDemoView()
            case .navigation:
                NavigationDemoView()
            case .viewModel:
                ViewModelDemoView()
            }
        }
    }
}

// MARK: - Demo Types
enum DemoType {
    case basic
    case stateChange
    case task
    case navigation
    case viewModel
}

// MARK: - Demo Button Component
struct DemoButton: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                    .frame(width: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - State Change Demo
struct StateChangeDemoView: View {
    @State private var counter = 0
    @State private var bodyRenderCount = 0
    @State private var logs: [String] = []
    
    var body: some View {
        let _ = {
            bodyRenderCount += 1
            addLog("body 被渲染 (第 \(bodyRenderCount) 次)")
        }()
        
        return VStack(spacing: 20) {
            Text("Body 渲染次數: \(bodyRenderCount)")
                .font(.title2)
                .padding()
            
            Text("計數器: \(counter)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("增加計數器") {
                counter += 1
                addLog("計數器更新為: \(counter)")
            }
            .buttonStyle(.borderedProminent)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(logs, id: \.self) { log in
                        Text(log)
                            .font(.caption)
                            .padding(.vertical, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding()
        }
        .navigationTitle("狀態變化觀察")
        .onAppear {
            addLog("View 出現")
        }
        .onChange(of: counter) { newValue in
            addLog("onChange 被觸發: \(newValue)")
        }
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logs.append("[\(timestamp)] \(message)")
        print(message)
    }
}

// MARK: - Task Demo
struct TaskDemoView: View {
    @State private var status = "等待中..."
    @State private var progress = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Task 生命週期演示")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(status)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("進度: \(progress)/5")
                .font(.largeTitle)
            
            Text("返回上一頁時，task 會自動取消")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .task {
            status = "Task 開始執行..."
            print("Task 開始")
            
            for i in 1...5 {
                // 檢查是否被取消
                if Task.isCancelled {
                    print("Task 被取消")
                    break
                }
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                progress = i
                status = "執行中... (\(i)/5)"
                print("Task 進度: \(i)/5")
            }
            
            if !Task.isCancelled {
                status = "Task 完成！"
                print("Task 完成")
            } else {
                status = "Task 已取消"
            }
        }
    }
}

// MARK: - Navigation Demo
struct NavigationDemoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("多次導航演示")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("點擊下面的按鈕進入子頁面，然後返回，觀察生命週期")
                .multilineTextAlignment(.center)
                .padding()
            
            NavigationLink(destination: LifeCycleDemoView(name: "子頁面")) {
                Text("進入子頁面")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("NavigationDemoView appeared")
        }
        .onDisappear {
            print("NavigationDemoView disappeared")
        }
    }
}

// MARK: - ViewModel Demo
class DemoViewModel: ObservableObject {
    @Published var count = 0
    let id = UUID()
    
    init() {
        print("ViewModel [\(id)] init")
    }
    
    deinit {
        print("ViewModel [\(id)] deinit")
    }
}

struct ViewModelDemoView: View {
    @StateObject private var viewModel = DemoViewModel()
    @State private var recreateToggle = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ViewModel 生命週期")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("ViewModel ID:")
                .foregroundColor(.secondary)
            Text(viewModel.id.uuidString)
                .font(.caption)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            Text("Count: \(viewModel.count)")
                .font(.largeTitle)
            
            Button("增加計數") {
                viewModel.count += 1
            }
            .buttonStyle(.borderedProminent)
            
            Divider()
                .padding()
            
            Text("即使切換 toggle，ViewModel 也不會重新創建")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Toggle("Toggle", isOn: $recreateToggle)
                .padding()
            
            Text("返回上一頁後，ViewModel 才會被釋放")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Info Section
struct InfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("重要提示", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text("• 請打開 Xcode 控制台查看詳細日誌輸出")
            Text("• init 可能被多次調用，這是正常的")
            Text("• body 會在狀態改變時重新執行")
            Text("• @StateObject 確保 ViewModel 只創建一次")
            Text("• task 會在 View 消失時自動取消")
            
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Binding Extension for Optional
extension Binding {
    func map<T>(get: @escaping (Value) -> T, set: @escaping (T) -> Value) -> Binding<T> {
        Binding<T>(
            get: { get(self.wrappedValue) },
            set: { self.wrappedValue = set($0) }
        )
    }
}

// MARK: - Preview
struct SwiftUILifeCycleDemoView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUILifeCycleDemoView()
    }
}



