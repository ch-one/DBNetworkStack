//
//  NetworkResourceRepresening.swift
//  DBNetworkStack
//
//	Legal Notice! DB Systel GmbH proprietary License!
//
//	Copyright (C) 2015 DB Systel GmbH
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	This code is protected by copyright law and is the exclusive property of
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	Consent to use ("licence") shall be granted solely on the basis of a
//	written licence agreement signed by the customer and DB Systel GmbH. Any
//	other use, in particular copying, redistribution, publication or
//	modification of this code without written permission of DB Systel GmbH is
//	expressly prohibited.

//	In the event of any permitted copying, redistribution or publication of
//	this code, no changes in or deletion of author attribution, trademark
//	legend or copyright notice shall be made.
//
//  Created by Lukas Schmidt on 21.07.16.
//

import Foundation

/**
 `NetworkRequestRepresening` represents a networkreuqest with all components needed to retrieve correct ressources.
 */
public protocol NetworkRequestRepresening {
    /**
     Path to the remote ressource.
     */
    var path: String { get }
    
    /**
     The key which represents the matching baseURL to this request.
     */
    var baseURLKey: BaseURLKey { get }
    
    /**
     The HTTP Method.
     */
    var HTTPMethod: DBNetworkStack.HTTPMethod { get }
    
    /**
     Headers for the request.
     */
    var allHTTPHeaderFields: [String: String]? { get }
    
    /**
     Parameters which will be send with the request.
     */
    var parameter: [String : AnyObject]? { get }
    
    /**
     Data payload of the request
     */
    var body: NSData? { get }
}

extension NetworkRequestRepresening {
    /**
     Transforms self into a equivalent `NSURLRequest` with a given baseURL.
     
     - parameter baseURL: baseURL for the resulting request.
     - returns: the equivalent request
     */
    public func urlRequest(with baseURL: NSURL) -> NSURLRequest {
        let absoluteURL = absoluteURLWith(baseURL)
        let request = NSMutableURLRequest(URL: absoluteURL)
        request.allHTTPHeaderFields = allHTTPHeaderFields
        request.HTTPMethod = HTTPMethod.rawValue
        request.HTTPBody = body
        
        return request
    }
    
    /**
     Creates an absulte URL of for the request by concating baseURL and path and apending request parameter
     
     - parameter baseURL: baseURL for the resulting url.
     - returns: absolute url for the request.
     */
    private func absoluteURLWith(baseURL: NSURL) -> NSURL {
        guard let absoluteURL = NSURL(string: path, relativeToURL: baseURL) else {
            fatalError("Error createing absolute URL from path: \(path), with baseURL: \(baseURL)")
        }
         let urlComponents = NSURLComponents(URL: absoluteURL, resolvingAgainstBaseURL: true)
        if let parameter = parameter, let urlComponents = urlComponents where !parameter.isEmpty {
            let percentEncodedQuery = parameter.map({ value in
                return "\(value.0)=\(value.1)".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            }).flatMap { $0 }
            urlComponents.percentEncodedQuery = percentEncodedQuery.joinWithSeparator("&")
            
            guard let absoluteURL = urlComponents.URL else {
                 fatalError("Error createing absolute URL from path: \(path), with baseURL: \(baseURL)")
            }
            return absoluteURL
        }
        
        return absoluteURL
    }
}
