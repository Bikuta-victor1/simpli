//
//  ResultView.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import SwiftUI

struct ResultView: View {
    @StateObject private var viewModel: ResultViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme

    init(response: ExplainResponse) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(response: response))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Tab", selection: $viewModel.selectedTab) {
                    ForEach(ResultTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .tint(theme.primary)
                .padding()
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        switch viewModel.selectedTab {
                        case .summary:
                            SummaryTabView(summary: viewModel.response.summary)
                        case .bullets:
                            BulletsTabView(bullets: viewModel.response.bullets)
                        case .actions:
                            ActionsTabView(actions: viewModel.response.actionItems)
                        case .questions:
                            QuestionsTabView(questions: viewModel.response.questions)
                        }
                    }
                    .padding()
                }
                
                // Warnings
                if let warnings = viewModel.response.warnings, !warnings.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(warnings, id: \.self) { warning in
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(theme.primary)
                                Text(warning)
                                    .font(.caption)
                                    .foregroundColor(theme.textPrimary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(theme.primary.opacity(0.15))
                }
            }
            .background(theme.background)
            .navigationTitle("Explanation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.copyToClipboard()
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        Button {
                            viewModel.share()
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// Tab Content Views
struct SummaryTabView: View {
    let summary: String
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
                .foregroundColor(theme.textPrimary)
            Text(summary)
                .font(.body)
                .foregroundColor(theme.textPrimary)
        }
    }
}

struct BulletsTabView: View {
    let bullets: [String]
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Points")
                .font(.headline)
                .foregroundColor(theme.textPrimary)
            ForEach(bullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .fontWeight(.bold)
                        .foregroundColor(theme.primary)
                    Text(bullet)
                        .font(.body)
                        .foregroundColor(theme.textPrimary)
                }
            }
        }
    }
}

struct ActionsTabView: View {
    let actions: [String]
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Action Items")
                .font(.headline)
                .foregroundColor(theme.textPrimary)
            ForEach(actions, id: \.self) { action in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.success)
                    Text(action)
                        .font(.body)
                        .foregroundColor(theme.textPrimary)
                }
            }
        }
    }
}

struct QuestionsTabView: View {
    let questions: [String]
    @Environment(\.appTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Questions to Ask")
                .font(.headline)
                .foregroundColor(theme.textPrimary)
            ForEach(questions, id: \.self) { question in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(theme.primary)
                    Text(question)
                        .font(.body)
                        .foregroundColor(theme.textPrimary)
                }
            }
        }
    }
}

#Preview {
    ResultView(response: ExplainResponse(
        summary: "This is a test summary",
        bullets: ["Point 1", "Point 2", "Point 3"],
        actionItems: ["Action 1", "Action 2"],
        questions: ["Question 1", "Question 2"],
        warnings: nil
    ))
}
