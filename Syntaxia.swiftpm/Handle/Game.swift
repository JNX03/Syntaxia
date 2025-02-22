import SwiftUI
import UniformTypeIdentifiers
import AVFoundation
import Vision

enum NodeType: String, Codable, CaseIterable {
    case number, plus, minus, multiply, divide, print, ifElse, variable, loop, text
}

enum Port: String, Codable {
    case output, left, right, input, ifConditionLeft, ifConditionRight, ifThen, ifElse, ifOutput, loopStart, loopEnd, loopBody, loopOutput
}

enum Value: CustomStringConvertible {
    case number(Double)
    case text(String)
    
    var description: String {
        switch self {
        case .number(let n): return "\(n)"
        case .text(let s): return s
        }
    }
}

struct Node: Identifiable, Equatable {
    let id: UUID = UUID()
    var type: NodeType
    var title: String
    var position: CGPoint
    var content: String = ""
}

struct Connection: Identifiable, Codable, Equatable {
    let id: UUID = UUID()
    let fromNode: UUID
    let fromPort: Port
    let toNode: UUID
    let toPort: Port
}

class NodeEditorViewModel: ObservableObject {
    @Published var nodes: [Node] = []
    @Published var connections: [Connection] = []
    
    func addNode(type: NodeType, at position: CGPoint) {
        var title = ""
        var content = ""
        switch type {
        case .number:
            title = "Number"
            content = "0"
        case .plus:
            title = "+"
        case .minus:
            title = "–"
        case .multiply:
            title = "×"
        case .divide:
            title = "÷"
        case .print:
            title = "Print"
        case .ifElse:
            title = "IfElse"
        case .variable:
            title = "Var"
            content = "x"
        case .loop:
            title = "Loop"
        case .text:
            title = "Text"
            content = "\"Hello\""
        }
        let node = Node(type: type, title: title, position: position, content: content)
        nodes.append(node)
    }
    
    func delete(node: Node) {
        nodes.removeAll { $0.id == node.id }
        connections.removeAll { $0.fromNode == node.id || $0.toNode == node.id }
    }
    
    func addConnection(from sourceID: UUID, sourcePort: Port, to targetID: UUID, targetPort: Port) {
        guard sourceID != targetID else { return }
        let newConn = Connection(fromNode: sourceID, fromPort: sourcePort, toNode: targetID, toPort: targetPort)
        if !connections.contains(newConn) {
            connections.append(newConn)
        }
    }
    
    func delete(connection: Connection) {
        connections.removeAll { $0.id == connection.id }
    }
    
    func portPosition(for node: Node, port: Port) -> CGPoint {
        switch node.type {
        case .number, .variable, .text:
            if port == .output { return CGPoint(x: node.position.x + 70, y: node.position.y) }
        case .plus, .minus, .multiply, .divide:
            switch port {
            case .left: return CGPoint(x: node.position.x - 70, y: node.position.y - 15)
            case .right: return CGPoint(x: node.position.x - 70, y: node.position.y + 15)
            case .output: return CGPoint(x: node.position.x + 70, y: node.position.y)
            default: break
            }
        case .print:
            if port == .input { return CGPoint(x: node.position.x - 70, y: node.position.y) }
        case .ifElse:
            switch port {
            case .ifConditionLeft: return CGPoint(x: node.position.x - 80, y: node.position.y - 30)
            case .ifConditionRight: return CGPoint(x: node.position.x - 20, y: node.position.y - 30)
            case .ifThen: return CGPoint(x: node.position.x - 80, y: node.position.y + 30)
            case .ifElse: return CGPoint(x: node.position.x - 20, y: node.position.y + 30)
            case .ifOutput: return CGPoint(x: node.position.x + 80, y: node.position.y)
            default: break
            }
        case .loop:
            switch port {
            case .loopStart: return CGPoint(x: node.position.x - 90, y: node.position.y - 30)
            case .loopEnd: return CGPoint(x: node.position.x - 90, y: node.position.y + 30)
            case .loopBody: return CGPoint(x: node.position.x, y: node.position.y + 50)
            case .loopOutput: return CGPoint(x: node.position.x + 90, y: node.position.y)
            default: break
            }
        }
        return node.position
    }
    
