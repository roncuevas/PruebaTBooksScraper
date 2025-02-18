import Foundation
import SwiftData

@MainActor
final class DatabaseManager {
    static var shared: DatabaseManager {
        do {
            return try DatabaseManager(type: LibroModel.self)
        } catch {
            fatalError("Failed to initialize DatabaseManager: \(error)")
        }
    }
    let container: ModelContainer
    
    private init<T: PersistentModel>(type: T.Type) throws {
        let storeURL = URL.documentsDirectory.appending(path: "database.sqlite")
        let config = ModelConfiguration(url: storeURL)
        self.container = try ModelContainer(for: T.self,
                                            configurations: config)
    }
    
    func insert(model: any PersistentModel) throws {
        container.mainContext.insert(model)
        try container.mainContext.save()
    }
    
    func fetch<T: PersistentModel>(predicate: Predicate<T>) throws -> [T] {
        return try container.mainContext.fetch(FetchDescriptor(predicate: predicate))
    }
}
