import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var musicManager = MusicManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .padding()
            
            Toggle(isOn: $musicManager.isPlaying) {
                Text("Background Music")
                    .font(.headline)
            }
            .padding(.horizontal)
            
            HStack {
                Text("Volume")
                Slider(value: Binding(
                    get: { Double(musicManager.volume) },
                    set: { newValue in
                        musicManager.volume = Float(newValue)
                    }
                ), in: 0...1)
            }
            .padding(.horizontal)
            
            Button("Close") {
                isPresented = false
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: 350)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding()
    }
}

