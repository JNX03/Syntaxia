import SwiftUI
import AVKit
import UniformTypeIdentifiers

enum QuizQuestion2Type {
    case trueFalse, dragDrop, multipleChoice, multipleAnswer, ordering, imageSelection, matching, rangeSelection
}

struct QuizQuestion2: Identifiable {
    let id = UUID()
    let question: String
    let type: QuizQuestion2Type
    let correctBool: Bool?
    let correctOperator: String?
    let codeSnippet: String?
    let expectedOutput: String?
    let choices: [String]?
    let correctAnswerMC: String?
    let correctAnswers: [String]?
    let items: [String]?
    let correctOrder: [String]?
    let imageChoices: [String]?
    let correctImage: String?
    let leftItems: [String]?
    let rightItems: [String]?
    let correctMatches: [String: String]?
    let range: ClosedRange<Double>?
    let correctValue: Double?
    let tolerance: Double?
}

struct HardPractice: View {
    @Binding var showPracticeView: Bool
    let timerDuration = PracticeSettings.timer
    @State private var remainingTime: Int = 0
    @State private var endTime: Date = Date()
    @State private var pausedRemainingTime: Int = 0
    @State private var isPaused: Bool = false
    @State private var currentQuestion: QuizQuestion2 = QuizQuestion2(
        question: "Loading...",
        type: .trueFalse,
        correctBool: true,
        correctOperator: nil,
        codeSnippet: nil,
        expectedOutput: nil,
        choices: nil,
        correctAnswerMC: nil,
        correctAnswers: nil,
        items: nil,
        correctOrder: nil,
        imageChoices: nil,
        correctImage: nil,
        leftItems: nil,
        rightItems: nil,
        correctMatches: nil,
        range: nil,
        correctValue: nil,
        tolerance: nil
    )
    @State private var correctCount = 0
    @State private var incorrectCount = 0
    @State private var totalQuestions = 0
    @State private var showResults = false
    @State private var isMusicPaused: Bool = false
    @State private var musicVolume: Float = 0.4
    @State private var showMusicControls: Bool = false
    
    let QuizQuestion2s: [QuizQuestion2] = [
        QuizQuestion2(
            question: "Is Python a statically typed language?",
            type: .trueFalse,
            correctBool: false,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Does Swift support optionals?",
            type: .trueFalse,
            correctBool: true,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Is JavaScript a compiled language?",
            type: .trueFalse,
            correctBool: false,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "SwiftUI is available only on macOS?",
            type: .trueFalse,
            correctBool: false,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Complete the code snippet by dragging the correct operator:",
            type: .dragDrop,
            correctBool: nil,
            correctOperator: "/",
            codeSnippet: "let result = 3 __ 2",
            expectedOutput: "1.5",
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Complete the code snippet by dragging the correct operator:",
            type: .dragDrop,
            correctBool: nil,
            correctOperator: "*",
            codeSnippet: "let product = 4 __ 5",
            expectedOutput: "20",
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Complete the snippet: let diff = 10 __ 3",
            type: .dragDrop,
            correctBool: nil,
            correctOperator: "-",
            codeSnippet: "let diff = 10 __ 3",
            expectedOutput: "7",
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "What is the output of 3.0 / 2.0 in Swift?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: "1.5",
            choices: ["1.0", "1.5", "2.0", "Error"],
            correctAnswerMC: "1.5",
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Which keyword is used to declare constants in Swift?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["let", "var", "const", "def"],
            correctAnswerMC: "let",
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Which language is primarily used for iOS development?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Swift", "Python", "Java", "Ruby"],
            correctAnswerMC: "Swift",
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Select all that are dynamically typed languages:",
            type: .multipleAnswer,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Java", "Ruby", "C++"],
            correctAnswerMC: nil,
            correctAnswers: ["Python", "Ruby"],
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Order these numbers in ascending order:",
            type: .ordering,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: ["8", "3", "5", "1"],
            correctOrder: ["1", "3", "5", "8"],
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Select the heart icon:",
            type: .imageSelection,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: ["heart", "star", "circle", "square"],
            correctImage: "heart",
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Match these fruits with their colors:",
            type: .matching,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: ["Banana", "Apple", "Grape"],
            rightItems: ["Red", "Yellow", "Purple"],
            correctMatches: ["Banana": "Yellow", "Apple": "Red", "Grape": "Purple"],
            range: nil,
            correctValue: nil,
            tolerance: nil
        ),
        QuizQuestion2(
            question: "Set the approximate value of π:",
            type: .rangeSelection,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: 3.0...3.2,
            correctValue: 3.14,
            tolerance: 0.05
        ),
        QuizQuestion2(
            question: "Set the correct brightness value:",
            type: .rangeSelection,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: nil,
            correctAnswerMC: nil,
            correctAnswers: nil,
            items: nil,
            correctOrder: nil,
            imageChoices: nil,
            correctImage: nil,
            leftItems: nil,
            rightItems: nil,
            correctMatches: nil,
            range: 0.0...1.0,
            correctValue: 0.75,
            tolerance: 0.05
        )
    ]
    
