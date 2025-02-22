import SwiftUI
import AVKit
import AVFoundation

enum SystemOverlay: Equatable {
    case image(String)
    case blackScreenWithText(String)
}

struct Story: View {
    @Binding var showIntro: Bool
    @State private var currentIndex = 0
    @State private var showChoice = false
    @State private var choices: [String] = []
    @State private var dialogText = ""
    @State private var speakerVoice = ""
    @State private var currentVideo = "idle"
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showQuiz = false
    @State private var quizQuestion = ""
    @State private var quizChoices: [String] = []
    @State private var quizCorrectIndex = 0
    @State private var quizMessage = ""
    @State private var showQuizMessage = false
    @State private var systemOverlay: SystemOverlay? = nil
    
    let script: [ScriptLine] = [
        ScriptLine(action: .playVideo("idle")),
        ScriptLine(speaker: .yuki, text: "Ought, What happen? What is this place", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "VIRUS! VIRUS!"),
        ScriptLine(speaker: .yuki, text: "Hey I not a virus I am a human | What the skipidi are you?", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "I am anti virus and how did you get here?"),
        ScriptLine(speaker: .yuki, text: "I don't know can you help me get out?", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "I not sure I can help but I try my best, Now you should walk to door"),
        ScriptLine(speaker: .yuki, text: "sure (*walk to door)"),
        ScriptLine(action: .playVideo("noss")),
        ScriptLine(speaker: .antivirus, text: "Sudo Summon MacBook , You can keep this Mac book"),
        ScriptLine(speaker: .yuki, text: "~Thank but the door said I need to code something to get value of \"1\" and it given A as \"1\"", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "So first of all I will teach you some code If you using Python user can use '''Swift a = 1''' and it need to get the print as \"1\" you can use \"Print(A)\" for this will output as \"1\""),
        ScriptLine(speaker: .yuki, text: "Print(A)", isChoice: true),
        ScriptLine(action: .playVideo("idle")),
        ScriptLine(speaker: .yuki, text: "Got it the door open", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "Nice ! it look like the system are corrupted an let you here"),
        ScriptLine(speaker: .yuki, text: "And how to get out?", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "You need to edit to computer core to get output here"),
        ScriptLine(speaker: .yuki, text: "How?", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "Walk to the glitch over there and use the computer to analysis the code and tell me what is it"),
        ScriptLine(speaker: .system, text: "show console.png"),
        ScriptLine(speaker: .yuki, text: "Umm It now given more 3 value of W , D ,C  and it given as 5 , 3 , 1 output and need output of 15 , 4 , 8", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "Ohh let me now teach you about basic math in Swift you can use \"+\" to plus , \"-\" to minus , \"*\" to multiply \"/\" to subtract"),
        ScriptLine(action: .playVideo("noss")),
        ScriptLine(speaker: .yuki, text: "umm let me try so to get 15?"),
        ScriptLine(quiz: Quiz(question: "Which operator makes 5 and 3 become 15?", choices: ["+", "-", "*", "/"], correctIndex: 2)),
        ScriptLine(speaker: .antivirus, text: "Nice You got the first one"),
        ScriptLine(speaker: .yuki, text: "Let do the 4"),
        ScriptLine(quiz: Quiz(question: "Which operator makes 3 and 1 become 4?", choices: ["+", "-", "*", "/"], correctIndex: 0)),
        ScriptLine(speaker: .antivirus, text: "Nice You got the second one"),
        ScriptLine(speaker: .yuki, text: "Let to the last one"),
        ScriptLine(quiz: Quiz(question: "Which operator makes 5 and 3 become 8?", choices: ["+", "-", "*", "/"], correctIndex: 0)),
        ScriptLine(speaker: .antivirus, text: "let go!"),
        ScriptLine(speaker: .yuki, text: "Uhhh what happen another glitch?", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "I detecting a virus that let you here and now it start to destory this place. Run to the last room of this hall ways NOW!"),
        ScriptLine(speaker: .yuki, text: "o ok", isChoice: true),
        ScriptLine(speaker: .system, text: "Change to black screen  as show text \"Yuki Run the the system room\""),
        ScriptLine(action: .playVideo("idle")),
        ScriptLine(speaker: .yuki, text: "So Far", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "You done a good job now quick it have only few minute left until this place get desotyr"),
        ScriptLine(speaker: .yuki, text: "What I need to do connect computer with core?", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "You are very smart That right!"),
        ScriptLine(action: .playVideo("boss")),
        ScriptLine(speaker: .yuki, text: "It say uh input is [error] and if the number is even make it show '1\" if false show \"0\"", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "You can use [Null] umm sorry use If else and if to check even number you can use %2 to get Even [wwdc.swift.erorr]"),
        ScriptLine(speaker: .yuki, text: "What happen?", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "No time! It look like I get destroy you can use this code"),
        ScriptLine(speaker: .system, text: "show code of even / odd check python"),
        ScriptLine(speaker: .yuki, text: "Thank you for everything", isChoice: true),
        ScriptLine(speaker: .antivirus, text: "HaP-Py T* Help Good byE Yuki")
    ]
    
