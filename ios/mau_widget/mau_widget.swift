import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FlutterEntry {
        FlutterEntry(date: Date(), widgetData: WidgetData(name: "username", iconLink: "'https://hpgpixer.jp/image_icons/animals/animal_icon/cat/cat_12.gif'", status: "🔴 Offline"))
    }

    func getSnapshot(in context: Context, completion: @escaping (FlutterEntry) -> ()) {
        let entry : FlutterEntry
        if context.isPreview {
            entry = placeholder(in: context)
        } else {
            entry = FlutterEntry(date: Date(), widgetData: WidgetData(name: "username", iconLink: "'https://hpgpixer.jp/image_icons/animals/animal_icon/cat/cat_12.gif'", status: "🔴 Offline"))
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FlutterEntry>) -> ()) {
        let sharedDefaults: UserDefaults? = UserDefaults(suiteName: "group.mau_widget")
        let flutterData: WidgetData? = try? JSONDecoder().decode(WidgetData.self, from: (sharedDefaults?
            .string(forKey: "mau_widget")?.data(using: .utf8)) ?? Data())
        let entryDate: Date = Date()
        let entry: FlutterEntry = FlutterEntry(date: entryDate, widgetData: flutterData)
        let timeline: Timeline<FlutterEntry> = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct WidgetData: Decodable, Hashable {
    let name: String
    let iconLink: String
    let status: String
}

struct FlutterEntry: TimelineEntry {
    let date: Date
    let widgetData: WidgetData?
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

struct mau_widgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {

             VStack() {
            HStack{
 if let url = URL(string: entry.widgetData?.iconLink ??  "https://hpgpixer.jp/image_icons/animals/animal_icon/cat/cat_12.gif"),
            let imageData = try? Data(contentsOf: url),
            let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
        }
            // User Name
            Text(entry.widgetData?.name ?? "Username")
                .font(.body)
                .fontWeight(.bold)

            }
           
            // Status
            HStack {
                Text(entry.widgetData?.status ?? "🔴 Offline")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 24/255, green: 59/255, blue: 78/255).opacity(0.2))
                    .cornerRadius(12)
            }
        }
    }
}

struct mau_widget: Widget {
    let kind: String = "mau_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            mau_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mau Widget")
        .description("Display the first status in the list")
    }
}

struct mau_widget_Previews: PreviewProvider {
    static var previews: some View {
        mau_widgetEntryView(entry: FlutterEntry(date: Date(), widgetData: WidgetData(name: "username", iconLink: "https://hpgpixer.jp/image_icons/animals/animal_icon/cat/cat_12.gif", status: "🔴 Offline")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}