    var body: some View {
        ZStack {
            VideoBackgroundView()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            MusicBackgroundView(isPaused: isMusicPaused, volume: musicVolume)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if isPaused {
                            endTime = Date().addingTimeInterval(TimeInterval(pausedRemainingTime))
                            isPaused = false
                        } else {
                            pausedRemainingTime = remainingTime
                            isPaused = true
                        }
                    }) {
                        Text(isPaused ? "Resume Quiz" : "Pause Quiz")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                VStack(spacing: 5) {
                    Text("Time Remaining: \(remainingTime) sec")
                        .font(.title2)
                        .foregroundColor(Color.primary)
                    Text("Hard Practice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                }
                Spacer()
            }
            if !showResults && remainingTime > 0 {
                Group {
                    if currentQuestion.type == .trueFalse {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(currentQuestion.question)
                                .font(.title)
                                .foregroundColor(Color.primary)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                                .cornerRadius(10)
                            HStack(spacing: 20) {
                                Button(action: { answerTrueFalse(answer: true) }) {
                                    Text("Yes")
                                        .bold()
                                        .frame(minWidth: 80)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                Button(action: { answerTrueFalse(answer: false) }) {
                                    Text("No")
                                        .bold()
                                        .frame(minWidth: 80)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    } else if currentQuestion.type == .dragDrop,
                              let codeSnippet = currentQuestion.codeSnippet,
                              let correctOp = currentQuestion.correctOperator {
                        DragDropQuestionView(
                            question: currentQuestion.question,
                            codeSnippet: codeSnippet,
                            correctOperator: correctOp,
                            expectedOutput: currentQuestion.expectedOutput,
                            onAnswer: { isCorrect in
                                totalQuestions += 1
                                if isCorrect { correctCount += 1 } else { incorrectCount += 1 }
                                loadNextQuestion()
                            }
                        )
                    } else if currentQuestion.type == .multipleChoice,
                              let choices = currentQuestion.choices,
                              let correctAnswer = currentQuestion.correctAnswerMC {
                        MultipleChoiceQuestionView(
                            question: currentQuestion.question,
                            choices: choices,
                            correctAnswer: correctAnswer,
                            expectedOutput: currentQuestion.expectedOutput,
                            onAnswer: { isCorrect in
                                totalQuestions += 1
                                if isCorrect { correctCount += 1 } else { incorrectCount += 1 }
                                loadNextQuestion()
                            }
                        )
                    } else if currentQuestion.type == .multipleAnswer,
                              let choices = currentQuestion.choices,
                              let correctAnswers = currentQuestion.correctAnswers {
                        MultipleAnswerQuestionView(
                            question: currentQuestion.question,
                            choices: choices,
                            correctAnswers: correctAnswers,
                            onAnswer: { isCorrect in
                                totalQuestions += 1
                                if isCorrect { correctCount += 1 } else { incorrectCount += 1 }
                                loadNextQuestion()
                            }
                        )
                    } else if currentQuestion.type == .ordering,
                              let items = currentQuestion.items,
                              let correctOrder = currentQuestion.correctOrder {
                        OrderingQuestionView(
                            question: currentQuestion.question,
                            items: items,
                            correctOrder: correctOrder,
                            onAnswer: { isCorrect in
                                totalQuestions += 1
                                if isCorrect { correctCount += 1 } else { incorrectCount += 1 }
                                loadNextQuestion()
                            }
                        )
                    } else if currentQuestion.type == .imageSelection,
                              let imageChoices = currentQuestion.imageChoices,
                              let correctImage = currentQuestion.correctImage {
                        ImageSelectionQuestionView(
                            question: currentQuestion.question,
                            imageChoices: imageChoices,
                            correctImage: correctImage,
                            onAnswer: { isCorrect in
                                totalQuestions += 1
                                if isCorrect { correctCount += 1 } else { incorrectCount += 1 }
                                loadNextQuestion()
                            }
                        )
                    } else if currentQuestion.type == .matching,
                              let leftItems = currentQuestion.leftItems,
                              let rightItems = currentQuestion.rightItems,
                              let correctMatches = currentQuestion.correctMatches {
                        MatchingQuestionView(
                            question: currentQuestion.question,
                            leftItems: leftItems,
                            rightItems: rightItems,
                            correctMatches: correctMatches,
                            onAnswer: { isCorrect in
                                totalQuestions += 1
                                if isCorrect { correctCount += 1 } else { incorrectCount += 1 }
                                loadNextQuestion()
                            }
                        )
                    } else if currentQuestion.type == .rangeSelection,
                              let range = currentQuestion.range,
                              let correctValue = currentQuestion.correctValue,
                              let tolerance = currentQuestion.tolerance {
                        RangeSelectionQuestionView(
                            question: currentQuestion.question,
                            range: range,
                            correctValue: correctValue,
                            tolerance: tolerance,
                            onAnswer: { isCorrect in
                                totalQuestions += 1
                                if isCorrect { correctCount += 1 } else { incorrectCount += 1 }
                                loadNextQuestion()
                            }
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground).opacity(0.9))
                .cornerRadius(12)
                .frame(maxWidth: 350)
                .position(x: UIScreen.main.bounds.width - 170, y: UIScreen.main.bounds.height / 2)
                .offset(x: -UIScreen.main.bounds.width * 0.15)
                .allowsHitTesting(!isPaused)
            }
            if showResults {
                ResultReportView(totalQuestions: totalQuestions, correctCount: correctCount, incorrectCount: incorrectCount) {
                    showPracticeView = false
                    isMusicPaused = true
                    
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showMusicControls = true }) {
                        Image(systemName: "music.note")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showMusicControls) {
            MusicControlView(isPaused: $isMusicPaused, volume: $musicVolume)
        }
        .onAppear {
            endTime = Date().addingTimeInterval(Double(timerDuration))
            loadNextQuestion()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if !isPaused {
                let timeLeft = Int(endTime.timeIntervalSinceNow)
                remainingTime = max(timeLeft, 0)
            } else {
                remainingTime = pausedRemainingTime
            }
            if remainingTime <= 0 && !showResults {
                showResults = true
            }
        }
    }
    
    func answerTrueFalse(answer: Bool) {
        guard !isPaused else { return }
        totalQuestions += 1
        if answer == currentQuestion.correctBool { correctCount += 1 } else { incorrectCount += 1 }
        loadNextQuestion()
    }
    
    func loadNextQuestion() {
        if let randomQuestion = QuizQuestion2s.randomElement() {
            currentQuestion = randomQuestion
        }
    }
}

struct ResultReportView: View {
    let totalQuestions: Int
    let correctCount: Int
    let incorrectCount: Int
    let onDone: () -> Void
    var accuracy: Double {
        totalQuestions > 0 ? (Double(correctCount) / Double(totalQuestions)) * 100 : 0.0
    }
    var body: some View {
        VStack(spacing: 30) {
            Text("Time's Up!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.primary)
            ZStack {
                Circle()
                    .stroke(lineWidth: 15)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)
                    .frame(width: 150, height: 150)
                Circle()
                    .trim(from: 0, to: CGFloat(min(accuracy / 100, 1)))
                    .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: -90))
                    .frame(width: 150, height: 150)
                Text("\(String(format: "%.0f", accuracy))%")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
            }
            VStack(spacing: 10) {
                Text("Total Questions: \(totalQuestions)")
                Text("Correct: \(correctCount)")
                Text("Wrong: \(incorrectCount)")
            }
            .font(.title3)
            .foregroundColor(Color.primary)
            ShareLink(item: "I answered \(totalQuestions) questions with \(correctCount) correct and \(incorrectCount) wrong (Accuracy: \(String(format: "%.1f", accuracy))%) in Hard Practice!") {
                Text("Share")
                    .bold()
                    .frame(minWidth: 120)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: onDone) {
                Text("Done")
                    .bold()
                    .frame(minWidth: 120)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(30)
        .background(Color(UIColor.systemBackground).opacity(0.95))
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxWidth: 350 * 1.15)
    }
}

struct DragDropQuestionView: View {
    let question: String
    let codeSnippet: String
    let correctOperator: String
    let expectedOutput: String?
    var onAnswer: (Bool) -> Void
    @State private var droppedOperator: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title)
                .foregroundColor(Color.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                .cornerRadius(10)
            let parts = codeSnippet.components(separatedBy: "__")
            HStack(spacing: 0) {
                if parts.count == 2 {
                    Text(parts[0])
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Color.primary)
                    Text(droppedOperator ?? "___")
                        .font(.system(.body, design: .monospaced))
                        .padding(8)
                        .background(Color(UIColor.systemBackground).opacity(0.9))
                        .cornerRadius(5)
                        .onDrop(of: [UTType.plainText.identifier], isTargeted: nil) { providers in
                            if let provider = providers.first {
                                _ = provider.loadObject(ofClass: String.self) { (object, error) in
                                    if let op = object as? String {
                                        DispatchQueue.main.async {
                                            droppedOperator = op
                                            onAnswer(op == correctOperator)
                                        }
                                    }
                                }
                                return true
                            }
                            return false
                        }
                    Text(parts[1])
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Color.primary)
                } else {
                    Text(codeSnippet)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(Color.primary)
                }
            }
            .padding()
            .background(Color(UIColor.tertiarySystemBackground).opacity(0.8))
            .cornerRadius(10)
            if let expected = expectedOutput {
                Text("Expected Output: \(expected)")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
            }
            HStack(spacing: 20) {
                ForEach(["+", "-", "*", "/"], id: \.self) { op in
                    Text(op)
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(Color(UIColor.systemGray4))
                        .cornerRadius(10)
                        .onDrag { NSItemProvider(object: op as NSString) }
                }
            }
        }
    }
}

