import Foundation

enum AppExternalLink: String {
    case privacyPolicy = "https://elarionpulsehub170.site/privacy/172"
    case termsOfUse = "https://elarionpulsehub170.site/terms/172"
    

    var url: URL? {
        URL(string: rawValue)
    }
}
