//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(coin: CoinModel)
    func didFailWithError(error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "1B573DCF-1871-4D08-9970-171A8D458C34"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequst(with: urlString)
    }
    func performRequst(with urlString: String) {
        //create url
        if let url = URL(string: urlString) {
            //create url session
            let session = URLSession(configuration: .default)
            //give session a task
            let task = session.dataTask(with: url) { data, urlResponse, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                }
                
                if let safeData = data {
                    print(String(data: safeData, encoding: .utf8)!)
                    if let coin = parseJson(safeData) {
                        delegate?.didUpdateCurrency(coin: coin)
                    }
                }
            }
            //start task
            task.resume()
        }
    }
    func parseJson(_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            
            let rate = decodedData.rate
            let currency = decodedData.asset_id_quote
            
            let coinModel = CoinModel(rate: rate, currency: currency)
            print(coinModel)
            return coinModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
