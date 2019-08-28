//
//  Countries.swift
//  DeepLife
//
//

import Foundation

import Alamofire

import SwiftyJSON

class Countries {
    
    static let shared = Countries()
    
    var allCountries: [Country] = [Country(id: 9999, name: "Could not load countries")]
    
    func loadCountries() {
        
        guard let currentUserId = Auth.auth.currentUserId else {
            
            return
            
        }
        
        let userDataParameters: Parameters = [
            
            "user_id" : currentUserId
            
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        Alamofire.request(APIRoute.shared.getCountriesListURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                if let countriesList = jsonData["countries"].dictionaryObject {
                    
                    for (_ , country) in countriesList.enumerated() {
                        
                        guard let countryValue = country.value as? String else { continue }
                        
                        guard let countryKey = Int(country.key) else { continue }
                        
                        strongSelf.allCountries.append(Country(id: countryKey, name: countryValue))
                        
                    }
                    
                    strongSelf.allCountries.sort(by: { $0.name < $1.name })
                    
                }
                
            }
            
        }
        
    }
    
    /*
    func getCountries() -> [Country] {
        
        var allCountries: [Country] = [Country]()
        
        allCountries.append(Country(id: 8, name: "Angola"))
        
        allCountries.append(Country(id: 30, name: "Botswana"))
        
        allCountries.append(Country(id: 49, name: "Comoros"))
        
        allCountries.append(Country(id: 111, name: "Kenya"))
        
        allCountries.append(Country(id: 121, name: "Lesotho"))
        
        allCountries.append(Country(id: 129, name: "Madagascar"))
        
        allCountries.append(Country(id: 130, name: "Malawi"))
        
        allCountries.append(Country(id: 148, name: "Mozambique"))
        
        allCountries.append(Country(id: 150, name: "Namibia"))
        
        allCountries.append(Country(id: 180, name: "Rwanda"))
        
        allCountries.append(Country(id: 190, name: "Seychelles"))
        
        allCountries.append(Country(id: 197, name: "South Africa"))
        
        allCountries.append(Country(id: 206, name: "Swaziland"))
        
        allCountries.append(Country(id: 212, name: "Tanzania, United Republic of"))
        
        allCountries.append(Country(id: 223, name: "Uganda"))
        
        allCountries.append(Country(id: 240, name: "Zaire"))
        
        allCountries.append(Country(id: 241, name: "Zambia"))
        
        allCountries.append(Country(id: 242, name: "Zimbabwe"))
        
        return allCountries
        
    }
    */
    
}
