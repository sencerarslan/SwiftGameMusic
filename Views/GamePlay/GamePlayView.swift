import SwiftUI

struct GamePlayView: View {
    @StateObject var vm: GamePlayViewModel
    @State private var isSharePresented = false
    @State private var shareImage: UIImage?
 
    @State private var visibleOptionCount = 0

    init(viewModel: GamePlayViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, .gray.opacity(0.25)],
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()

                if vm.gameEnded {
                    gameOverView
                        .transition(.opacity.combined(with: .scale))
                } else {
                    gameContent
                        .transition(.opacity)
                }
            }
            .onDisappear { vm.stopGame() }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: vm.options) { newOptions in
            animateOptions(newOptions)
        }
    }

    // MARK: - Oyun İçeriği
    private var gameContent: some View {
        VStack(spacing: 30) {
            HeaderView(
                score: vm.currentScore,
                roundText: "\(vm.currentRound)/\(vm.totalRounds)",
                remainingTime: vm.remainingTime
            )

            ZStack {
                ProgressRing(progress: vm.progress, color: ringColor)
                albumView
            }
            .id(vm.currentSong?.id)

            optionsView

            if let gain = vm.lastGain {
                Text(gain > 0 ? "+\(gain)" : "+0")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 8)
                    .offset(y: -10)
                    .transition(.scale.combined(with: .opacity).combined(with: .offset(y: -10)))
                    .animation(.easeOut(duration: 0.4), value: vm.lastGain)
            }


            Spacer(minLength: 0)
        }
    }

    // MARK: - Albüm Görseli
    private var albumView: some View {
        Group {
            if let song = vm.currentSong {
                AsyncImage(url: URL(string: song.albumImage)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 200, height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .blur(radius: vm.blurAmount)
                            .animation(.easeInOut(duration: 1), value: vm.blurAmount)
                            .shadow(radius: 20)
                    case .failure:
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 200, height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Circle()
                    .fill(.gray)
                    .frame(width: 200, height: 200)
            }
        }
    }

    // MARK: - İlerleme Rengi
    private var ringColor: Color {
        if vm.remainingTime > 10 { return .green }
        let fraction = Double(10 - vm.remainingTime) / 10
        return Color(
            red: 1.0 * fraction + 0.0 * (1 - fraction),
            green: 1.0 * (1 - fraction),
            blue: 0.0
        )
    }

    // MARK: - Seçenekler Görünümü (Animasyonlu)
    private var optionsView: some View {
        let columns = [GridItem(.flexible(), spacing: 15), GridItem(.flexible(), spacing: 15)]
        return LazyVGrid(columns: columns, spacing: 15) {
            ForEach(Array(vm.options.prefix(visibleOptionCount))) { option in
                Button { vm.select(option) } label: {
                    OptionButton(
                        option: option,
                        isSelected: vm.selectedOption?.id == option.id,
                        isCorrectPhase: vm.correctOption != nil,
                        isCorrect: option.isCorrect
                    )
                    .scaleEffect(visibleOptionCount > 0 ? 1 : 0.8)
                    .opacity(visibleOptionCount > 0 ? 1 : 0)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .disabled(vm.isSelectionLocked)
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.25), value: visibleOptionCount)
    }

    // MARK: - Oyun Bitti Ekranı
    private var gameOverView: some View {
        VStack(spacing: 25) {
            Text("Game Over")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.yellow)

            VStack(spacing: 8) {
                Text("Your Total Score")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))

                Text("\(vm.currentScore)")
                    .font(.system(size: 52, weight: .heavy))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.7), radius: 10)

                Text("High Score: \(vm.highScore)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 4)
                 
                Button(action: shareScreenshot) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Score")
                    }
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(12)
                }
            }
 
            NavigationLink(
                destination: CountdownView(
                    selectedLanguage: vm.selectedLanguage,
                    selectedCategory: vm.selectedCategory
                )
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
            ) {
                Text("Play Again")
                    .font(.headline.bold())
                    .foregroundColor(.black)
                    .frame(width: 200, height: 50)
                    .background(Color.yellow)
                    .cornerRadius(12)
            }
 
            NavigationLink(
                destination: HomeView()
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
            ) {
                Text("Home")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.green.opacity(0.7))
                    .cornerRadius(12)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .transition(.opacity)
        .sheet(isPresented: $isSharePresented) {
            if let shareImage = shareImage {
                ShareSheet(items: [shareImage])
            }
        }
    }
      

    private func shareScreenshot() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard let image = UIApplication.shared.screenshot() else {
                print("⚠️ Screenshot alınamadı.")
                return
            }
            shareImage = image

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isSharePresented = true
            }
        }
    }



 
    // MARK: - Yardımcı: Seçenekleri sırayla göster
    private func animateOptions(_ newOptions: [SongOption]) {
        visibleOptionCount = 0
        for i in newOptions.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    visibleOptionCount = i + 1
                }
            }
        }
    }
}