    func evaluate(_ node: Node) -> Value? {
        switch node.type {
        case .number:
            if let d = Double(node.content) {
                return .number(d)
            } else {
                return .number(0)
            }
        case .text:
            return .text(node.content)
        case .variable:
            if let d = Double(node.content) {
                return .number(d)
            } else {
                return .text(node.content)
            }
        case .plus, .minus, .multiply, .divide:
            guard let leftConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .left }),
                  let rightConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .right }),
                  let leftNode = nodes.first(where: { $0.id == leftConn.fromNode }),
                  let rightNode = nodes.first(where: { $0.id == rightConn.fromNode }),
                  let leftVal = evaluate(leftNode),
                  let rightVal = evaluate(rightNode)
            else { return nil }
            switch (leftVal, rightVal) {
            case (.number(let l), .number(let r)):
                switch node.type {
                case .plus: return .number(l + r)
                case .minus: return .number(l - r)
                case .multiply: return .number(l * r)
                case .divide: return r != 0 ? .number(l / r) : nil
                default: return nil
                }
            default:
                return nil
            }
        case .ifElse:
            guard let condLeftConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .ifConditionLeft }),
                  let condRightConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .ifConditionRight }),
                  let thenConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .ifThen }),
                  let elseConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .ifElse }),
                  let condLeftNode = nodes.first(where: { $0.id == condLeftConn.fromNode }),
                  let condRightNode = nodes.first(where: { $0.id == condRightConn.fromNode }),
                  let thenNode = nodes.first(where: { $0.id == thenConn.fromNode }),
                  let elseNode = nodes.first(where: { $0.id == elseConn.fromNode }),
                  let leftVal = evaluate(condLeftNode),
                  let rightVal = evaluate(condRightNode)
            else { return nil }
            let conditionMet: Bool
            switch (leftVal, rightVal) {
            case (.number(let l), .number(let r)):
                conditionMet = l == r
            case (.text(let l), .text(let r)):
                conditionMet = l == r
            default:
                conditionMet = false
            }
            return conditionMet ? evaluate(thenNode) : evaluate(elseNode)
        case .print:
            guard let inputConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .input }),
                  let inputNode = nodes.first(where: { $0.id == inputConn.fromNode }),
                  let value = evaluate(inputNode)
            else { return nil }
            return value
        case .loop:
            return .number(0)
        }
    }
    
    func runCode() -> String {
        guard let printNode = nodes.first(where: { $0.type == .print }) else {
            return "Error: No Print node found."
        }
        if let result = evaluate(printNode) {
            return result.description
        } else {
            return "Error: Evaluation failed."
        }
    }
    
    func generateCode() -> String {
        guard let printNode = nodes.first(where: { $0.type == .print }) else {
            return "Error: No Print node found."
        }
        return codeForNode(printNode)
    }
    
    private func codeForNode(_ node: Node, indent: String = "") -> String {
        switch node.type {
        case .number:
            return node.content
        case .plus, .minus, .multiply, .divide:
            guard let leftConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .left }),
                  let rightConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .right }),
                  let leftNode = nodes.first(where: { $0.id == leftConn.fromNode }),
                  let rightNode = nodes.first(where: { $0.id == rightConn.fromNode })
            else { return "/* incomplete operation */" }
            let op: String
            switch node.type {
            case .plus: op = "+"
            case .minus: op = "-"
            case .multiply: op = "*"
            case .divide: op = "/"
            default: op = "?"
            }
            return "(\(codeForNode(leftNode)) \(op) \(codeForNode(rightNode)))"
        case .ifElse:
            guard let condLeftConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .ifConditionLeft }),
                  let condRightConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .ifConditionRight }),
                  let thenConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .ifThen }),
                  let elseConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .ifElse }),
                  let condLeftNode = nodes.first(where: { $0.id == condLeftConn.fromNode }),
                  let condRightNode = nodes.first(where: { $0.id == condRightConn.fromNode }),
                  let thenNode = nodes.first(where: { $0.id == thenConn.fromNode }),
                  let elseNode = nodes.first(where: { $0.id == elseConn.fromNode })
            else { return "/* incomplete ifElse */" }
            let ifCode = "\(indent)if \(codeForNode(condLeftNode)) == \(codeForNode(condRightNode)) {\n"
            let thenCode = "\(indent)    \(codeForNode(thenNode, indent: indent + "    "))\n"
            let elseCode = "\(indent)} else {\n\(indent)    \(codeForNode(elseNode, indent: indent + "    "))\n\(indent)}"
            return ifCode + thenCode + elseCode
        case .print:
            guard let inputConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .input }),
                  let inputNode = nodes.first(where: { $0.id == inputConn.fromNode })
            else { return "print(/* incomplete print */)" }
            return "\(indent)print(\(codeForNode(inputNode)))"
        case .loop:
            guard let startConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .loopStart }),
                  let endConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .loopEnd }),
                  let bodyConn = connections.first(where: { $0.toNode == node.id && $0.toPort == .loopBody }),
                  let startNode = nodes.first(where: { $0.id == startConn.fromNode }),
                  let endNode = nodes.first(where: { $0.id == endConn.fromNode }),
                  let bodyNode = nodes.first(where: { $0.id == bodyConn.fromNode })
            else { return "/* incomplete loop */" }
            return "for i in \(codeForNode(startNode))..<\(codeForNode(endNode)) {\n    \(codeForNode(bodyNode))\n}"
        case .variable, .text:
            return node.content
        }
    }
}

