//
//  CaptureImageView.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 28.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct CaptureImageView: View {
    @ObservedObject var capturer: ImageScreen
    
    init(capturer: ImageScreen) {
        self.capturer = capturer        
    }
        
    var body: some View {
        HStack {
            Picker(selection: $capturer.demoImage, label:
                Text("Image").frame(width: 150, alignment: .leading)
            ) {
                ForEach(ImageScreen.demoImages.map(\.0) + [""], id: \.self) { imageKey in
                    Text(imageKey.isEmpty ? "Custom" : imageKey)
                        .tag(imageKey.isEmpty ? nil : Optional.some(imageKey))
                }
            }
            
            Button(action: {
                let dialog = NSOpenPanel();

                dialog.title                   = "Choose a file| Our Code World";
                dialog.showsResizeIndicator    = true;
                dialog.showsHiddenFiles        = false;
                dialog.allowsMultipleSelection = false;
                dialog.canChooseDirectories = false;

                guard dialog.runModal() ==  .OK, let url = dialog.url else {
                    return // Cancelled
                }
                    
                self.capturer.demoImage = nil
                self.capturer.image = NSImage(contentsOf: url)
            }) {
                Text("Custom")
            }
        }
    }
}
