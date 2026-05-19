import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdown = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                if markdown.isEmpty {
                    ProgressView()
                        .tint(.appPrimary)
                        .padding(.top, 40)
                } else {
                    PolicyMarkdownText(source: markdown)
                        .padding(18)
                        .appCard(accent: .primary, highlighted: true)
                        .padding(20)
                }
            }
            .transparentAppScreen()
            .appScreenBackground()
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        HapticService.lightTap()
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.appPrimary)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadPolicy()
        }
    }

    private func loadPolicy() {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            markdown = "# Privacy Policy\n\nUnable to load policy file."
            return
        }
        markdown = text
    }
}