enum NodeCategory: String, CaseIterable {
    case math = "Math"
    case variable = "Variable"
    case loop = "Loop"
    case text = "Text"
    case logic = "Logic"
}

struct NodeCatalog: View {
    @ObservedObject var viewModel: NodeEditorViewModel
    @State private var selectedCategory: NodeCategory = .math
    let catalogMapping: [NodeCategory: [NodeType]] = [
        .math: [.number, .plus, .minus, .multiply, .divide],
        .variable: [.variable],
        .loop: [.loop],
        .text: [.text],
        .logic: [.ifElse, .print]
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Menu {
                ForEach(NodeCategory.allCases, id: \.self) { category in
                    Button("\(category.rawValue)") { selectedCategory = category }
                }
            } label: {
                HStack {
                    Text("Category: \(selectedCategory.rawValue) ▼")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.7))
                .cornerRadius(8)
                .padding()
            }
            let columns = [GridItem(.adaptive(minimum: 100))]
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(catalogMapping[selectedCategory] ?? [], id: \.self) { type in
                    Button(action: {
                        viewModel.addNode(type: type, at: CGPoint(x: 300, y: 300))
                    }) {
                        Text(displayTitle(for: type))
                            .frame(width: 100, height: 50)
                            .background(catalogColor(for: type))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                    }
                }
            }
            .padding()
            Spacer()
        }
        .frame(width: 220)
        .background(Color(white: 0.2))
    }
    
    func displayTitle(for type: NodeType) -> String {
        switch type {
        case .number: return "Number"
        case .plus: return "+"
        case .minus: return "–"
        case .multiply: return "×"
        case .divide: return "÷"
        case .print: return "Print"
        case .ifElse: return "IfElse"
        case .variable: return "Var"
        case .loop: return "Loop"
        case .text: return "Text"
        }
    }
    
    func catalogColor(for type: NodeType) -> Color {
        switch type {
        case .number, .plus, .minus, .multiply, .divide:
            return Color.blue
        case .print, .ifElse:
            return Color.red
        case .variable:
            return Color.orange
        case .loop:
            return Color.green
        case .text:
            return Color.purple
        }
    }
}

