import SwiftUI

struct CreditsView: View {
    @Binding var isPresented: Bool
    
    private let creditItems: [String] = [
        "3D Model by @Jnx03 (Chawabhon Netisingha)",
        "Music by @Jnx03 (Chawabhon Netisingha)",
        "Art by @Jnx03 (Chawabhon Netisingha)",
        "Programming by @Jnx03 (Chawabhon Netisingha)",
        "Core Concept by @Jnx03 (Chawabhon Netisingha)"
    ]
    
    @State private var showItems: [Bool] = []
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 16) {
                Text("Credits")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .padding(.top, 20)
                
                Text("To WWDC Swift Student Challenge")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("I am so honored to be part of this inspiring challenge. Thank you for pushing us to innovate, create, and bring our passion for Swift to life!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(creditItems.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                Text(creditItems[index])
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal)
                            .opacity(showItems.indices.contains(index) && showItems[index] ? 1 : 0)
                            .offset(x: showItems.indices.contains(index) && showItems[index] ? 0 : -20)
                            .animation(Animation.easeIn(duration: 0.5).delay(0.2 * Double(index)), value: showItems)
                        }
                    }
                }
                .frame(maxHeight: 300)
                
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: 350)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
            .padding(.vertical, 80)
        }
        .onAppear {
            showItems = Array(repeating: false, count: creditItems.count)
            for index in creditItems.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * Double(index)) {
                    withAnimation {
                        showItems[index] = true
                    }
                }
            }
        }
    }
}
