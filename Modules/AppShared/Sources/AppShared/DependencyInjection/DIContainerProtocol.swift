import Foundation

public protocol DIContainerProtocol: AnyObject {
    func register<T>(type: T.Type, dependency: Any)
    func resolve<T>(type: T.Type) -> T?
}