struct NodeView: View {
    @Binding var node: Node
    let viewModel: NodeEditorViewModel
    let onDelete: () -> Void
    
    func catalogColor(for type: NodeType) -> Color {
        switch type {
        case .number, .plus, .minus, .multiply, .divide:
            return Color.blue
        case .print, .ifElse:
            return Color.red
        case .variable:
            return Color.orange
        case .loop:
            return Color.green
        case .text:
            return Color.purple
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(catalogColor(for: node.type))
                .frame(width: 160, height: 80)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 4))
                .shadow(color: Color.black.opacity(0.5), radius: 8, x: 4, y: 4)
            VStack {
                Text(node.title)
                    .foregroundColor(.white)
                    .font(.headline)
                if node.type == .number || node.type == .text || node.type == .variable {
                    TextField("", text: Binding(get: { node.content }, set: { node.content = $0 }))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 90)
                }
            }
            if node.type == .ifElse {
                ifElsePorts
            } else if node.type == .loop {
                loopPorts
            } else {
                standardPorts
            }
        }
        .position(node.position)
        .gesture(DragGesture().onChanged { value in
            withAnimation(.easeInOut) { node.position = value.location }
        })
        .contextMenu { Button("Delete", action: onDelete) }
    }
    
    @ViewBuilder
    var standardPorts: some View {
        switch node.type {
        case .number, .variable, .text:
            outputDot(port: .output)
                .offset(x: 70, y: 0)
        case .print:
            inputDot(port: .input)
                .offset(x: -70, y: 0)
        case .plus, .minus, .multiply, .divide:
            inputDot(port: .left)
                .offset(x: -70, y: -15)
            inputDot(port: .right)
                .offset(x: -70, y: 15)
            outputDot(port: .output)
                .offset(x: 70, y: 0)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    var ifElsePorts: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                labeledInputDot(port: .ifConditionLeft, label: "IF L")
                labeledInputDot(port: .ifConditionRight, label: "IF R")
            }
            HStack(spacing: 8) {
                labeledInputDot(port: .ifThen, label: "THEN")
                labeledInputDot(port: .ifElse, label: "ELSE")
            }
        }
        .offset(x: -80, y: 0)
        VStack {
            outputDot(port: .ifOutput)
            Text("OUT")
                .font(.caption)
                .foregroundColor(.white)
        }
        .offset(x: 80, y: 0)
    }
    
    @ViewBuilder
    var loopPorts: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                labeledInputDot(port: .loopStart, label: "Start")
            }
            HStack(spacing: 8) {
                labeledInputDot(port: .loopEnd, label: "End")
            }
        }
        .offset(x: -90, y: 0)
        VStack {
            labeledInputDot(port: .loopBody, label: "Body")
                .offset(y: 40)
            outputDot(port: .loopOutput)
        }
        .offset(x: 90, y: 0)
    }
    
    func outputDot(port: Port) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 28, height: 28)
            .overlay(Circle().stroke(Color.black, lineWidth: 3))
            .onDrag {
                let string = "\(node.id.uuidString):\(port.rawValue)"
                return NSItemProvider(object: string as NSString)
            }
    }
    
    func inputDot(port: Port) -> some View {
        Circle()
            .fill(Color.white.opacity(0.7))
            .frame(width: 36, height: 36)
            .overlay(Circle().stroke(Color.black, lineWidth: 3))
            .contentShape(Rectangle())
            .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                if let provider = providers.first {
                    provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { data, error in
                        if let data = data as? Data,
                           let string = String(data: data, encoding: .utf8) {
                            let parts = string.split(separator: ":")
                            if parts.count == 2,
                               let sourceID = UUID(uuidString: String(parts[0])),
                               let sourcePort = Port(rawValue: String(parts[1])) {
                                DispatchQueue.main.async {
                                    viewModel.addConnection(from: sourceID, sourcePort: sourcePort, to: node.id, targetPort: port)
                                }
                            }
                        }
                    }
                    return true
                }
                return false
            }
    }
    
    func labeledInputDot(port: Port, label: String) -> some View {
        VStack(spacing: 2) {
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: 36, height: 36)
                .overlay(Circle().stroke(Color.black, lineWidth: 3))
                .contentShape(Rectangle())
                .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                    if let provider = providers.first {
                        provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { data, error in
                            if let data = data as? Data,
                               let string = String(data: data, encoding: .utf8) {
                                let parts = string.split(separator: ":")
                                if parts.count == 2,
                                   let sourceID = UUID(uuidString: String(parts[0])),
                                   let sourcePort = Port(rawValue: String(parts[1])) {
                                    DispatchQueue.main.async {
                                        viewModel.addConnection(from: sourceID, sourcePort: sourcePort, to: node.id, targetPort: port)
                                    }
                                }
                            }
                        }
                        return true
                    }
                    return false
                }
            Text(label)
                .font(.caption2)
                .foregroundColor(.white)
        }
    }
}