    var body: some View {
        ZStack {
            LoopingVideoView2(videoName: $currentVideo, videoType: "mp4")
                .id(currentVideo)
                .ignoresSafeArea()
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: currentVideo)
            VStack {
                Spacer()
                if !dialogText.isEmpty {
                    VisualNovelDialog(message: dialogText)
                        .padding(.bottom, 60)
                }
                if showQuiz {
                    QuizDialog(
                        question: quizQuestion,
                        choices: quizChoices,
                        onChoiceSelected: { index in
                            if index == quizCorrectIndex {
                                showQuiz = false
                                quizMessage = "Correct!"
                                showQuizMessage = true
                            } else {
                                quizMessage = "Wrong!"
                                showQuizMessage = true
                            }
                        }
                    )
                } else if showChoice && !choices.isEmpty {
                    ChoiceDialog(choices: choices) { _ in
                        nextLine()
                    }
                } else if !showQuizMessage && systemOverlay == nil {
                    Button(action: {
                        nextLine()
                    }) {
                        Text("Next")
                            .frame(maxWidth: .infinity, maxHeight: 44)
                    }
                    .contentShape(Rectangle())
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                }
            }
            if showQuizMessage {
                VStack {
                    Spacer()
                    Text(quizMessage)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(10)
                    Button(action: {
                        showQuizMessage = false
                        if quizMessage == "Correct!" {
                            nextLine()
                        }
                    }) {
                        Text("OK")
                            .frame(maxWidth: .infinity, maxHeight: 44)
                    }
                    .contentShape(Rectangle())
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.bottom, 50)
                }
            }
            if let overlay = systemOverlay {
                SystemOverlayView(overlay: overlay) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        systemOverlay = nil
                    }
                    nextLine()
                }
            }
        }
        .onAppear {
            handleLine()
        }
    }
    
    func nextLine() {
        currentIndex += 1
        handleLine()
    }
    
    func handleLine() {
        if currentIndex >= script.count {
            withAnimation(.easeInOut(duration: 0.5)) {
                systemOverlay = .blackScreenWithText("The End")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showIntro = false
                }
            }
            return
        }
        let line = script[currentIndex]
        if let action = line.action {
            switch action {
            case .playVideo(let name):
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentVideo = name
                }
                dialogText = ""
                showChoice = false
                showQuiz = false
                quizChoices = []
                quizQuestion = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    nextLine()
                }
            }
            return
        }
        if let spk = line.speaker, spk == .system {
            if line.text.contains("show console.png") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    systemOverlay = .image("console")
                }
                return
            } else if line.text.contains("Change to black screen") {
                let text = line.text.components(separatedBy: "show text").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                withAnimation(.easeInOut(duration: 0.5)) {
                    systemOverlay = .blackScreenWithText(text.replacingOccurrences(of: "\"", with: ""))
                }
                return
            } else if line.text.contains("show code of even / odd check python") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    systemOverlay = .image("code")
                }
                return
            }
        }
        dialogText = line.text
        showChoice = line.isChoice
        if let spk = line.speaker, spk != .system {
            speakerVoice = spk == .yuki ? "com.apple.ttsbundle.siri_female_en-US_compact" : (spk == .antivirus ? "com.apple.ttsbundle.siri_male_en-US_compact" : "en-US")
            speakText(dialogText, with: speakerVoice)
        }
        if let quizData = line.quiz {
            quizQuestion = quizData.question
            quizChoices = quizData.choices
            quizCorrectIndex = quizData.correctIndex
            showQuiz = true
            showChoice = false
        } else {
            quizQuestion = ""
            quizChoices = []
            showQuiz = false
        }
        if line.isChoice {
            let segments = line.text.components(separatedBy: " | ")
            choices = segments.count > 1 ? segments : ["OK"]
        } else {
            choices = []
        }
    }
    
    func speakText(_ text: String, with voiceID: String) {
        let utterance = AVSpeechUtterance(string: text.replacingOccurrences(of: "|", with: ""))
        if let preferredVoice = AVSpeechSynthesisVoice(identifier: voiceID) {
            utterance.voice = preferredVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}

struct ScriptLine {
    var speaker: Speaker?
    var text: String = ""
    var isChoice: Bool = false
    var action: ScriptAction? = nil
    var quiz: Quiz? = nil
}

struct Quiz {
    var question: String
    var choices: [String]
    var correctIndex: Int
}

enum Speaker {
    case yuki
    case antivirus
    case system
}

enum ScriptAction {
    case playVideo(String)
}

struct ChoiceDialog: View {
    let choices: [String]
    let onChoiceSelected: (Int) -> Void
    var body: some View {
        VStack(spacing: 10) {
            ForEach(choices.indices, id: \.self) { index in
                Button(action: {
                    onChoiceSelected(index)
                }) {
                    Text(choices[index])
                        .frame(maxWidth: .infinity, maxHeight: 44)
                }
                .contentShape(Rectangle())
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
    }
}

struct QuizDialog: View {
    var question: String
    var choices: [String]
    var onChoiceSelected: (Int) -> Void
    var body: some View {
        VStack(spacing: 10) {
            Text(question)
                .font(.headline)
                .foregroundColor(.white)
            ForEach(choices.indices, id: \.self) { i in
                Button(action: {
                    onChoiceSelected(i)
                }) {
                    Text(choices[i])
                        .frame(maxWidth: .infinity, maxHeight: 44)
                }
                .contentShape(Rectangle())
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 50)
    }
}

struct LoopingVideoView2: UIViewRepresentable {
    @Binding var videoName: String
    var videoType: String
    
    func makeUIView(context: Context) -> LoopingPlayerUIView2 {
        let view = LoopingPlayerUIView2(frame: .zero)
        view.updateVideoIfNeeded(videoName: videoName, videoType: videoType)
        return view
    }
    
    func updateUIView(_ uiView: LoopingPlayerUIView2, context: Context) {
        uiView.updateVideoIfNeeded(videoName: videoName, videoType: videoType)
    }
}

class LoopingPlayerUIView2: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    private var currentVideoName: String?
    private var currentVideoType: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateVideoIfNeeded(videoName: String, videoType: String) {
        if videoName != currentVideoName || videoType != currentVideoType {
            currentVideoName = videoName
            currentVideoType = videoType
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let name = currentVideoName,
              let type = currentVideoType,
              let path = Bundle.main.path(forResource: name, ofType: type) else { return }
        let url = URL(fileURLWithPath: path)
        let item = AVPlayerItem(url: url)
        queuePlayer = AVQueuePlayer(items: [item])
        playerLayer.player = queuePlayer
        playerLayer.videoGravity = .resizeAspectFill
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        layer.addSublayer(playerLayer)
        playerLooper = AVPlayerLooper(player: queuePlayer!, templateItem: item)
        queuePlayer?.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

struct SystemOverlayView: View {
    let overlay: SystemOverlay
    let onDismiss: () -> Void
    var body: some View {
        ZStack {
            switch overlay {
            case .image(let imageName):
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding()
            case .blackScreenWithText(let text):
                Color.black
                    .ignoresSafeArea()
                Text(text)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            VStack {
                Spacer()
                Button(action: {
                    onDismiss()
                }) {
                    Text("Continue")
                        .frame(maxWidth: .infinity, maxHeight: 44)
                }
                .contentShape(Rectangle())
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.bottom, 50)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: overlay)
    }
}
