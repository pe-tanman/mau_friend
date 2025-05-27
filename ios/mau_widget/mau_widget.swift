//
//  mau_widget.swift
//  mau_widget
//
//  Created by pe on 2025/05/27.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), userName: "username", iconLink: "https://hpgpixer.jp/image_icons/animals/animal_icon/cat/cat_12.gif", status: "🔴 Offline")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry: SimpleEntry
        if context.isPreview {
            entry = placeholder(in: context)
        } else {
            let userDefaults = UserDefaults(suiteName: "group.mau_widget")
            let username: String = userDefaults?.string(forKey: "username") ?? "username"
            let iconLink: String = userDefaults?.string(forKey: "iconLink") ?? "https://hpgpixer.jp/image_icons/animals/animal_icon/cat/cat_12.gif"
            let status: String = userDefaults?.string(forKey: "status") ?? "🔴 Offline"
            entry = SimpleEntry(date: Date(), userName: username, iconLink: iconLink, status: status)
        }
        completion(entry)
    }


    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        getSnapshot(in: context) { (entry: SimpleEntry) in
// atEnd policy tells widgetkit to request a new entry after the date has passed
        let timeline: Timeline<SimpleEntry> = Timeline(entries: [entry], policy: .atEnd)
                  completion(timeline)
              }
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }aasdasffsdfsdf
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let userName: String
    let iconLink: String
    let status: String
}
extension View {
    @ViewBuilder
    func widgetBackground(_ style: some ShapeStyle) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) {
                ContainerRelativeShape().foregroundStyle(AnyShapeStyle(style))
            }
        } else {
            self.background(AnyShapeStyle(style))
        }
    }
}

struct mau_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
         VStack() {
            HStack{
 if let url = URL(string: entry.iconLink),
            let imageData = try? Data(contentsOf: url),
            let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
        }
            // User Name
            Text(entry.userName)
                .font(.body)
                .fontWeight(.bold)

            }
           
            // Status
            HStack {
                Text(entry.status)
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 24/255, green: 59/255, blue: 78/255).opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .widgetBackground(Color(red: 243/255, green: 243/255, blue: 224/255))
    }
    
}

struct mau_widget: Widget {
    let kind: String = "mau_widget"

   var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            mau_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mau Widget")
        .description("Displays user status and profile.")
    }
}


struct mau_widget_Previews: PreviewProvider {
    static var previews: some View {
        mau_widgetEntryView(entry: SimpleEntry(date: Date(), userName: "username", iconLink: "https://hpgpixer.jp/image_icons/animals/animal_icon/cat/cat_12.gif", status: "🔴 Offline"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}