struct NodeEditorCanvas: View {
    @ObservedObject var viewModel: NodeEditorViewModel
    @State private var zoomScale: CGFloat = 1.0
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), Color.black.opacity(0.7)]),
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                ForEach(viewModel.connections) { connection in
                    if let sourceNode = viewModel.nodes.first(where: { $0.id == connection.fromNode }),
                       let targetNode = viewModel.nodes.first(where: { $0.id == connection.toNode }) {
                        let start = viewModel.portPosition(for: sourceNode, port: connection.fromPort)
                        let end = viewModel.portPosition(for: targetNode, port: connection.toPort)
                        ConnectionView(connection: connection, start: start, end: end) {
                            viewModel.delete(connection: connection)
                        }
                    }
                }
                ForEach($viewModel.nodes) { $node in
                    NodeView(node: $node, viewModel: viewModel, onDelete: { viewModel.delete(node: node) })
                }
            }
            .scaleEffect(zoomScale)
            .gesture(MagnificationGesture().onChanged { value in zoomScale = value })
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct ConnectionView: View {
    let connection: Connection
    let start: CGPoint
    let end: CGPoint
    let onDelete: () -> Void
    var body: some View {
        Path { path in
            path.move(to: start)
            let control1 = CGPoint(x: start.x + (end.x - start.x) * 0.3, y: start.y)
            let control2 = CGPoint(x: start.x + (end.x - start.x) * 0.7, y: end.y)
            path.addCurve(to: end, control1: control1, control2: control2)
        }
        .stroke(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white]),
                               startPoint: .leading, endPoint: .trailing), lineWidth: 2)
        .contentShape(Rectangle())
        .contextMenu { Button("Delete Connection", action: onDelete) }
    }
}

