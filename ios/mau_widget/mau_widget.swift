//
//  mau_widget.swift
//  mau_widget
//
//  Created by pe on 2025/05/27.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), friendCardPath: "No screenshot available", displaySize: context.displaySize)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let userDefaults: UserDefaults? = UserDefaults(suiteName: "group.mau_widget")
        let friendCardPath: String = userDefaults?.string(forKey: "friendCard") ?? "No screenshot available"
        
        return SimpleEntry(date: Date(), configuration: configuration, friendCardPath: friendCardPath, displaySize: context.displaySize)
    }

    
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
 let userDefaults: UserDefaults? = UserDefaults(suiteName: "group.mau_widget")
        let friendCardPath: String = userDefaults?.string(forKey: "friendCard") ?? "No screenshot available"
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            let entry = SimpleEntry(date: entryDate, configuration: configuration, friendCardPath: friendCardPath, displaySize: context.displaySize)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }aasdasffsdfsdf
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let friendCardPath: String
    let displaySize: CGSize
}

struct mau_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Favorite Emoji:")
            Text(entry.configuration.favoriteEmoji)
            
            FriendCard
            
        }
    }
    var FriendCard: some View {
        if let uiImage = UIImage(contentsOfFile: entry.friendCardPath) {
            let image = Image(uiImage: uiImage)
                .resizable()
                .frame(width: entry.displaySize.height*0.5, height: entry.displaySize.height*0.5,alignment: .center)
            return AnyView(image)
        }
        print("The image file could not be loaded")
        return AnyView(EmptyView())
    }
}

struct mau_widget: Widget {
    let kind: String = "mau_widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            mau_widgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    mau_widget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, friendCardPath: "No screenshot available", displaySize: CGSize(width: 100, height: 100))
    SimpleEntry(date: .now, configuration: .starEyes, friendCardPath: "No screenshot available", displaySize: CGSize(width: 100, height: 100))
}
