import SwiftUI

struct OptionButton: View {
    let option: SongOption
    let isSelected: Bool
    let isCorrectPhase: Bool
    let isCorrect: Bool

    var body: some View {
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundColor.opacity(0.4))
                    .blur(radius: 12)
                    .scaleEffect(1.1)
                    .transition(.opacity)
            }
 
            VStack(spacing: 6) {
                Text(option.title)
                    .font(.headline.bold())
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
                Text(option.artist)
                    .font(.subheadline)
                    .opacity(0.8)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.11)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: backgroundColor.opacity(0.8), radius: isSelected ? 15 : 0)
            .scaleEffect(isSelected ? 1.07 : 1.0)
            .animation(.spring(response: 0.45, dampingFraction: 0.65), value: isSelected)
            .animation(.easeInOut(duration: 0.3), value: isCorrectPhase)
        }
        .padding(.horizontal, 4)
    }

    private var backgroundColor: Color {
        if isCorrectPhase {
            if isCorrect { return .green.opacity(0.7) }
            if isSelected { return .red.opacity(0.7) }
            return Color.white.opacity(0.12)
        }
        if isSelected {
            return isCorrect ? .green.opacity(0.7) : .red.opacity(0.7)
        }
        return Color.white.opacity(0.12)
    }
}
