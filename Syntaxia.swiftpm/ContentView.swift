import SwiftUI
import SceneKit
import AVKit
import AVFoundation

class MusicManager: ObservableObject {
    static let shared = MusicManager()
    
    private var player: AVAudioPlayer?
    
    @Published var volume: Float = 0.05 {
        didSet {
            player?.volume = volume
        }
    }
    
    @Published var isPlaying: Bool = true {
        didSet {
            if isPlaying {
                play()
            } else {
                pause()
            }
        }
    }
    
    init() {
        guard let path = Bundle.main.path(forResource: "Background", ofType: "mp3") else {
            print("Background.mp3 not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = volume
            if isPlaying {
                player?.play()
            }
        } catch {
            print("Error initializing background music: \(error)")
        }
    }
    
    func play() {
        print("MusicManager: play music")
        player?.play()
    }
    
    func pause() {
        print("MusicManager: pause music")
        player?.pause()
    }
}

struct ContentView: View {
    @Binding var showIntro: Bool
    @Binding var showPlayground: Bool
    @Binding var showLearn: Bool
    @Binding var showPractice: Bool
    @Binding var showFun: Bool
    @State private var showSettings = false
    @State private var showCredits = false
    @State private var fadeToBlack = false
    
    var body: some View {
        Group {
            if showIntro {
                Intro(showIntro: $showIntro)
                    .transition(.opacity)
                    .onAppear {
                        print("Intro view appeared")
                    }
            } else {
                ZStack {
                    LoopingVideoView(videoName: "background", videoType: "mp4")
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    
                    HStack {
                        VStack(spacing: 15) {
                            Text("SYNTAXIA")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("MAIN MENU")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.vertical)
                            
                            MenuButton(text: "NEW GAME") {
                                print("NEW GAME tapped")
                                withAnimation(.easeInOut(duration: 2)) {
                                    fadeToBlack = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    print("Switching to Intro view")
                                    MusicManager.shared.pause()
                                    fadeToBlack = false
                                    showIntro = true
                                }
                            }
                            
                            MenuButton(text: "PLAYGROUND") {
                                print("PLAYGROUND tapped")
                                MusicManager.shared.pause()
                                withAnimation(.easeInOut(duration: 2)) {
                                    fadeToBlack = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    print("Switching to Playground view")
                                    MusicManager.shared.pause()
                                    fadeToBlack = false
                                    showPlayground = true
                                }
                            }
                            
                            MenuButton(text: "PRACTICE/ CHALLENGE") {
                                print("PRACTICE tapped")
                                MusicManager.shared.pause()
                                withAnimation(.easeInOut(duration: 2)) {
                                    fadeToBlack = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    print("Switching to Playground view")
                                    MusicManager.shared.pause()
                                    fadeToBlack = false
                                    showPractice = true
                                }
                            }
                            
                            MenuButton(text: "LEARN") {
                                MusicManager.shared.pause()
                                print("LEARN tapped")
                                withAnimation(.easeInOut(duration: 2)) {
                                    fadeToBlack = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    print("Switching to Learn view")
                                    MusicManager.shared.pause()
                                    fadeToBlack = false
                                    showLearn = true
                                }
                            }
                            
                            MenuButton(text: "FUN BOX") {
                                print("Fun tapped")
                                MusicManager.shared.pause()
                                withAnimation(.easeInOut(duration: 2)) {
                                    fadeToBlack = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    MusicManager.shared.pause()
                                    fadeToBlack = false
                                    showFun = true
                                }
                            }
                            
                            Divider()
                                .background(Color.white)
                                .padding(.vertical)
                            
                            MenuButton(text: "SETTINGS") {
                                print("SETTINGS tapped")
                                showSettings = true
                            }
                            MenuButton(text: "CREDITS") {
                                print("CREDITS tapped")
                                showCredits = true
                            }
                            
                            Button(action: {
                                print("EXIT tapped")
                            }) {
                                Text("EXIT")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .frame(width: UIScreen.main.bounds.width * 0.3)
                        .offset(x: UIScreen.main.bounds.width * 0.015)
                        
                        SceneView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(20)
                            .background(Color.black)
                            .padding()
                            .blendMode(.destinationOver)
                            .opacity(0)
                    }
                    
                    if showSettings {
                        SettingsView(isPresented: $showSettings)
                    }
                    
                    if showCredits {
                        CreditsView(isPresented: $showCredits)
                    }
                    
                    if fadeToBlack {
                        Color.black
                            .ignoresSafeArea()
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 2))
                    }
                }
                .onAppear {
                    print("ContentView appeared: starting background music")
                    MusicManager.shared.play()
                }
            }
        }
        .animation(.easeInOut, value: showIntro)
    }
}

struct MenuButton: View {
    let text: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            Text(text)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.3))
                .cornerRadius(10)
        }
    }
}

struct LoopingVideoView: UIViewRepresentable {
    let videoName: String
    let videoType: String
    
    func makeUIView(context: Context) -> LoopingPlayerUIView {
        let view = LoopingPlayerUIView()
        view.setupVideo(videoName: videoName, videoType: videoType)
        return view
    }
    
    func updateUIView(_ uiView: LoopingPlayerUIView, context: Context) {}
}

class LoopingPlayerUIView: UIView {
    private var player: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    func setupVideo(videoName: String, videoType: String) {
        guard let path = Bundle.main.path(forResource: videoName, ofType: videoType) else {
            print("Video file \(videoName).\(videoType) not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        let queuePlayer = AVQueuePlayer(playerItem: item)
        queuePlayer.isMuted = true
        self.player = queuePlayer
        
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        
        let playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        queuePlayer.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.forEach { sublayer in
            if let playerLayer = sublayer as? AVPlayerLayer {
                playerLayer.frame = bounds
            }
        }
    }
}
