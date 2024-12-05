// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Blog
  internal static let textBlog = L10n.tr("Localizable", "text_blog", fallback: "Blog")
  /// Follower
  internal static let textFollower = L10n.tr("Localizable", "text_follower", fallback: "Follower")
  /// Following
  internal static let textFollowing = L10n.tr("Localizable", "text_following", fallback: "Following")
  /// User Details
  internal static let textUserDetailTitle = L10n.tr("Localizable", "text_user_detail_title", fallback: "User Details")
  /// Github Users
  internal static let textUsersTitle = L10n.tr("Localizable", "text_users_title", fallback: "Github Users")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
