//
//  mau_widgetLiveActivity.swift
//  mau_widget
//
//  Created by pe on 2025/05/27.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct mau_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct mau_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: mau_widgetAttributes.self) { context in
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

extension mau_widgetAttributes {
    fileprivate static var preview: mau_widgetAttributes {
        mau_widgetAttributes(name: "World")
    }
}

extension mau_widgetAttributes.ContentState {
    fileprivate static var smiley: mau_widgetAttributes.ContentState {
        mau_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: mau_widgetAttributes.ContentState {
         mau_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: mau_widgetAttributes.preview) {
   mau_widgetLiveActivity()
} contentStates: {
    mau_widgetAttributes.ContentState.smiley
    mau_widgetAttributes.ContentState.starEyes
}
