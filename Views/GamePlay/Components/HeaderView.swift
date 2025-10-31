import SwiftUI

struct HeaderView: View {
    let score: Int
    let roundText: String
    let remainingTime: Int

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 26))
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.yellow)
            }

            Spacer()

            Text(roundText)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white.opacity(0.9))

            Spacer()

            Text("⏱ \(remainingTime)s")
                .font(.title3.bold())
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}