import SwiftUI
import NaturalLanguage

enum CodeMode: String, CaseIterable, Identifiable {
    case sample = "Sample Code"
    case custom = "Custom Code"
    var id: String { rawValue }
}

struct Sample: Identifiable {
    let id = UUID()
    let title: String
    let code: String
}

struct Emoji: View {
    @State private var codeMode: CodeMode = .sample
    @State private var samples: [Sample] = [
        Sample(title: "Loop Example", code: "for i in 0..<10 { print(i) }"),
        Sample(title: "Conditional Example", code: "if x > 5 { print(\"x is large\") }"),
        Sample(title: "Function Example", code: "func greet(name: String) { print(\"Hello \\(name)\") }"),
        Sample(title: "Error Example", code: "if error != nil { print(\"Error occurred\") }"),
        Sample(title: "Class Example", code: "class MyClass { var x: Int = 0 }"),
        Sample(title: "Struct Example", code: "struct MyStruct { var value: Int }")
    ]
    
    @State private var selectedSampleIndex: Int = 0
    @State private var customCode: String = ""
    @State private var predictedEmoji: String = ""
    @State private var animateEmoji: Bool = false
    @State private var showDescription: Bool = false
    
    var currentCode: String {
        codeMode == .sample ? samples[selectedSampleIndex].code : customCode
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.85)]),
                               startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Dynamic Emoji Coding")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        Picker("Mode", selection: $codeMode) {
                            ForEach(CodeMode.allCases) { mode in
                                Text(mode.rawValue)
                                    .foregroundColor(.white)
                                    .tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                        
                        if codeMode == .sample {
                            Picker("Select a Sample", selection: $selectedSampleIndex) {
                                ForEach(0..<samples.count, id: \.self) { index in
                                    Text(samples[index].title)
                                        .foregroundColor(.white)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            
                            Text(samples[selectedSampleIndex].code)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        } else {
                            TextEditor(text: $customCode)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(8)
                                .frame(height: 150)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            predictedEmoji = predictEmoji(from: currentCode)
                            animateEmoji = false
                            withAnimation(Animation.easeIn(duration: 0.5)) {
                                animateEmoji = true
                            }
                        }) {
                            Text("Analyze Code")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        
                        if !predictedEmoji.isEmpty {
                            Text(predictedEmoji)
                                .font(.system(size: animateEmoji ? 120 : 60))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 10, x: 0, y: 0)
                                .padding()
                                .onTapGesture { showDescription = true }
                                .animation(.easeInOut(duration: 0.5), value: animateEmoji)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle("Emoji Coder", displayMode: .inline)
            .alert(isPresented: $showDescription) {
                Alert(title: Text("Emoji Description"),
                      message: Text(emojiDescription(for: predictedEmoji)),
                      dismissButton: .default(Text("OK")))
            }
            .onChange(of: selectedSampleIndex) { newValue in
                if codeMode == .sample {
                    predictedEmoji = predictEmoji(from: samples[newValue].code)
                    animateEmoji = false
                    withAnimation(Animation.easeIn(duration: 0.5)) {
                        animateEmoji = true
                    }
                }
            }
            .onAppear {
                predictedEmoji = predictEmoji(from: currentCode)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    func predictEmoji(from code: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = code
        var tokens = [String]()
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther]
        tagger.enumerateTags(in: code.startIndex..<code.endIndex, unit: .word, scheme: .lemma, options: options) { _, tokenRange in
            tokens.append(String(code[tokenRange]).lowercased())
            return true
        }
        if tokens.contains(where: { $0 == "for" || $0 == "while" || $0 == "loop" }) {
            return "🌀"
        } else if tokens.contains(where: { $0 == "if" || $0 == "switch" }) {
            return "💡"
        } else if tokens.contains(where: { $0 == "error" || $0 == "bug" || $0 == "throw" }) {
            return "🐞"
        } else if tokens.contains(where: { $0 == "func" || $0 == "def" || $0 == "method" }) {
            return "🔧"
        } else if tokens.contains(where: { $0 == "class" }) {
            return "🏛"
        } else if tokens.contains(where: { $0 == "struct" }) {
            return "📦"
        } else {
            return "🤖"
        }
    }
    
    func emojiDescription(for emoji: String) -> String {
        switch emoji {
        case "🌀": return "Loop construct detected: repetitive operations."
        case "💡": return "Conditional logic detected: branching decisions."
        case "🐞": return "Potential error or bug present in the code."
        case "🔧": return "Function or method definition found."
        case "🏛": return "Class definition detected."
        case "📦": return "Struct definition detected."
        default: return "General code detected."
        }
    }
}
