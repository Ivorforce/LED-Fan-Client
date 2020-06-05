//
//  SwiftUI+Ports.swift
//  LLED Client
//
//  Created by Lukas Tenbrink on 02.06.20.
//  Copyright © 2020 Lukas Tenbrink. All rights reserved.
//

import SwiftUI

struct ProgressIndicator: NSViewRepresentable {
    typealias TheNSView = NSProgressIndicator
    var configuration: (TheNSView) -> Void = { _ in }

    func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        TheNSView()
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressIndicator>) {
        configuration(nsView)
    }
}

struct TooltipView: NSViewRepresentable {
    let text: String

    init(_ text: String?, showCursor: Bool = false) {
        self.text = text ?? ""
    }
    
    func withCursor() -> some View {
        return self.onHover { inside in
            if inside {
                NSCursor.crosshair.push()
            } else {
                NSCursor.pop()
            }
        }
    }

    func makeNSView(context: NSViewRepresentableContext<TooltipView>) -> NSView {
        NSView()
    }

    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<TooltipView>) {
        nsView.toolTip = self.text
    }
}
