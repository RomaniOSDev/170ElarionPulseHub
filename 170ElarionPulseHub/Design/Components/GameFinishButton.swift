import SwiftUI

struct GameFinishButton: View {
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    HStack(spacing: 6) {
                        Image(systemName: "flag.checkered")
                            .font(.subheadline.weight(.bold))
                        Text("Finish")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundColor(.appTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppGradients.primaryButton)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    .appDepthShadow(accent: .accent, elevated: true)
                }
                .buttonStyle(.plain)
                .frame(minWidth: 44, minHeight: 44)
                .padding(.trailing, 12)
                .padding(.bottom, 24)
            }
        }
    }
}
