//
//  HealthGoalsWidgetControl.swift
//  HealthGoalsWidget
//
//  Created by Jaba Kochashvili on 8/4/24.
//

import AppIntents
import SwiftUI
import WidgetKit

struct HealthGoalsWidgetControl: ControlWidget {
    static let kind: String = "kochashvili.Health-Goals.HealthGoalsWidget"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value,
                action: StartTimerIntent(),
                valueLabel: { isRunning in
                    Label(isRunning ? "On" : "Off", systemImage: "timer")
                }
            )
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

extension HealthGoalsWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

struct StartTimerIntent: SetValueIntent {
    static var title: LocalizedStringResource { "Start a timer" }

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}
