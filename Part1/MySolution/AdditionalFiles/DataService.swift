import Foundation

enum Request {
    static var testRequest = "testreq"
}

class DataService {
    func fetch(completion: @escaping (([Details]) -> Void)) throws {
        guard let url = URL(string: Request.testRequest) else {
            // handle error
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                // handle error
                return
            }
            
            do {
                let json = try JSONDecoder().decode([Details].self, from: data)
                completion(json)
            } catch {
                // handle error
            }
        }.resume()
    }
}
