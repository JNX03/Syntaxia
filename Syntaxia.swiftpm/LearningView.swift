import SwiftUI
import AudioToolbox

enum ProgrammingLanguage: String, CaseIterable, Identifiable {
    case python = "Python"
    case swift = "Swift"
    var id: String { self.rawValue }
}

enum LessonType: String {
    case lesson, quiz, game
}

enum QuizSubType: String {
    case dragDrop, trueFalse, matching, debug, correctCode
}

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let language: ProgrammingLanguage
    let type: LessonType
    let detailDescription: String?
    let codeSample: String?
    let expectedOutput: String?
    let quizQuestion: String?
    let correctAnswer: String?
    let quizSubType: QuizSubType?
    let editable: Bool
}

class LearningProgress: ObservableObject {
    @Published var currentLesson: [ProgrammingLanguage: Int] = [
        .python: 0,
        .swift: 0
    ]
    
    func isUnlocked(_ lesson: Lesson) -> Bool {
        lesson.id <= ((currentLesson[lesson.language] ?? 0) + 1)
    }
    
    func complete(lesson: Lesson) {
        if lesson.id == ((currentLesson[lesson.language] ?? 0) + 1) {
            currentLesson[lesson.language]? += 1
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

func playSuccessSound() {
    AudioServicesPlaySystemSound(1104)
}

func playFailureSound() {
    AudioServicesPlaySystemSound(1107)
}
struct LearningView: View {
    @Binding var showLearn: Bool
    @State private var selectedLanguage: ProgrammingLanguage = .python
    @ObservedObject var progress = LearningProgress()
    let lessons: [Lesson] = Lesson.sampleLessons()
    
    var filteredLessons: [Lesson] {
        lessons.filter { $0.language == selectedLanguage }
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Learn \(selectedLanguage.rawValue)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Advance your skills with interactive lessons—from variables to control flow and functions. Edit code (if allowed) to see live output or try out quizzes and mini-games.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(ProgrammingLanguage.allCases) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)
                Text("Progress: \(progress.currentLesson[selectedLanguage] ?? 0)/\(filteredLessons.count)")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredLessons) { lesson in
                            NavigationLink(destination: LessonDetailView(lesson: lesson, progress: progress)) {
                                LevelCellView(lesson: lesson, isUnlocked: progress.isUnlocked(lesson))
                            }
                            .disabled(!progress.isUnlocked(lesson))
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .navigationBarItems(leading: Button(action: {
                showLearn = false
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.blue)
            })
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct LevelCellView: View {
    let lesson: Lesson
    let isUnlocked: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.green : Color.gray)
                    .frame(width: 70, height: 70)
                if isUnlocked {
                    Text("\(lesson.id)")
                        .font(.title)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white)
                }
            }
            Text(lesson.title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(width: 80)
                .foregroundColor(.primary)
        }
    }
}

struct LessonDetailView: View {
    let lesson: Lesson
    @ObservedObject var progress: LearningProgress
    @State private var codeText: String = ""
    @State private var outputText: String = ""
    
