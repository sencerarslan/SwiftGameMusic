import SwiftUI

struct ProgressRing: View {
    let progress: CGFloat
    let color: Color
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: 220, height: 220)
            .shadow(color: color.opacity(0.5), radius: 10)
            .animation(.easeInOut(duration: 0.5), value: progress)
    }
}
