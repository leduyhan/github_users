//// swiftlint:disable all
//// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
//
//import Foundation
//
//// swiftlint:disable superfluous_disable_command file_length implicit_return
//
//// MARK: - Strings
//
//// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
//// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
//public enum NetworkServiceLocalization {
//  /// New
//  public static var networkServiceTextNew: String { return NetworkServiceLocalization.tr("Localizable", "network_service_text_new") }
//}
//// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
//// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces
//
//// MARK: - Implementation Details
//
//extension NetworkServiceLocalization {
//  public static func getByKey(_ key: String, _ args: CVarArg...) -> String {
//    let table = "Localizable"
//        let format = LanguageService.service.dynamicLocalizedString(key, table, bundle: BundleToken.bundle)
//    return String(format: format, locale: Locale.current, arguments: args)
//  }
//
//  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
//        let format = LanguageService.service.dynamicLocalizedString(key, table, bundle: BundleToken.bundle)
//    return String(format: format, locale: Locale.current, arguments: args)
//  }
//}
//private final class BundleToken {
//  static var language: String = "en"
//  static var bundleSetted: Bundle?
//  static var bundle: Bundle {
//      get {
//
//          if let bundleSetted = bundleSetted, language == LanguageService.service.curLanguage {
//              return bundleSetted
//          }
//          language = LanguageService.service.curLanguage
//
//          let myBundle = Bundle(for: BundleToken.self)
//          // Get the URL to the resource bundle within the bundle
//          // of the current class.
//          guard let resourceBundleURL = myBundle.url(
//            forResource: "NetworkService", withExtension: "bundle")
//          else { fatalError(" NetworkService not found!") }
//          if let bundle = Bundle(url: resourceBundleURL) {
//            if let pathSelected = bundle.path(forResource: LanguageService.service.curLanguage, ofType: "lproj"),
//               let bundleSelected = Bundle(path: pathSelected) {
//                bundleSetted = bundleSelected
//                return bundleSelected
//            } else if let pathDefault = bundle.path(forResource: SystemLanguage.en.desc, ofType: "lproj"),
//                      let bundleDefault = Bundle(path: pathDefault) {
//                bundleSetted = bundleDefault
//                return bundleDefault
//            }
//          }
//          return Bundle(for: BundleToken.self)
//      }
//  }
//}
//// swiftlint:enable convenience_type
//// swiftlint:enable all
