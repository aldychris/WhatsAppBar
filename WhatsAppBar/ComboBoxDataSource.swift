//
//  ComboBoxDataSource.swift
//  WhatsAppBar
//
//  Created by Aldy on 20/05/2018.
//  Copyright © 2018 Aldy. All rights reserved.
//

import Cocoa

class ComboBoxDataSource: NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource {
    
    var states = [Countries]()
    
    struct ResponseData: Decodable {
        var countries: [Countries]
    }
    
    override init() {
        super.init()
        states = loadJson(filename: "Countries")!
    }
    
    func loadJson(filename fileName: String) -> [Countries]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(ResponseData.self, from: data)
                return jsonData.countries
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        
        print("SubString = \(string)")
        
        for state in states {
            if string.count < state.name.count{
                let statePartialStr = state.name.lowercased()[state.name.lowercased().startIndex..<state.name.lowercased().index(state.name.lowercased().startIndex,offsetBy:string.count)]
                
                if statePartialStr.range(of: string.lowercased()) != nil {
                    return state.name
                }
            }
        }
        return ""
    }

    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return(states.count)
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return(states[index].name as AnyObject)
    }
    
    func comboBox(_ comboBox: NSComboBox, objectForItemAt index: Int) -> Any? {
        return(states[index] as AnyObject)
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var i = 0
        for str in states {
            if str.name == string{
                return i
            }
            i += 1
        }
        return -1
    }
    
    
}
