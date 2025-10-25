//
//  UpcomingWidget.swift
//  UpcomingWidget
//
//  Created by Umikaze on 10/24/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> UpcomingEntry {
        UpcomingEntry(date: Date(), items: sampleData)
    }

    func getSnapshot(in context: Context, completion: @escaping (UpcomingEntry) -> ()) {
        let entry = UpcomingEntry(date: Date(), items: loadUpcomingContent())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let items = loadUpcomingContent()
        let entry = UpcomingEntry(date: currentDate, items: items)

        // Update every 4 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    // Load upcoming content from shared UserDefaults
    func loadUpcomingContent() -> [UpcomingItem] {
        guard let userDefaults = UserDefaults(suiteName: "group.app.zagreus") else {
            return sampleData
        }

        guard let jsonString = userDefaults.string(forKey: "upcoming_content"),
              let jsonData = jsonString.data(using: .utf8) else {
            return sampleData
        }

        do {
            let decoder = JSONDecoder()
            let items = try decoder.decode([UpcomingItem].self, from: jsonData)
            return items.isEmpty ? sampleData : items
        } catch {
            print("Error decoding upcoming content: \(error)")
            return sampleData
        }
    }

    var sampleData: [UpcomingItem] {
        return [
            UpcomingItem(
                id: 1,
                title: "Loading...",
                releaseDate: ISO8601DateFormatter().string(from: Date()),
                poster: nil,
                mediaType: "movie",
                rating: 0.0,
                overview: ""
            )
        ]
    }
}

struct UpcomingEntry: TimelineEntry {
    let date: Date
    let items: [UpcomingItem]
}

struct UpcomingItem: Codable, Identifiable {
    let id: Int
    let title: String
    let releaseDate: String
    let poster: String?
    let mediaType: String
    let rating: Double
    let overview: String

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: releaseDate) else {
            return "TBA"
        }

        let displayFormatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            displayFormatter.dateFormat = "MMM d"
            return displayFormatter.string(from: date)
        }
    }

    var mediaIcon: String {
        mediaType == "movie" ? "🎬" : "📺"
    }
}

struct UpcomingWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(items: entry.items)
        case .systemMedium:
            MediumWidgetView(items: entry.items)
        case .systemLarge:
            LargeWidgetView(items: entry.items)
        default:
            SmallWidgetView(items: entry.items)
        }
    }
}

// Small widget: Shows next upcoming item
struct SmallWidgetView: View {
    let items: [UpcomingItem]

    var body: some View {
        if let item = items.first {
            ZStack {
                Color(red: 0.14, green: 0.14, blue: 0.17)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Up Next")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                        Spacer()
                        Text(item.mediaIcon)
                            .font(.caption)
                    }

                    Spacer()

                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text(item.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", item.rating))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
        } else {
            Text("No upcoming content")
                .foregroundColor(.gray)
        }
    }
}

// Medium widget: Shows 3 upcoming items
struct MediumWidgetView: View {
    let items: [UpcomingItem]

    var body: some View {
        ZStack {
            Color(red: 0.14, green: 0.14, blue: 0.17)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Upcoming This Week")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                    Spacer()
                    Text(getCurrentDate())
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                ForEach(items.prefix(3)) { item in
                    HStack(spacing: 10) {
                        Text(item.mediaIcon)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            HStack(spacing: 8) {
                                Text(item.formattedDate)
                                    .font(.caption2)
                                    .foregroundColor(.gray)

                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", item.rating))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)

                    if item.id != items.prefix(3).last?.id {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }
                }

                Spacer()
            }
            .padding()
        }
    }

    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: Date())
    }
}

// Large widget: Shows 5 upcoming items with more detail
struct LargeWidgetView: View {
    let items: [UpcomingItem]

    var body: some View {
        ZStack {
            Color(red: 0.14, green: 0.14, blue: 0.17)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Upcoming This Week")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.purple)
                }

                ForEach(items.prefix(5)) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            Text(item.mediaIcon)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                HStack(spacing: 10) {
                                    Text(item.formattedDate)
                                        .font(.caption)
                                        .foregroundColor(.purple)

                                    HStack(spacing: 3) {
                                        Image(systemName: "star.fill")
                                            .font(.caption2)
                                            .foregroundColor(.yellow)
                                        Text(String(format: "%.1f", item.rating))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            Spacer()
                        }

                        Text(item.overview)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .padding(.leading, 40)
                    }
                    .padding(.vertical, 4)

                    if item.id != items.prefix(5).last?.id {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct UpcomingWidget: Widget {
    let kind: String = "UpcomingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                UpcomingWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                UpcomingWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Upcoming Movies & Shows")
        .description("See what's coming out this week")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    UpcomingWidget()
} timeline: {
    let sampleItems = [
        UpcomingItem(
            id: 1,
            title: "Dune: Part Three",
            releaseDate: ISO8601DateFormatter().string(from: Date()),
            poster: nil,
            mediaType: "movie",
            rating: 8.5,
            overview: "Paul Atreides unites with Chani and the Fremen while seeking revenge."
        ),
        UpcomingItem(
            id: 2,
            title: "The Last of Us",
            releaseDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)),
            poster: nil,
            mediaType: "tv",
            rating: 9.2,
            overview: "Joel and Ellie journey through post-apocalyptic America."
        )
    ]
    UpcomingEntry(date: .now, items: sampleItems)
}
