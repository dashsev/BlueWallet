//
//  WidgetAPI.swift
//  TodayExtension
//
//  Created by Marcos Rodriguez on 11/2/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation


var numberFormatter: NumberFormatter {
  let formatter = NumberFormatter()
  formatter.numberStyle = .decimal
  formatter.maximumFractionDigits = 0
  formatter.locale = Locale.current
  formatter.groupingSeparator = " "
  return formatter
}

class WidgetAPI {
  
  static func fetchPrice(currency: String, completion: @escaping ((WidgetDataStore?, Error?) -> Void)) {
    guard let url = URL(string: "https://api.coindesk.com/v1/bpi/currentPrice/\(currency).json") else {return}
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard let dataResponse = data,
            let json = ((try? JSONSerialization.jsonObject(with: dataResponse, options: .mutableContainers) as? Dictionary<String, Any>) as Dictionary<String, Any>??),
            error == nil else {
        print(error?.localizedDescription ?? "Response Error")
        completion(nil, error)
        return }
      
      guard let bpi = json?["bpi"] as? Dictionary<String, Any>, let preferredCurrency = bpi[currency] as? Dictionary<String, Any>, let rateString = preferredCurrency["rate"] as? String, let rateDouble = preferredCurrency["rate_float"] as? Double, let time = json?["time"] as? Dictionary<String, Any>, let lastUpdatedString = time["updatedISO"] as? String
 else {
        print(error?.localizedDescription ?? "Response Error")
        completion(nil, error)
        return }
      let latestRateDataStore = WidgetDataStore(rate: rateString, lastUpdate: lastUpdatedString, rateDouble: rateDouble)
      completion(latestRateDataStore, nil)
    }.resume()
  }
  
  static func getUserPreferredCurrency() -> String {
    guard let userDefaults = UserDefaults(suiteName: "group.io.bluewallet.bluewallet"),
          let preferredCurrency = userDefaults.string(forKey: "preferredCurrency")
    else {
      return "USD"
    }
    
    if preferredCurrency != WidgetAPI.getLastSelectedCurrency() {
      UserDefaults.standard.removeObject(forKey: WidgetData.WidgetCachedDataStoreKey)
      UserDefaults.standard.removeObject(forKey: WidgetData.WidgetDataStoreKey)
      UserDefaults.standard.synchronize()
    }
    
    return preferredCurrency
  }
  
  static func getUserPreferredCurrencyLocale() -> String {
    guard let userDefaults = UserDefaults(suiteName: "group.io.bluewallet.bluewallet"),
          let preferredCurrency = userDefaults.string(forKey: "preferredCurrencyLocale")
    else {
      return "en_US"
    }
    return preferredCurrency
  }
  
  static func getLastSelectedCurrency() -> String {
    guard let dataStore = UserDefaults.standard.string(forKey: "currency") else {
      return "USD"
    }
    
    return dataStore
  }
  
  static func saveNewSelectedCurrency() {
    UserDefaults.standard.setValue(WidgetAPI.getUserPreferredCurrency(), forKey: "currency")
  }
  
}
