import SwiftUI

@main
struct MyApp: App {
    @State private var showIntro = false
    @State private var showPlayground = false
    @State private var showLearn = false
    @State private var showPractice = false
    @State private var showFun = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showPlayground {
                    Playground(showPlayground: $showPlayground)
                        .transition(.opacity)
                } else if showIntro {
                    Intro(showIntro: $showIntro)
                        .transition(.opacity)
                } else if showPractice {
                    Practice(showPractice: $showPractice)
                        .transition(.opacity)
                } else if showFun {
                    PlayMoji(showFun: $showFun)
                        .transition(.opacity)
                } else if showLearn {
                    LearningView(showLearn: $showLearn)
                        .transition(.opacity)
                } else {
                    ContentView(showIntro: $showIntro,
                                showPlayground: $showPlayground,
                                showLearn: $showLearn,
                                showPractice: $showPractice,
                                showFun: $showFun)
                    .transition(.opacity)
                }
            }
        }
    }
}
