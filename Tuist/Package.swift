// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    // productType을 지정해 Tuist가 framework로 링크하도록 명시
    productTypes: [
        "ComposableArchitecture": .framework,
        "NMapsMap": .framework,
        "Alamofire": .framework,
        "Moya": .framework,
        "Kingfisher": .framework,
        "FirebaseAnalytics": .framework,
        "FirebaseCore": .framework,
        "FirebaseMessaging": .framework,
        "FirebaseCoreDiagnostics": .framework
    ]
)
#endif

let package = Package(
    name: "DoRunDoRun",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "main"),
        .package(url: "https://github.com/navermaps/SPM-NMapsMap", branch: "main"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.8.0"),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "11.5.0")),
    ]
)
