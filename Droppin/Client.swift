//
//  Client.swift
//  Droppin
//
//  Created by Adnan Ahmed on 2018-10-18.
//  Copyright © 2018 Syed Ahmed. All rights reserved.
//

import Foundation

struct Client {
    
    let status:Int
    let msg:String
    
    static let basePath = "https://droppin-1b474.firebaseio.com/"

    //Functions for different types of calls: GET, POST, PUT

    static func getCall(_ pathExtension: String, completion: @escaping ([Any]) -> ()) {
        let url = basePath + pathExtension
        let request = URLRequest(url: URL(string: url)!)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            var dataArray:[Any] = []

            if let response = response {
                if let httpResponse = response as? HTTPURLResponse {
//                    print("statusCode: \(httpResponse.statusCode)")
                    dataArray.append(httpResponse.statusCode)
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
//                        print("---------------------------------------------------")
//                        print (json)
//                        print("---------------------------------------------------")
                        
                        dataArray.append(json)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(dataArray)
            }
        }.resume()
    }
    
    static func postCall(_ parameters: [String:String], _ pathExtension: String, completion: @escaping ([Any]) -> ()) {
        let url = basePath + pathExtension
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            var dataArray:[Any] = []
            
            if let response = response {
                if let httpResponse = response as? HTTPURLResponse {
//                    print("statusCode: \(httpResponse.statusCode)")
                    dataArray.append(httpResponse.statusCode)
                }
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        //return data from post
                        //print(json)
                        if let name = json["name"] as? String {
                            dataArray.append(name)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(dataArray)
            }
        }.resume()
    }
    
    static func putCall(_ parameters: [String:String], _ pathExtension: String, completion: @escaping ([Any]) -> ()) {
        let url = basePath + pathExtension
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            //            if let response = response {
            //                print(response)
            //            }
            
            var dataArray:[Any] = []
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        //return data from put
                    }
                } catch {
                    print(error.localizedDescription)
                }
                completion(dataArray)
            }
            }.resume()
    }
    
    //Different API Calls
    
    //post calls
    
    static func addEvent(_ parameters: [String:String], completion: @escaping ([Any]) -> ()) {
        let pathExtension = "events.json"
        postCall(parameters, pathExtension) { (results:[Any]) in completion(results)}
    }
    
    static func getEvents(completion: @escaping ([Any]) -> ()) {
        let pathExtension = "events.json"
        getCall(pathExtension) { (results:[Any]) in completion(results)}
    }
    
}
