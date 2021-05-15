//
//  Song.swift
//  Reproductor
//
//  Created by daniel on 13/03/2021.
//

// Clase para manejar las canciones
import Foundation
import AVFoundation
import UIKit

class Song {
    
    var name: String
    var artist: String
    var image: UIImage
    var url: URL
    
    init(name: String, artist: String, image: UIImage, url: URL) {
        self.name = name
        self.artist = artist
        self.image = image
        self.url = url
    }
}
