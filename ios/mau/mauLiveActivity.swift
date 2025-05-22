//
//  mauLiveActivity.swift
//  mau
//
//  Created by pe on 2025/05/22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct mauAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct mauLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: mauAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension mauAttributes {
    fileprivate static var preview: mauAttributes {
        mauAttributes(name: "World")
    }
}

extension mauAttributes.ContentState {
    fileprivate static var smiley: mauAttributes.ContentState {
        mauAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: mauAttributes.ContentState {
         mauAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: mauAttributes.preview) {
   mauLiveActivity()
} contentStates: {
    mauAttributes.ContentState.smiley
    mauAttributes.ContentState.starEyes
}
