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
        print("📱 Widget: Loading upcoming content...")

        guard let userDefaults = UserDefaults(suiteName: "group.app.zagreus") else {
            print("❌ Widget: Failed to access app group")
            return sampleData
        }

        print("✅ Widget: App group accessed")

        guard let jsonString = userDefaults.string(forKey: "upcoming_content"),
              let jsonData = jsonString.data(using: .utf8) else {
            print("❌ Widget: No data found in UserDefaults")
            // Print all keys to debug
            print("Available keys: \(userDefaults.dictionaryRepresentation().keys)")
            return sampleData
        }

        print("📦 Widget: Found data, decoding...")
        print("JSON: \(jsonString)")

        do {
            let decoder = JSONDecoder()
            let items = try decoder.decode([UpcomingItem].self, from: jsonData)
            print("✅ Widget: Decoded \(items.count) items")
            return items.isEmpty ? sampleData : items
        } catch {
            print("❌ Widget: Error decoding upcoming content: \(error)")
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
                overview: "",
                episodeTitle: nil
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
    let episodeTitle: String?

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: releaseDate) else {
            return "TBA"
        }

        let calendar = Calendar.current
        let now = Date()

        // Get days until release
        let components = calendar.dateComponents([.day], from: now, to: date)

        if let days = components.day {
            if days == 0 {
                return "Today"
            } else if days == 1 {
                return "Tomorrow"
            } else if days > 1 && days <= 7 {
                return "In \(days) Days"
            } else {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM d"
                return displayFormatter.string(from: date)
            }
        }

        return "TBA"
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
        ZStack {
            Color.black

            if let item = items.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Up Next")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            // Colored dot indicator
                            Circle()
                                .fill(item.mediaType == "movie" ? Color.orange : Color.blue)
                                .frame(width: 10, height: 10)

                            Text(item.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                        }

                        Text(item.formattedDate)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding()
            } else {
                Text("No upcoming content")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// Medium widget: Shows 3 upcoming items
struct MediumWidgetView: View {
    let items: [UpcomingItem]

    var body: some View {
        ZStack {
            Color.black
            UpcomingListLayout(items: items, maxItems: 4, includeFooterSpacer: false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// Large widget: Shows 5 upcoming items
struct LargeWidgetView: View {
    let items: [UpcomingItem]

    var body: some View {
        ZStack {
            Color.black
            UpcomingListLayout(items: items, maxItems: 5, includeFooterSpacer: true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// Shared layout for medium & large widgets
struct UpcomingListLayout: View {
    let items: [UpcomingItem]
    let maxItems: Int
    let includeFooterSpacer: Bool

    var body: some View {
        let limitedItems = Array(items.prefix(maxItems))

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Upcoming This Week")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            .padding(.bottom, 4)

            ForEach(limitedItems) { item in
                HStack(spacing: 10) {
                    // Colored dot indicator
                    Circle()
                        .fill(item.mediaType == "movie" ? Color.orange : Color.blue)
                        .frame(width: 10, height: 10)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if let episodeTitle = item.episodeTitle {
                            // TV Show: Show episode title
                            Text(episodeTitle)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        } else {
                            // Movie: Show date
                            Text(item.formattedDate)
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 3)

                if item.id != limitedItems.last?.id {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.vertical, 2)
                }
            }

            if includeFooterSpacer {
                Spacer(minLength: 0)
            }
        }
        .padding(14)
    }
}

struct UpcomingWidget: Widget {
    let kind: String = "UpcomingWidget"

    var body: some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return StaticConfiguration(kind: kind, provider: Provider()) { entry in
                UpcomingWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        Color.black
                    }
            }
            .contentMarginsDisabled()
            .configurationDisplayName("Upcoming Movies & Shows")
            .description("See what's coming out this week")
            .supportedFamilies([.systemMedium, .systemLarge])
        } else {
            return StaticConfiguration(kind: kind, provider: Provider()) { entry in
                UpcomingWidgetEntryView(entry: entry)
                    .background(Color.black)
            }
            .configurationDisplayName("Upcoming Movies & Shows")
            .description("See what's coming out this week")
            .supportedFamilies([.systemMedium, .systemLarge])
        }
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
            overview: "Paul Atreides unites with Chani and the Fremen while seeking revenge.",
            episodeTitle: nil
        ),
        UpcomingItem(
            id: 2,
            title: "The Last of Us",
            releaseDate: ISO8601DateFormatter().string(from: Date().addingTimeInterval(86400)),
            poster: nil,
            mediaType: "tv",
            rating: 9.2,
            overview: "Joel and Ellie journey through post-apocalyptic America.",
            episodeTitle: "When You're Lost in the Darkness"
        )
    ]
    UpcomingEntry(date: .now, items: sampleItems)
}
