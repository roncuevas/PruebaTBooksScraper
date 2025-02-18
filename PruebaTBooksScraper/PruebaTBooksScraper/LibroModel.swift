import SwiftData

@Model
final class LibroModel {
    @Attribute(.unique) var id: String
    var nombre: String
    var url: String
    var urlDescarga: [String]
    
    init(id: String,
         nombre: String,
         url: String,
         urlDescarga: [String]) {
        self.id = id
        self.nombre = nombre
        self.url = url
        self.urlDescarga = urlDescarga
    }
}
