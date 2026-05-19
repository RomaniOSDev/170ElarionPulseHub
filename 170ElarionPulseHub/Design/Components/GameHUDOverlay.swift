import SwiftUI

/// HUD that does not steal touches from the game layer beneath.
struct GameHUDOverlay<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack {
            content()
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    AppCardBackground(accent: .primary, highlighted: false, cornerRadius: 16)
                }
                .appDepthShadow(accent: .primary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            Spacer()
        }
        .allowsHitTesting(false)
    }
}
