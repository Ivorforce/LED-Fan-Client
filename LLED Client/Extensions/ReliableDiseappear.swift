//
//  ReliableDiseappear.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 21.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct WillDisappearHandler: NSViewControllerRepresentable {
    let callback: (Bool) -> Void

    func makeNSViewController(context: Context) -> NSViewController {
        TheViewController(callback: callback)
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        
    }

    class TheViewController: NSViewController {
        let callback: (Bool) -> Void

        init(callback: @escaping (Bool) -> Void) {
            self.callback = callback
            super.init(nibName: nil, bundle: nil)
            self.view = NSView()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillAppear() {
            super.viewWillAppear()
            callback(true)
        }

        override func viewWillDisappear() {
            super.viewWillDisappear()
            callback(false)
        }
    }
}

extension View {
    func whileActive(_ perform: @escaping (Bool) -> Void) -> some View {
        self
            .background(WillDisappearHandler(callback: perform))
    }
}
