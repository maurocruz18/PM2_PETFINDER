import Foundation
import UIKit

class APIService {
    
    static let shared = APIService()
    private init() {}
 
    private let petsListURL = "https://carlos-aldeias-estg.github.io/pdm2-2025-mock-api/api/pets.json"
    
    func fetchAnimals(completion: @escaping (Bool) -> Void) {	
        
        CoreDataManager.shared.cleanExpiredCache()
        guard let url = URL(string: petsListURL) else {
            print("❌ Erro: URL inválido")
            completion(false)
            return
        }
        
        print("📡 A contactar Mock API...")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print("❌ Erro de rede: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let data = data else {
                print("❌ Dados vazios")
                completion(false)
                return
            }
            
            do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponse.self, from: data)
                            
                    guard let allPets = apiResponse.pets else {
                        print("⚠️ JSON recebido mas sem lista de 'pets'")
                        completion(false)
                        return
                    }
                            
                    
                    let limit = UserDefaults.standard.integer(forKey: "itemsPerPage")
                    let maxItems = limit > 0 ? limit : 20 // Default 20
                            
                    
                    let petsToSave = Array(allPets.prefix(maxItems))
                            
                    print("🔢 Definição de limite: \(maxItems). A guardar \(petsToSave.count) animais.")
                            
                    
                    let context = CoreDataManager.shared.context
                    context.performAndWait {
                        for apiAnimal in petsToSave {
                            CoreDataManager.shared.saveAnimalFromAPI(apiData: apiAnimal)
                        }
                    }
                            
                    print("✅ SUCESSO: \(petsToSave.count) animais carregados da Mock API.")
                    completion(true)
                
            } catch {
                print("❌ Erro ao descodificar JSON: \(error)")
                completion(false)
            }
        }
        task.resume()
    }
}
