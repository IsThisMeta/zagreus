//
//  UpcomingWidgetBundle.swift
//  UpcomingWidget
//
//  Created by Umikaze on 10/24/25.
//

import WidgetKit
import SwiftUI

@main
struct UpcomingWidgetBundle: WidgetBundle {
    var body: some Widget {
        UpcomingWidget()
        UpcomingWidgetControl()
        UpcomingWidgetLiveActivity()
    }
}
