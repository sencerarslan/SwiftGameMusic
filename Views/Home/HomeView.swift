import SwiftUI

struct HomeView: View {
    @State private var highScore = HighScoreManager.shared.value
    @State private var selectedLanguage: String? = nil
    @State private var selectedCategory: String? = nil
    @State private var navigateToGame = false
    @State private var showContent = false

    // MARK: - Language Options
    let languages = [
        ("Turkish", "t.circle.fill"),    
        ("English", "e.circle.fill")
    ]

    // MARK: - Music Categories
    let categories = [
        ("Pop", "music.mic"),
        ("Rock", "guitars"),
        ("Rap", "music.note.list"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.black, Color.black.opacity(0.9)],
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
         
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 140)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeOut(duration: 0.8), value: showContent)
 
                        SectionView(
                            title: "Languages",
                            items: languages,
                            isCategory: false,
                            selectedItem: $selectedLanguage
                        )
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8).delay(0.2), value: showContent)

                        SectionView(
                            title: "Categories",
                            items: categories,
                            isCategory: true,
                            selectedItem: $selectedCategory
                        )
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8).delay(0.3), value: showContent)

                        VStack(spacing: 28) {
                            NavigationLink(
                                destination: CountdownView(
                                    selectedLanguage: selectedLanguage ?? "Turkish",
                                    selectedCategory: selectedCategory ?? "Pop"
                                )
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true),
                                isActive: $navigateToGame
                            ) { EmptyView() }

                            Button(action: {
                                if selectedCategory != nil {
                                    navigateToGame = true
                                }
                            }) {
                                Text("START")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        LinearGradient(colors: [.green, .mint],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                    )
                                    .clipShape(Capsule())
                                    .shadow(color: .green.opacity(0.6), radius: 12, x: 0, y: 6)
                            }
                            .padding(.horizontal, 50)
                            .opacity(selectedCategory == nil ? 0.5 : 1)
                            .disabled(selectedCategory == nil)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).delay(0.4), value: showContent)

                            VStack(spacing: 6) {
                                Text("High Score")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("\(highScore)")
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                    .shadow(color: .white.opacity(0.25), radius: 10)
                            }
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8).delay(0.5), value: showContent)
                        }
                        .padding(.bottom, 60)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) { showContent = true }
                highScore = HighScoreManager.shared.value
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
 
