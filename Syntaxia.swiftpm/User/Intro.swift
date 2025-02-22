import SwiftUI
import SceneKit
import AVKit
import AVFoundation

struct Intro: View {
    @State private var dialogMessage: String = "Hi, I yuki chan. What is your name?"
    @State private var showNameInput = false
    @State public var name: String = ""
    @State private var showTransition = false
    @State private var showContentView = false
    @State private var synthesizer = AVSpeechSynthesizer()
    @Binding var showIntro: Bool

    var body: some View {
        ZStack {
            LoopingVideoView(videoName: "intro", videoType: "mp4")
                .ignoresSafeArea()
                .allowsHitTesting(false)
            VStack {
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showNameInput = true
                }
            }
        }
        .overlay(
            Group {
                if showNameInput {
                    NameInputDialog(name: $name) {
                        withAnimation {
                            showNameInput = false
                        }
                        dialogMessage = "Hi, \(name). Nice to meet you."
                        speakText(dialogMessage)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                showTransition = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                showContentView = true
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
        )
        .fullScreenCover(isPresented: $showContentView) {
            Story(showIntro: $showIntro)
        }
    }
    
    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        if let preferredVoice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_ja-JP_compact") {
            utterance.voice = preferredVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        synthesizer.speak(utterance)
    }
}

struct VisualNovelDialog: View {
    var message: String
    var body: some View {
        Text(message)
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
            .padding(.horizontal, 20)
    }
}

struct NameInputDialog: View {
    @Binding var name: String
    var onComplete: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Please enter your name:")
                .font(.headline)
                .foregroundColor(.white)
            TextField("Your name", text: $name)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Button(action: {
                onComplete()
            }) {
                Text("OK")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(BlurView(style: .systemThinMaterialDark))
        .cornerRadius(20)
        .padding(.horizontal, 40)
        .shadow(radius: 10)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterialDark
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}
