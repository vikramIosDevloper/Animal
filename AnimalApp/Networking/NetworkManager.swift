//
//  NetworkManager.swift
//  AnimalApp
//
//  Created by apple on 30/06/24.
//

import Foundation


struct DogBread: Codable{
    let message: [String:[String]]
    let status: String
}
struct DogBreedImageResponse: Codable {
    let message: [String]
    let status: String
}

class NetworkManager {
    
    func fetchBreeds(completion: @escaping ([String]?, Error?) -> Void) {
            guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else { return }
          
        
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = json["message"] as? [String: Any] {
                        var breeds = [String]()
                        for (key, value) in message {
                            if let subBreeds = value as? [String], subBreeds.isEmpty {
                                breeds.append(key)
                            } else if let subBreeds = value as? [String] {
                                for subBreed in subBreeds {
                                    breeds.append("\(subBreed) \(key)")
                                }
                            }
                        }
                        breeds.sort()
                        completion(breeds, nil)
                    } else {
                        completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]))
                    }
                } catch {
                    completion(nil, error)
                }
            }
            
            task.resume()
        }
    
    
    func fetchBreedImages(breed: String, completion: @escaping ([String]?, Error?) -> Void) {
        guard let encodedBreed = breed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode breed"]))
            return
        }

        let urlString = "https://dog.ceo/api/breed/\(encodedBreed)/images"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                return
            }

            if httpResponse.statusCode == 404 {
                let errorDescription = "Breed not found"
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: errorDescription]))
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(DogBreedImageResponse.self, from: data)
                completion(decodedData.message, nil)
            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }

    

}