    @State private var dropAnswer: String = ""
    @State private var quizCompleted: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var showSuccessOverlay = false
    @State private var showFailureOverlay = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(lesson.title)
                        .font(.title)
                        .padding(.top)
                        .foregroundColor(.primary)
                    if let description = lesson.detailDescription {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if lesson.type == .lesson {
                        Text("Example Code:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        if lesson.codeSample != nil {
                            if lesson.editable {
                                TextEditor(text: $codeText)
                                    .frame(height: 150)
                                    .border(Color.gray, width: 1)
                                    .background(Color(UIColor.secondarySystemBackground))
                            } else {
                                Text(codeText)
                                    .frame(height: 150)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)
                                    .border(Color.gray, width: 1)
                            }
                        }
                        Button("Run Code") {
                            if lesson.editable {
                                let lines = codeText.components(separatedBy: "\n")
                                var number: Int?
                                for line in lines {
                                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                                    if trimmed.hasPrefix("x =") {
                                        let parts = trimmed.split(separator: "=")
                                        if parts.count >= 2,
                                           let value = Int(parts[1].trimmingCharacters(in: .whitespaces)) {
                                            number = value
                                        }
                                    }
                                }
                                if let num = number, codeText.contains("print(x)") {
                                    outputText = String(num)
                                } else {
                                    outputText = lesson.expectedOutput ?? "Output simulated..."
                                }
                            } else {
                                outputText = lesson.expectedOutput ?? "Output simulated..."
                            }
                        }
                        .padding(.vertical)
                        .buttonStyle(PressableButtonStyle())
                        Text("Output:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(outputText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    } else if lesson.type == .quiz {
                        if let subType = lesson.quizSubType {
                            switch subType {
                            case .dragDrop, .matching:
                                if let question = lesson.quizQuestion {
                                    Text(question)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                Text("Drag the correct answer into the box below:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DropAreaView(correctAnswer: lesson.correctAnswer ?? "", currentAnswer: $dropAnswer)
                                    .padding(.vertical)
                                HStack {
                                    DraggableCodeBlock(text: lesson.correctAnswer ?? "")
                                    DraggableCodeBlock(text: "Incorrect Answer")
                                }
                                .padding(.horizontal)
                                Button("Submit Answer") {
                                    if dropAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                                        (lesson.correctAnswer ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
                                        quizCompleted = true
                                        alertMessage = "Correct! You can now complete the lesson."
                                        showSuccessEffect()
                                    } else {
                                        alertMessage = "Wrong answer. Please try again."
                                        showFailureEffect()
                                    }
                                    showingAlert = true
                                }
                                .padding(.vertical)
                                .buttonStyle(PressableButtonStyle())
                            case .trueFalse:
                                if let question = lesson.quizQuestion {
                                    Text(question)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                HStack {
                                    Button("True") {
                                        if (lesson.correctAnswer ?? "").lowercased() == "true" {
                                            quizCompleted = true
                                            alertMessage = "Correct! You can now complete the lesson."
                                            showSuccessEffect()
                                        } else {
                                            alertMessage = "Wrong answer. Please try again."
                                            showFailureEffect()
                                        }
                                        showingAlert = true
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                                    .buttonStyle(PressableButtonStyle())
                                    
                                    Button("False") {
                                        if (lesson.correctAnswer ?? "").lowercased() == "false" {
                                            quizCompleted = true
                                            alertMessage = "Correct! You can now complete the lesson."
                                            showSuccessEffect()
                                        } else {
                                            alertMessage = "Wrong answer. Please try again."
                                            showFailureEffect()
                                        }
                                        showingAlert = true
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                                    .buttonStyle(PressableButtonStyle())
                                }
                            case .debug, .correctCode:
                                if let question = lesson.quizQuestion {
                                    Text(question)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                                Text("Drag the corrected code into the blank below:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                DebugDropAreaView(correctAnswer: lesson.correctAnswer ?? "", currentAnswer: $dropAnswer)
                                    .padding(.vertical)
                                HStack {
                                    DraggableCodeBlock(text: lesson.correctAnswer ?? "")
                                    DraggableCodeBlock(text: "Incorrect Code")
                                }
                                .padding(.horizontal)
                                Button("Submit Correction") {
                                    if dropAnswer.trimmingCharacters(in: .whitespacesAndNewlines) ==
                                        (lesson.correctAnswer ?? "").trimmingCharacters(in: .whitespacesAndNewlines) {
                                        quizCompleted = true
                                        alertMessage = "Correct! You can now complete the lesson."
                                        showSuccessEffect()
                                    } else {
                                        alertMessage = "The correction is not correct. Please try again."
                                        showFailureEffect()
                                    }
                                    showingAlert = true
                                }
                                .padding(.vertical)
                                .buttonStyle(PressableButtonStyle())
                            }
                        } else {
                            if let question = lesson.quizQuestion {
                                Text(question)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Text("Drag the correct answer into the box below:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            DropAreaView(correctAnswer: lesson.correctAnswer ?? "", currentAnswer: $dropAnswer)
                                .padding(.vertical)
                            HStack {
                                DraggableCodeBlock(text: lesson.correctAnswer ?? "")
                                DraggableCodeBlock(text: "Incorrect Answer")
                            }
                            .padding(.horizontal)
                            Button("Submit Answer") {
                                if dropAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                                    (lesson.correctAnswer ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
                                    quizCompleted = true
                                    alertMessage = "Correct! You can now complete the lesson."
                                    showSuccessEffect()
                                } else {
                                    alertMessage = "Wrong answer. Please try again."
                                    showFailureEffect()
                                }
                                showingAlert = true
                            }
                            .padding(.vertical)
                            .buttonStyle(PressableButtonStyle())
                        }
                    } else if lesson.type == .game {
                        Text("Arrange the code blocks in the correct order:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        CodeArrangementGameView()
                    }
                    Spacer()
                    Button("Complete Lesson") {
                        progress.complete(lesson: lesson)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .buttonStyle(PressableButtonStyle())
                    .disabled(lesson.type == .quiz && !quizCompleted)
                }
                .padding()
                .navigationBarTitle("", displayMode: .inline)
                .onAppear {
                    if let sample = lesson.codeSample, lesson.type == .lesson {
                        codeText = sample
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(quizCompleted ? "Correct" : "Incorrect"),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))
                }
            }
            
            if showSuccessOverlay {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.yellow)
                    .transition(.scale)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation { showSuccessOverlay = false }
                        }
                    }
            }
            if showFailureOverlay {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.red)
                    .transition(.scale)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation { showFailureOverlay = false }
                        }
                    }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func showSuccessEffect() {
        withAnimation { showSuccessOverlay = true }
        playSuccessSound()
    }
    
    private func showFailureEffect() {
        withAnimation { showFailureOverlay = true }
        playFailureSound()
    }
}

struct DropAreaView: View {
    let correctAnswer: String
    @Binding var currentAnswer: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 150, height: 40)
                .cornerRadius(8)
            Text(currentAnswer.isEmpty ? "Drop here" : currentAnswer)
                .foregroundColor(.primary)
        }
        .onDrop(of: ["public.text"], isTargeted: nil) { providers in
            if let provider = providers.first {
                provider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, _ in
                    if let data = data as? Data,
                       let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            currentAnswer = text
                        }
                    }
                }
                return true
            }
            return false
        }
    }
}

