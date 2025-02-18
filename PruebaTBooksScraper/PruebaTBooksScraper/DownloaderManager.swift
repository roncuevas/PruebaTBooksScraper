import Foundation

import Foundation

final class DownloaderManager {
    func downloadPDF(from url: URL?,
                     folder: String,
                     customName: String) async throws {
        guard let url else {
            throw URLError(.badURL)
        }
        
        let (tempURL, _) = try await URLSession.shared.download(from: url)
        let destinationURL = try buildDestinationURL(in: folder,
                                                     with: customName)
        
        let fileManager = FileManager.default
        
        // Si el archivo ya existe, eliminarlo
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.moveItem(at: tempURL, to: destinationURL)
        print("Archivo guardado en: \(destinationURL.path)")
    }
    
    private func buildDestinationURL(in folder: String,
                                     with customName: String) throws -> URL {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "DownloaderManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo acceder al directorio de documentos"])
        }
        
        let categoryFolder = documentsURL
            .appendingPathComponent(folder)
        
        // Crear los directorios si no existen
        try fileManager.createDirectory(at: categoryFolder, withIntermediateDirectories: true)
        
        return categoryFolder.appendingPathComponent("\(customName)")
    }
}
