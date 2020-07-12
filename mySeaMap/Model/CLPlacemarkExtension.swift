//
//  CLPlacemarkExtension.swift
//  myseamap
//
//  Created by Frank Budszuhn on 12.07.20.
//  Copyright © 2020 Frank Budszuhn. All rights reserved.
//

extension CLPlacemark {
    
    func formattedPlacemark() -> String {
        
        var parts: [String] = [];
        if let aLocality = self.locality {
            parts += [aLocality]
        }
        if let anAdminArea = self.administrativeArea {
            if !parts.contains(anAdminArea) { // wir wollen kein Hamburg, Hamburg
                parts += [anAdminArea]
            }
        }
        if let aCountry = self.country {
            parts += [aCountry]
        }
        
        return parts.joined(separator: ", ")
    }
}