struct DebugDropAreaView: View {
    let correctAnswer: String
    @Binding var currentAnswer: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 150)
                .cornerRadius(8)
            Text(currentAnswer.isEmpty ? "Drop corrected code here" : currentAnswer)
                .foregroundColor(.primary)
                .padding()
        }
        .onDrop(of: ["public.text"], isTargeted: nil) { providers in
            if let provider = providers.first {
                provider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, _ in
                    if let data = data as? Data,
                       let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            currentAnswer = text
                        }
                    }
                }
                return true
            }
            return false
        }
    }
}

struct DraggableCodeBlock: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding()
            .background(Color.yellow)
            .cornerRadius(8)
            .onDrag {
                NSItemProvider(object: text as NSString)
            }
    }
}

struct CodeArrangementGameView: View {
    @State private var arrangedBlocks: [String] = []
    let correctOrder = ["let a = 5", "let b = 10", "print(a + b)"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Arrangement:")
                .font(.subheadline)
                .foregroundColor(.primary)
            HStack {
                ForEach(arrangedBlocks, id: \.self) { block in
                    Text(block)
                        .padding()
                        .background(Color.green.opacity(0.7))
                        .cornerRadius(8)
                }
            }
            .padding()
            Text("Drag the blocks below into the area above:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                ForEach(correctOrder, id: \.self) { block in
                    DraggableCodeBlock(text: block)
                }
            }
            .padding(.horizontal)
            Button("Submit") {
            }
            .padding()
            .buttonStyle(PressableButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Rectangle().fill(Color.blue.opacity(0.1)))
        .cornerRadius(12)
        .onDrop(of: ["public.text"], isTargeted: nil) { providers in
            if let provider = providers.first {
                provider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, _ in
                    if let data = data as? Data,
                       let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            arrangedBlocks.append(text)
                        }
                    }
                }
                return true
            }
            return false
        }
    }
}

