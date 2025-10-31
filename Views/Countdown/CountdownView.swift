import SwiftUI

struct CountdownView: View {
    let selectedLanguage: String
    let selectedCategory: String

    @State private var countdown = 3
    @State private var showGo = false
    @State private var navigateToGame = false
    @StateObject private var viewModel: GamePlayViewModel

    init(selectedLanguage: String, selectedCategory: String) {
        self.selectedLanguage = selectedLanguage
        self.selectedCategory = selectedCategory
        _viewModel = StateObject(wrappedValue: GamePlayViewModel(
            selectedLanguage: selectedLanguage,
            selectedCategory: selectedCategory
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.black, Color.black.opacity(0.8)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                Group {
                    if showGo {
                        Text("GO!")
                            .font(.system(size: 110, weight: .heavy))
                            .foregroundColor(.green)
                            .scaleEffect(showGo ? 1.2 : 1.0)
                            .transition(.scale)
                            .shadow(color: .green.opacity(0.8), radius: 20)
                    } else {
                        Text("\(countdown)")
                            .font(.system(size: 120, weight: .bold))
                            .foregroundColor(.white)
                            .scaleEffect(1.3)
                            .transition(.opacity)
                            .shadow(color: .white.opacity(0.8), radius: 20)
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: countdown)
 
                NavigationLink(
                    destination: GamePlayView(viewModel: viewModel)
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true),
                    isActive: $navigateToGame
                ) { EmptyView() }
            }
            .onAppear { startCountdownAndFetch() }
        }
    }

    private func startCountdownAndFetch() {
        AudioManager.shared.playEffect(named: "time", loops: 0)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                AudioManager.shared.stop()

                withAnimation(.easeInOut(duration: 0.4)) {
                    showGo = true
                }

                AudioManager.shared.playEffect(named: "start", loops: 0)
 
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    Task {
                        await viewModel.loadSongsFromAPI()
 
                        withAnimation(.easeOut(duration: 0.5)) {
                            showGo = false
                        }

                        AudioManager.shared.stop()
                        navigateToGame = true
                    }
                }
            }
        }
    }
}
#Preview {
    CountdownView(  selectedLanguage: "Turkish", selectedCategory: "Pop")
}
