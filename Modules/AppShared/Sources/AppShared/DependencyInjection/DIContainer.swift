import Foundation

public final class DIContainer: DIContainerProtocol {
    public static let shared = DIContainer()
    private var dependencies: [String: Any] = [:]

    private init() { }

    public func register<T>(type: T.Type, dependency: Any) {
        self.dependencies["\(type)"] = dependency
    }

    public func resolve<T>(type: T.Type) -> T? {
        return self.dependencies["\(type)"] as? T
    }
}
