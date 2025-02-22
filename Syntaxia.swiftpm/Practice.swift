import SwiftUI
import SceneKit
import AVKit
import AVFoundation

public struct PracticeSettings {
    public static var timer: Int = 15
}

struct Practice: View {
    @State private var dialogMessage: String = "Select Your Practice"
    @State private var showPracticeSelection = true
    @State private var showTransition = false
    @State private var showPracticeView = false
    @State private var selectedDifficulty: String = "Hard"
    @State private var localTimerSelection: Int = 15
    @State private var synthesizer = AVSpeechSynthesizer()
    @Binding var showPractice: Bool
    
    var body: some View {
        ZStack {
            LoopingVideoView(videoName: "idle", videoType: "mp4")
                .ignoresSafeArea()
                .allowsHitTesting(false)
            VStack {
                HStack {
                    Button(action: {
                        showPractice = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.leading, 16)
                Spacer()
                Spacer()
                VisualNovelDialog(message: dialogMessage)
            }
            .padding(.bottom, 40)
            if showTransition {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            speakText(dialogMessage)
        }
        .overlay(
            Group {
                if showPracticeSelection {
                    PracticeSelectionDialog(selectedDifficulty: $selectedDifficulty, localTimerSelection: $localTimerSelection) {
                        PracticeSettings.timer = localTimerSelection
                        withAnimation {
                            showPracticeSelection = false
                        }
                        dialogMessage = "Let go!"
                        speakText(dialogMessage)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                showTransition = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showPracticeView = true
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
        )
        .fullScreenCover(isPresented: $showPracticeView, onDismiss: {
            withAnimation {
                showTransition = false
                dialogMessage = "Select Your Practice"
                showPracticeSelection = true
            }
        }) {
            if selectedDifficulty == "Hard" {
                HardPractice(showPracticeView: $showPracticeView)
            } else {
                NorPractice(showPracticeView: $showPracticeView)
            }
        }
    }
    
    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        if let preferredVoice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.voice.Alex") {
            utterance.voice = preferredVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        synthesizer.speak(utterance)
    }
}

struct PracticeSelectionDialog: View {
    @Binding var selectedDifficulty: String
    @Binding var localTimerSelection: Int
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Your Practice")
                .font(.headline)
                .foregroundColor(.white)
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Difficulty")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Button(action: { selectedDifficulty = "Hard" }) {
                        Text("Hard")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedDifficulty == "Hard" ? Color.red : Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    Button(action: { selectedDifficulty = "Normal" }) {
                        Text("Normal")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedDifficulty == "Normal" ? Color.orange : Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
                VStack(spacing: 10) {
                    Text("Timer")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    HStack(spacing: 10) {
                        Button(action: { localTimerSelection = 15 }) {
                            Text("15 sec")
                                .padding()
                                .background(localTimerSelection == 15 ? Color.blue : Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        Button(action: { localTimerSelection = 30 }) {
                            Text("30 sec")
                                .padding()
                                .background(localTimerSelection == 30 ? Color.blue : Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        Button(action: { localTimerSelection = 60 }) {
                            Text("60 sec")
                                .padding()
                                .background(localTimerSelection == 60 ? Color.blue : Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            Button(action: {
                onStart()
            }) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(BlurView(style: .systemThinMaterialDark))
        .cornerRadius(20)
        .padding(.horizontal, 40)
        .shadow(radius: 10)
    }
}