extension Lesson {
    static func sampleLessons() -> [Lesson] {
        var lessons: [Lesson] = []
        lessons.append(Lesson(
            id: 1,
            title: "Python Lesson 1: Variables",
            language: .python,
            type: .lesson,
            detailDescription: "Learn how to declare variables in Python. This lesson shows a prepared example.",
            codeSample: "x = 5\nprint(x)",
            expectedOutput: "5",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 2,
            title: "Python Quiz 1: Print Statement",
            language: .python,
            type: .quiz,
            detailDescription: "Test your understanding of the print function.",
            codeSample: nil,
            expectedOutput: nil,
            quizQuestion: "What is the output of print('Hello, World!')?",
            correctAnswer: "Hello, World!",
            quizSubType: .dragDrop,
            editable: false))
        lessons.append(Lesson(
            id: 3,
            title: "Python Game: Code Arrangement",
            language: .python,
            type: .game,
            detailDescription: "Arrange the code blocks in the correct order to complete the program.",
            codeSample: nil,
            expectedOutput: nil,
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 4,
            title: "Python Lesson 2: If-Else Statements",
            language: .python,
            type: .lesson,
            detailDescription: "Learn how to use if-else statements to control the flow of your programs.",
            codeSample: "x = 5\nif x > 3:\n    print('Yes')\nelse:\n    print('No')",
            expectedOutput: "Yes",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 5,
            title: "Python Quiz 2: If-Else True/False",
            language: .python,
            type: .quiz,
            detailDescription: "Determine if the statement about if-else logic is true.",
            codeSample: nil,
            expectedOutput: nil,
            quizQuestion: "In Python, the else block is executed only if the if condition is false.",
            correctAnswer: "True",
            quizSubType: .trueFalse,
            editable: false))
        lessons.append(Lesson(
            id: 6,
            title: "Python Lesson 3: For Loops",
            language: .python,
            type: .lesson,
            detailDescription: "Learn how to iterate over sequences using for loops.",
            codeSample: "for i in range(3):\n    print(i)",
            expectedOutput: "0\n1\n2",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 7,
            title: "Python Quiz 3: Loop Output Matching",
            language: .python,
            type: .quiz,
            detailDescription: "Match the correct output of the loop.",
            codeSample: nil,
            expectedOutput: nil,
            quizQuestion: "Match the output for: for i in range(3): print(i)",
            correctAnswer: "0\n1\n2",
            quizSubType: .matching,
            editable: false))
        lessons.append(Lesson(
            id: 8,
            title: "Python Lesson 4: Functions",
            language: .python,
            type: .lesson,
            detailDescription: "Learn how to define and call functions in Python.",
            codeSample: "def greet():\n    print('Hello')\ngreet()",
            expectedOutput: "Hello",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 9,
            title: "Python Quiz 4: Debug Function Code",
            language: .python,
            type: .quiz,
            detailDescription: "Fix the function so it correctly prints 'Hello'. Drag the corrected code into the blank.",
            codeSample: "def greet()\n    print('Hello')\ngreet()",
            expectedOutput: nil,
            quizQuestion: "Drag the corrected code into the blank so the function prints 'Hello' correctly.",
            correctAnswer: "def greet():\n    print('Hello')\ngreet()",
            quizSubType: .debug,
            editable: false))
        lessons.append(Lesson(
            id: 10,
            title: "Python Lesson 5: Math Operations",
            language: .python,
            type: .lesson,
            detailDescription: "Learn how Python handles mathematical operations.",
            codeSample: "result = 2 + 3 * 4\nprint(result)",
            expectedOutput: "14",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 11,
            title: "Python Quiz 5: Correct Code for Math",
            language: .python,
            type: .quiz,
            detailDescription: "Correct the code to achieve the proper order of operations. Drag the corrected code into the blank.",
            codeSample: "result = (2 + 3) * 4\nprint(result)",
            expectedOutput: nil,
            quizQuestion: "Drag the corrected code into the blank to get the proper mathematical result.",
            correctAnswer: "result = 2 + 3 * 4\nprint(result)",
            quizSubType: .correctCode,
            editable: false))
        
        lessons.append(Lesson(
            id: 1,
            title: "Swift Lesson 1: Variables",
            language: .swift,
            type: .lesson,
            detailDescription: "Learn how to declare variables in Swift. This example is prepared.",
            codeSample: "var x = 5\nprint(x)",
            expectedOutput: "5",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 2,
            title: "Swift Quiz 1: Print Statement",
            language: .swift,
            type: .quiz,
            detailDescription: "Test your understanding of Swift's print function.",
            codeSample: nil,
            expectedOutput: nil,
            quizQuestion: "What is the output of print(\"Hello, World!\")?",
            correctAnswer: "Hello, World!",
            quizSubType: .dragDrop,
            editable: false))
        lessons.append(Lesson(
            id: 3,
            title: "Swift Game: Code Arrangement",
            language: .swift,
            type: .game,
            detailDescription: "Arrange the code blocks in the correct order to form a valid Swift program.",
            codeSample: nil,
            expectedOutput: nil,
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 4,
            title: "Swift Lesson 2: If-Else Statements",
            language: .swift,
            type: .lesson,
            detailDescription: "Learn how to use if-else statements in Swift to control the flow of your program.",
            codeSample: "let x = 5\nif x > 3 {\n    print(\"Yes\")\n} else {\n    print(\"No\")\n}",
            expectedOutput: "Yes",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 5,
            title: "Swift Quiz 2: If-Else True/False",
            language: .swift,
            type: .quiz,
            detailDescription: "Determine if the statement about Swift's if-else logic is true.",
            codeSample: nil,
            expectedOutput: nil,
            quizQuestion: "In Swift, the else block is executed only if the if condition is false.",
            correctAnswer: "True",
            quizSubType: .trueFalse,
            editable: false))
        lessons.append(Lesson(
            id: 6,
            title: "Swift Lesson 3: For Loops",
            language: .swift,
            type: .lesson,
            detailDescription: "Learn how to iterate over a range using for loops in Swift.",
            codeSample: "for i in 0..<3 {\n    print(i)\n}",
            expectedOutput: "0\n1\n2",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 7,
            title: "Swift Quiz 3: Loop Output Matching",
            language: .swift,
            type: .quiz,
            detailDescription: "Match the correct output for the given loop.",
            codeSample: nil,
            expectedOutput: nil,
            quizQuestion: "Match the output for: for i in 0..<3 { print(i) }",
            correctAnswer: "0\n1\n2",
            quizSubType: .matching,
            editable: false))
        lessons.append(Lesson(
            id: 8,
            title: "Swift Lesson 4: Functions",
            language: .swift,
            type: .lesson,
            detailDescription: "Learn how to define and call functions in Swift.",
            codeSample: "func greet() {\n    print(\"Hello\")\n}\ngreet()",
            expectedOutput: "Hello",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 9,
            title: "Swift Quiz 4: Debug Function Code",
            language: .swift,
            type: .quiz,
            detailDescription: "Fix the function so it prints 'Hello' correctly. Drag the corrected code into the blank.",
            codeSample: "func greet() {\nprint(\"Hello\")\n\ngreet()",
            expectedOutput: nil,
            quizQuestion: "Drag the corrected code into the blank so the function prints 'Hello' correctly.",
            correctAnswer: "func greet() {\n    print(\"Hello\")\n}\ngreet()",
            quizSubType: .debug,
            editable: false))
        lessons.append(Lesson(
            id: 10,
            title: "Swift Lesson 5: Math Operations",
            language: .swift,
            type: .lesson,
            detailDescription: "Learn how Swift evaluates mathematical expressions.",
            codeSample: "let result = 2 + 3 * 4\nprint(result)",
            expectedOutput: "14",
            quizQuestion: nil,
            correctAnswer: nil,
            quizSubType: nil,
            editable: false))
        lessons.append(Lesson(
            id: 11,
            title: "Swift Quiz 5: Correct Code for Math",
            language: .swift,
            type: .quiz,
            detailDescription: "Correct the code to achieve the proper order of operations. Drag the corrected code into the blank.",
            codeSample: "let result = (2 + 3) * 4\nprint(result)",
            expectedOutput: nil,
            quizQuestion: "Drag the corrected code into the blank to get the correct result.",
            correctAnswer: "let result = 2 + 3 * 4\nprint(result)",
            quizSubType: .correctCode,
            editable: false))
        return lessons
    }
}