struct MultipleChoiceQuestionView: View {
    let question: String
    let choices: [String]
    let correctAnswer: String
    let expectedOutput: String?
    var onAnswer: (Bool) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title)
                .foregroundColor(Color.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                .cornerRadius(10)
            if let expected = expectedOutput {
                Text("Expected Output: \(expected)")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
            }
            ForEach(choices, id: \.self) { choice in
                Button(action: { onAnswer(choice == correctAnswer) }) {
                    Text(choice)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(Color.primary)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

struct MultipleAnswerQuestionView: View {
    let question: String
    let choices: [String]
    let correctAnswers: [String]
    var onAnswer: (Bool) -> Void
    @State private var selected: Set<String> = []
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title)
                .foregroundColor(Color.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                .cornerRadius(10)
            ForEach(choices, id: \.self) { choice in
                Button(action: {
                    if selected.contains(choice) { selected.remove(choice) } else { selected.insert(choice) }
                }) {
                    HStack {
                        Text(choice)
                            .foregroundColor(Color.primary)
                        Spacer()
                        if selected.contains(choice) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(10)
                }
            }
            Button(action: { onAnswer(Set(correctAnswers) == selected) }) {
                Text("Submit")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct OrderingQuestionView: View {
    let question: String
    let items: [String]
    let correctOrder: [String]
    var onAnswer: (Bool) -> Void
    @State private var available: [String] = []
    @State private var selected: [String] = []
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title)
                .foregroundColor(Color.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                .cornerRadius(10)
            Text("Tap in order:")
                .foregroundColor(Color.primary)
            HStack {
                ForEach(available, id: \.self) { item in
                    Button(action: {
                        selected.append(item)
                        available.removeAll(where: { $0 == item })
                        if selected.count == correctOrder.count {
                            onAnswer(selected == correctOrder)
                        }
                    }) {
                        Text(item)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                    }
                }
            }
            if !selected.isEmpty {
                Text("Your Order: \(selected.joined(separator: ", "))")
                    .foregroundColor(Color.primary)
            }
            Button(action: { available = items.shuffled(); selected = [] }) {
                Text("Reset")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear { available = items.shuffled() }
        .padding()
    }
}

struct ImageSelectionQuestionView: View {
    let question: String
    let imageChoices: [String]
    let correctImage: String
    var onAnswer: (Bool) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title)
                .foregroundColor(Color.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                .cornerRadius(10)
            HStack {
                ForEach(imageChoices, id: \.self) { imageName in
                    Button(action: { onAnswer(imageName == correctImage) }) {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }
}

struct MatchingQuestionView: View {
    let question: String
    let leftItems: [String]
    let rightItems: [String]
    let correctMatches: [String: String]
    var onAnswer: (Bool) -> Void
    @State private var selectedLeft: String? = nil
    @State private var matches: [String: String] = [:]
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title)
                .foregroundColor(Color.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                .cornerRadius(10)
            HStack {
                VStack {
                    ForEach(leftItems, id: \.self) { item in
                        Button(action: { selectedLeft = item }) {
                            Text(item)
                                .padding()
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(10)
                        }
                    }
                }
                VStack {
                    ForEach(rightItems, id: \.self) { item in
                        Button(action: {
                            if let left = selectedLeft {
                                matches[left] = item
                                selectedLeft = nil
                                if matches.count == leftItems.count {
                                    onAnswer(matches == correctMatches)
                                }
                            }
                        }) {
                            Text(item)
                                .padding()
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            if !matches.isEmpty {
                Text("Matches: " + matches.map { "\($0.key)-\($0.value)" }.joined(separator: ", "))
                    .foregroundColor(Color.primary)
            }
            Button(action: { matches = [:] }) {
                Text("Reset")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct RangeSelectionQuestionView: View {
    let question: String
    let range: ClosedRange<Double>
    let correctValue: Double
    let tolerance: Double
    var onAnswer: (Bool) -> Void
    @State private var sliderValue: Double = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title)
                .foregroundColor(Color.primary)
                .padding()
                .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
                .cornerRadius(10)
            Slider(value: $sliderValue, in: range)
            Text("Value: \(String(format: "%.2f", sliderValue))")
                .foregroundColor(Color.primary)
            Button(action: {
                let isCorrect = abs(sliderValue - correctValue) <= tolerance
                onAnswer(isCorrect)
            }) {
                Text("Submit")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear { sliderValue = (range.lowerBound + range.upperBound) / 2 }
        .padding()
    }
}

struct VideoBackgroundView: UIViewRepresentable {
    class Coordinator {
        var player: AVQueuePlayer?
        var looper: AVPlayerLooper?
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        guard let url = Bundle.main.url(forResource: "boss", withExtension: "mp4") else {
            return view
        }
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(playerLayer)
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.playImmediately(atRate: 0.75)
        context.coordinator.player = queuePlayer
        context.coordinator.looper = looper
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct MusicBackgroundView: UIViewRepresentable {
    var isPaused: Bool
    var volume: Float
    class Coordinator {
        var player: AVQueuePlayer?
        var looper: AVPlayerLooper?
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        guard let url = Bundle.main.url(forResource: "boss", withExtension: "mp3") else {
            return view
        }
        let playerItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.volume = volume
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.play()
        context.coordinator.player = queuePlayer
        context.coordinator.looper = looper
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        if let player = context.coordinator.player {
            player.volume = volume
            if isPaused { player.pause() } else { player.play() }
        }
    }
}

struct MusicControlView: View {
    @Binding var isPaused: Bool
    @Binding var volume: Float
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Toggle(isOn: $isPaused) {
                    Text("Music Paused")
                }
                .padding()
                HStack {
                    Text("Volume")
                    Slider(value: Binding(get: {
                        Double(volume)
                    }, set: { newValue in
                        volume = Float(newValue)
                    }), in: 0...1)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Music Controls")
            .padding()
        }
    }
}