struct TerminalView: View {
    let output: String
    var body: some View {
        ScrollView {
            Text(output)
                .font(.system(.body, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.black)
        .foregroundColor(Color.green)
        .frame(height: 150)
    }
}

struct CodeTabView: View {
    let generatedCode: String
    var body: some View {
        TabView {
            ScrollView {
                Text("Python:\n\(generatedCode)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
            }
            .tabItem { Text("Python") }
            ScrollView {
                Text("Swift:\n\(generatedCode)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
            }
            .tabItem { Text("Swift") }
        }
        .background(Color.black)
        .frame(width: 300)
    }
}

class HandTrackingManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var indexPointNorm: CGPoint = .zero
    @Published var thumbPointNorm: CGPoint = .zero
    @Published var isPinching: Bool = false
    private let session = AVCaptureSession()
    override init() {
        super.init()
        session.sessionPreset = .medium
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        if let input = try? AVCaptureDeviceInput(device: device) { session.addInput(input) }
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "handTrackingQueue"))
        session.addOutput(output)
        session.startRunning()
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectHumanHandPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try? handler.perform([request])
        guard let observation = request.results?.first as? VNHumanHandPoseObservation,
              let indexTip = try? observation.recognizedPoint(.indexTip),
              let thumbTip = try? observation.recognizedPoint(.thumbTip)
        else { return }
        DispatchQueue.main.async {
            self.indexPointNorm = CGPoint(x: indexTip.location.x, y: indexTip.location.y)
            self.thumbPointNorm = CGPoint(x: thumbTip.location.x, y: thumbTip.location.y)
            let dx = indexTip.location.x - thumbTip.location.x
            let dy = indexTip.location.y - thumbTip.location.y
            let distance = sqrt(dx * dx + dy * dy)
            self.isPinching = distance < 0.1
        }
    }
}

struct HandTrackingOverlay: View {
    @ObservedObject var handManager: HandTrackingManager
    @ObservedObject var viewModel: NodeEditorViewModel
    @State private var creationStart: Date? = nil
    @State private var deletionStart: Date? = nil
    var body: some View {
        GeometryReader { geo in
            let indexPos = CGPoint(x: handManager.indexPointNorm.x * geo.size.width,
                                   y: (1 - handManager.indexPointNorm.y) * geo.size.height)
            let thumbPos = CGPoint(x: handManager.thumbPointNorm.x * geo.size.width,
                                   y: (1 - handManager.thumbPointNorm.y) * geo.size.height)
            let midPoint = CGPoint(x: (indexPos.x + thumbPos.x) / 2,
                                   y: (indexPos.y + thumbPos.y) / 2)
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .position(indexPos)
                Circle()
                    .fill(Color.green.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .position(thumbPos)
                Path { path in
                    path.move(to: indexPos)
                    path.addLine(to: thumbPos)
                }
                .stroke(handManager.isPinching ? Color.red : Color.gray, lineWidth: 3)
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 30, height: 30)
                    .position(midPoint)
                    .onChange(of: midPoint) { pos in
                        if handManager.isPinching {
                            if let nodeIndex = viewModel.nodes.firstIndex(where: { hypot($0.position.x - pos.x, $0.position.y - pos.y) < 40 }) {
                                viewModel.nodes[nodeIndex].position = pos
                            }
                        }
                    }
            }
            .onChange(of: midPoint) { pos in
                if pos.x < 100 && pos.y < 100 {
                    if creationStart == nil { creationStart = Date() }
                    if let start = creationStart, Date().timeIntervalSince(start) > 2 {
                        viewModel.addNode(type: .number, at: pos)
                        creationStart = nil
                    }
                } else { creationStart = nil }
                if pos.x > geo.size.width - 100 && pos.y < 100 {
                    if deletionStart == nil { deletionStart = Date() }
                    if let start = deletionStart, Date().timeIntervalSince(start) > 2 {
                        if let node = viewModel.nodes.min(by: { hypot($0.position.x - pos.x, $0.position.y - pos.y) < hypot($1.position.x - pos.x, $1.position.y - pos.y) }),
                           hypot(node.position.x - pos.x, node.position.y - pos.y) < 50 {
                            viewModel.delete(node: node)
                        }
                        deletionStart = nil
                    }
                } else { deletionStart = nil }
            }
            .allowsHitTesting(false)
        }
    }
}

struct TutorialView: View {
    var onDismiss: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Welcome to the Node Editor!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text("• Use the dropdown menu on the left to select a category and add blocks.")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("• Drag blocks around and connect them by dragging from one connector to another.")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("• Right-click (or tap with two fingers) on a connection line to delete it.")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("• All blocks are executable! Text nodes will print text, and number nodes will print numbers.")
                    .font(.title2)
                    .foregroundColor(.white)
                Button("Got it!") {
                    onDismiss()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}
