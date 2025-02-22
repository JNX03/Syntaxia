import SwiftUI
import AVKit
import UniformTypeIdentifiers

enum QuizQuestionType2 {
    case trueFalse, dragDrop, multipleChoice, multipleAnswer, ordering, imageSelection, matching, rangeSelection
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let type: QuizQuestionType2
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

struct NorPractice: View {
    @Binding var showPracticeView: Bool
    let timerDuration = PracticeSettings.timer
    @State private var remainingTime: Int = 0
    @State private var endTime: Date = Date()
    @State private var pausedRemainingTime: Int = 0
    @State private var isMusicPaused: Bool = false
    @State private var musicVolume: Float = 0.4
    @State private var showMusicControls: Bool = false
    @State private var isPaused: Bool = false
    @State private var currentQuestion: QuizQuestion = QuizQuestion(
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
    
    let quizQuestions: [QuizQuestion] = [
        // 1. Python Basics (True/False)
        QuizQuestion(
            question: "Is Python a high-level programming language?",
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
        // 2.
        QuizQuestion(
            question: "Does Python use indentation to define code blocks?",
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
        // 3.
        QuizQuestion(
            question: "Is Python case sensitive?",
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
        // 4. Swift Basics (True/False)
        QuizQuestion(
            question: "Is Swift a programming language developed by Apple?",
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
        // 5.
        QuizQuestion(
            question: "Can Swift be used to develop iOS apps?",
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
        // 6.
        QuizQuestion(
            question: "Does Swift use 'let' to declare constants?",
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
        // 7.
        QuizQuestion(
            question: "Does Python support multiple programming paradigms?",
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
        // 8.
        QuizQuestion(
            question: "Can you run Python code without compiling it first?",
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
        // 9.
        QuizQuestion(
            question: "Is Swift an interpreted language?",
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
        // 10. Python: Function definition keyword
        QuizQuestion(
            question: "Which language uses the 'def' keyword to define functions?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Swift", "Java"],
            correctAnswerMC: "Python",
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
        // 11. Swift: Function definition keyword
        QuizQuestion(
            question: "Which language uses 'func' to define functions?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Swift", "Ruby"],
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
        // 12. Python: Comments
        QuizQuestion(
            question: "In Python, which symbol is used for comments?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["//", "#", "/*"],
            correctAnswerMC: "#",
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
        // 13. Swift: Comments
        QuizQuestion(
            question: "In Swift, which symbol is used for single-line comments?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["//", "#", "--"],
            correctAnswerMC: "//",
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
        // 14. Python: Built-in list type
        QuizQuestion(
            question: "Does Python have a built-in list type?",
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
        // 15. Swift: Optionals
        QuizQuestion(
            question: "Does Swift have optionals to handle nil values?",
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
        // 16. Python: print() function
        QuizQuestion(
            question: "Is Python's print() function used to output text?",
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
        // 17. Swift: print() function
        QuizQuestion(
            question: "Is Swift's print() function used to output text?",
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
        // 18. Python: Object-Oriented Programming
        QuizQuestion(
            question: "Does Python support object-oriented programming?",
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
        // 19. Swift: Object-Oriented Programming
        QuizQuestion(
            question: "Does Swift support object-oriented programming?",
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
        // 20. Indentation Syntax
        QuizQuestion(
            question: "Which language uses indentation as a core part of its syntax?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Swift", "Python", "C++"],
            correctAnswerMC: "Python",
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
        // 21. Optionals and Safety
        QuizQuestion(
            question: "Which language is known for its safety features such as optionals?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Swift", "JavaScript"],
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
        // 22. Python: Function Keyword
        QuizQuestion(
            question: "In Python, what keyword is used to create a function?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["func", "def", "function"],
            correctAnswerMC: "def",
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
        // 23. Swift: Function Keyword
        QuizQuestion(
            question: "In Swift, what keyword is used to create a function?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["def", "func", "function"],
            correctAnswerMC: "func",
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
        // 24. Python: None value
        QuizQuestion(
            question: "In Python, is 'None' used to represent the absence of a value?",
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
        // 25. Swift: nil value
        QuizQuestion(
            question: "In Swift, is 'nil' used to represent the absence of a value?",
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
        // 26. Naming Conventions: snake_case
        QuizQuestion(
            question: "Which language uses snake_case as a common naming convention?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Swift", "Both"],
            correctAnswerMC: "Python",
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
        // 27. Naming Conventions: camelCase
        QuizQuestion(
            question: "Which language typically uses camelCase for variable names?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Swift", "Both"],
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
        // 28. Python: Multiple Inheritance
        QuizQuestion(
            question: "Does Python support multiple inheritance?",
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
        // 29. Swift: Multiple Inheritance
        QuizQuestion(
            question: "Does Swift support multiple inheritance?",
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
        // 30. Python: Text Data Type
        QuizQuestion(
            question: "In Python, what data type is used to represent text?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["String", "Int", "Bool"],
            correctAnswerMC: "String",
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
        // 31. Swift: Text Data Type
        QuizQuestion(
            question: "In Swift, what data type is used to represent text?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Text", "String", "char"],
            correctAnswerMC: "String",
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
        // 32. Dynamic Typing
        QuizQuestion(
            question: "Which language uses dynamic typing by default?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Swift", "Both"],
            correctAnswerMC: "Python",
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
        // 33. Static Typing
        QuizQuestion(
            question: "Which language is statically typed by default?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Swift", "Both"],
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
        // 34. Python: Curly Braces
        QuizQuestion(
            question: "Does Python use curly braces {} to define code blocks?",
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
        // 35. Swift: Curly Braces
        QuizQuestion(
            question: "Does Swift use curly braces {} to define code blocks?",
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
        // 36. Data Science in Python
        QuizQuestion(
            question: "Can Python be used for data science and machine learning?",
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
        // 37. Swift: Server-Side
        QuizQuestion(
            question: "Can Swift be used for server-side development?",
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
        // 38. Python: math module
        QuizQuestion(
            question: "Does Python have a built-in module called 'math'?",
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
        // 39. Swift: Math Functions
        QuizQuestion(
            question: "Does Swift have a standard library for math functions?",
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
        // 40. Python: Interpreted
        QuizQuestion(
            question: "Is Python interpreted rather than compiled?",
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
        // 41. Swift: Compiled
        QuizQuestion(
            question: "Is Swift compiled rather than interpreted?",
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
        // 42. Python: Error Handling
        QuizQuestion(
            question: "In Python, which keyword is used for error handling?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["try", "catch", "handle"],
            correctAnswerMC: "try",
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
        // 43. Swift: Error Handling
        QuizQuestion(
            question: "In Swift, which keyword is used for error handling?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["try", "catch", "throw"],
            correctAnswerMC: "try",
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
        // 44. Python: Lambda Functions
        QuizQuestion(
            question: "Does Python support lambda functions?",
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
        // 45. Swift: Closures
        QuizQuestion(
            question: "Does Swift support closures?",
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
        // 46. Python: Length of a List
        QuizQuestion(
            question: "In Python, what function is used to get the length of a list?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["size()", "len()", "count()"],
            correctAnswerMC: "len()",
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
        // 47. Swift: Array Count
        QuizQuestion(
            question: "In Swift, what property is used to get the count of elements in an array?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["length", "count", "size"],
            correctAnswerMC: "count",
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
        // 48. Python: Readability
        QuizQuestion(
            question: "Is Python known for its readability and simplicity?",
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
        // 49. Swift: Performance and Safety
        QuizQuestion(
            question: "Is Swift known for its performance and safety?",
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
        // 50. Scripting and Automation
        QuizQuestion(
            question: "Which language is often used for scripting and automation?",
            type: .multipleChoice,
            correctBool: nil,
            correctOperator: nil,
            codeSnippet: nil,
            expectedOutput: nil,
            choices: ["Python", "Swift", "Both"],
            correctAnswerMC: "Python",
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
    ]
    
    var body: some View {
        ZStack {
            VideoBackgroundView2()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            MusicBackgroundView2(isPaused: isMusicPaused, volume: musicVolume)
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
                        Text(isPaused ? "Resume" : "Pause")
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
                    Text("Normal Practice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                }
                Spacer()
            }
            if !showResults && remainingTime > 0 {
                Group {
                    switch currentQuestion.type {
                    case .trueFalse:
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
                    case .multipleChoice:
                        MultipleChoiceQuestionView(
                            question: currentQuestion.question,
                            choices: currentQuestion.choices ?? [],
                            correctAnswer: currentQuestion.correctAnswerMC ?? "",
                            expectedOutput: currentQuestion.expectedOutput,
                            onAnswer: { isCorrect in
                                totalQuestions += 1
                                if isCorrect { correctCount += 1 } else { incorrectCount += 1 }
                                loadNextQuestion()
                            }
                        )
                    default:
                        EmptyView()
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
        if let randomQuestion = quizQuestions.randomElement() {
            currentQuestion = randomQuestion
        }
    }
}

struct MusicBackgroundView2: UIViewRepresentable {
    var isPaused: Bool
    var volume: Float
    class Coordinator {
        var player: AVQueuePlayer?
        var looper: AVPlayerLooper?
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        guard let url = Bundle.main.url(forResource: "noss", withExtension: "mp3") else {
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

struct VideoBackgroundView2: UIViewRepresentable {
    class Coordinator {
        var player: AVQueuePlayer?
        var looper: AVPlayerLooper?
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        guard let url = Bundle.main.url(forResource: "noss", withExtension: "mp4") else {
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
