import SwiftUI
import UniformTypeIdentifiers
import AVFoundation
import Vision

struct Playground: View {
    @Binding var showPlayground: Bool
    @StateObject var viewModel = NodeEditorViewModel()
    @State private var terminalOutput: String = ""
    @State private var generatedCode: String = ""
    @State private var handTrackingEnabled: Bool = false
    @State private var showTutorial: Bool = true
    @StateObject private var handManager = HandTrackingManager()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        showPlayground = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        Text("Syntaxia/Playground")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Toggle("", isOn: $handTrackingEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                        Text("Hand Tracking")
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .background(LinearGradient(gradient: Gradient(colors: [.black, .blue.opacity(0.8)]),
                                           startPoint: .leading, endPoint: .trailing))
                
                Divider().background(Color.white)
                
                HStack(spacing: 0) {
                    NodeCatalog(viewModel: viewModel)
                    ZStack {
                        NodeEditorCanvas(viewModel: viewModel)
                        if handTrackingEnabled {
                            HandTrackingOverlay(handManager: handManager, viewModel: viewModel)
                        }
                    }
                    CodeTabView(generatedCode: generatedCode)
                }
                .background(Color.black.opacity(0.8))
                
                TerminalView(output: terminalOutput)
                    .background(Color.black)
                
                HStack {
                    Button("Run Code") {
                        terminalOutput = viewModel.runCode()
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
                .background(Color.black.opacity(0.8))
            }
            .frame(minWidth: 900, minHeight: 750)
            .onChange(of: viewModel.nodes) { _ in
                generatedCode = viewModel.generateCode()
            }
            .onChange(of: viewModel.connections) { _ in
                generatedCode = viewModel.generateCode()
            }
            
            if showTutorial {
                TutorialView() {
                    showTutorial = false
                }
            }
        }
    }
}
