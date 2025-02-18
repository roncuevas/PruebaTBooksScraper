import Foundation
import SwiftSoup

@main
struct Scraper {
    static func main() async {
        let url = "https://pruebat.org/biblioteca-digital"
        var libros = [LibroModel]()
        let databaseManager = DatabaseManager.shared
        do {
            guard let url = URL(string: url) else { return }
            let html = try String(contentsOf: url, encoding: .utf8)
            let document = try SwiftSoup.parse(html)
            let items = try document.select(".title-item-book a")
            for (index, item) in items.enumerated() {
                print("-> Looking into item #\(index)")
                let stringURL = try item.attr("href")
                guard let url = URL(string: stringURL) else { return }
                let id = url.lastPathComponent
                print("-> ID: \(id)")
                guard try databaseManager.fetch(predicate: #Predicate<LibroModel> { $0.id == id }).count == 0 else { continue }
                let html = try String(contentsOf: url, encoding: .utf8)
                let document = try SwiftSoup.parse(html)
                let urlDescarga =  try document.select("a.btn-book-link").array()
                if !urlDescarga.isEmpty {
                    print("--> Found \(urlDescarga.count) download urls")
                }
                let libroModel = LibroModel(id: id,
                                            nombre: try item.text(),
                                            url: stringURL,
                                            urlDescarga: try urlDescarga.map { try $0.attr("href") })
                libros.append(libroModel)
                try databaseManager.insert(model: libroModel)
            }
            let downloaderManager = DownloaderManager()
            let librosDB = try databaseManager.fetch(predicate: #Predicate<LibroModel> { $0.nombre != "" })
            var contadorDescargados = 0
            for libro in librosDB {
                let urlsValidas = libro.urlDescarga.compactMap { URL(string: $0) }
                for url in urlsValidas {
                    do {
                        print("Descargando item #\(contadorDescargados)")
                        try await downloaderManager.downloadPDF(from: url,
                                                                folder: "LibrosPruebaT",
                                                                customName: url.lastPathComponent)
                        contadorDescargados += 1
                    } catch {
                        print("Error al descargar \(url): \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            print(String(describing: error))
        }
    }
}
