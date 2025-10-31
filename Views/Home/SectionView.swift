import SwiftUI

struct SectionView: View {
    let title: String
    let items: [(String, String)]
    let isCategory: Bool

    @Binding var selectedItem: String?
    @State private var selectedIndex: Int? = nil

    private let categoryColors: [Color] = [
        .purple, .blue, .orange, .teal, .red, .indigo
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        let isSelected = selectedIndex == index
                        ZStack {
                            let baseColor = isCategory
                                ? categoryColors[index % categoryColors.count]
                                : .gray.opacity(0.2)

                            RoundedRectangle(cornerRadius: 22)
                                .fill(baseColor.opacity(0.25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(
                                            isSelected ? Color.green : Color.white.opacity(0.1),
                                            lineWidth: isSelected ? 3 : 1
                                        )
                                )
                                .shadow(color: isSelected ? .green.opacity(0.6) : .clear,
                                        radius: isSelected ? 18 : 0)
                                .scaleEffect(isSelected ? 1.06 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7),
                                           value: selectedIndex)

                            VStack(spacing: 10) {
                                Image(systemName: item.1)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 55, height: 55)
                                    .foregroundColor(.white)
                                    .padding(.top, 25)

                                Spacer()

                                Text(item.0)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 20)
                            }
                            .frame(width: 150, height: 150)
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedIndex = index
                                selectedItem = item.0
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }
}
