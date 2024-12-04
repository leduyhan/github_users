@testable import LocalStorage
import XCTest
import Domain
import CoreData

final class CoreDataUserStoreTests: XCTestCase {
    private var sut: CoreDataUserStore!
    
    override func setUp() {
        super.setUp()
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.type = NSInMemoryStoreType
        
        sut = try! CoreDataUserStore(storeURL: storeURL)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let cache = try sut.retrieve()
        XCTAssertNil(cache, "Expected empty cache to deliver nil")
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        _  = try sut.retrieve()
        let cache = try sut.retrieve()
        
        XCTAssertNil(cache, "Expected retrieve to have no side effects on empty cache")
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() throws {
        let users = uniqueUsers()
        let timestamp = Date()
        
        try insert(users, timestamp: timestamp)
        
        let retrievedCache = try sut.retrieve()
        
        XCTAssertEqual(retrievedCache?.users, users)
        XCTAssertEqual(retrievedCache?.timestamp, timestamp)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
        let users = uniqueUsers()
        let timestamp = Date()
        
        try insert(users, timestamp: timestamp)
        
        _ = try sut.retrieve()
        let retrievedCache = try sut.retrieve()
        
        XCTAssertEqual(retrievedCache?.users, users)
        XCTAssertEqual(retrievedCache?.timestamp, timestamp)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let users = uniqueUsers()
        let timestamp = Date()
        
        XCTAssertNoThrow(try insert(users, timestamp: timestamp))
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let users = uniqueUsers()
        let timestamp = Date()
        try insert(users, timestamp: timestamp)
        
        XCTAssertNoThrow(try insert(users, timestamp: timestamp))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        try insert(uniqueUsers(), timestamp: Date())
        
        let latestUsers = uniqueUsers()
        let latestTimestamp = Date()
        try insert(latestUsers, timestamp: latestTimestamp)
        
        let cache = try sut.retrieve()
        
        XCTAssertEqual(cache?.users, latestUsers)
        XCTAssertEqual(cache?.timestamp, latestTimestamp)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() throws {
        XCTAssertNoThrow(try sut.deleteCachedUsers())
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() throws {
        try sut.deleteCachedUsers()
        
        XCTAssertNil(try sut.retrieve())
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() throws {
        try insert(uniqueUsers(), timestamp: Date())
        
        XCTAssertNoThrow(try sut.deleteCachedUsers())
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() throws {
        try insert(uniqueUsers(), timestamp: Date())
        
        try sut.deleteCachedUsers()
        
        XCTAssertNil(try sut.retrieve())
    }
    
    // MARK: - Helpers
    
    private func uniqueUsers() -> [LocalUser] {
        return [
            LocalUser(
                login: "user1",
                avatarURL: "https://any-url.com/user1",
                htmlURL: "https://any-url.com/user1.html"
            ),
            LocalUser(
                login: "user2",
                avatarURL: "https://any-url.com/user2",
                htmlURL: "https://any-url.com/user2.html"
            )
        ]
    }
    
    private func insert(_ users: [LocalUser], timestamp: Date) throws {
        try sut.insert(users, timestamp: timestamp)
    }
}
