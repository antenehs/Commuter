//
//  Polyline+ReittiPolyline.swift
//  Reitti
//
//  Created by Anteneh Sahledengel on 6/17/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

import UIKit

extension Polyline {
    
    //Coordinate arrays are tricky in ObjC
    
    @objc class func reittiPolyline(fromLocationArray locs: [CLLocation]?) -> ReittiPolyline? {
        guard locs != nil && locs!.count > 1 else { return nil }
        
        let coordinates = self.toCoordinates(locs!)
        
        let reittiPolyline = ReittiPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        return reittiPolyline
    }
    
    private class func toCoordinates(_ locations: [CLLocation]) -> [CLLocationCoordinate2D] {
        return locations.map {location in location.coordinate}
    }

}
