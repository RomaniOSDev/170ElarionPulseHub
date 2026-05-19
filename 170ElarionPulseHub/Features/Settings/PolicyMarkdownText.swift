import SwiftUI

/// Renders markdown policy text on iOS 16+ (AttributedString-based; `Markdown` view requires iOS 17).
struct PolicyMarkdownText: View {
    let source: String

    var body: some View {
        Group {
            if let attributed = try? AttributedString(
                markdown: source,
                options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
            ) {
                Text(attributed)
            } else {
                Text(source)
            }
        }
        .foregroundColor(.appTextPrimary)
        .tint(.appPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
