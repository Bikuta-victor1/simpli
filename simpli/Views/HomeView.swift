//
//  HomeView.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.appTheme) private var theme

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Explain This Simply")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.textPrimary)
                    Text("Paste your text and choose how to explain it")
                        .font(.subheadline)
                        .foregroundColor(theme.textSecondary)
                }
                .padding(.top, 32)
                
                // Text Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Text")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)

                    TextEditor(text: $viewModel.inputText)
                        .frame(height: 200)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(theme.surface)
                        .foregroundColor(theme.textPrimary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.isOverLimit ? theme.error : Color.clear, lineWidth: 2)
                        )

                    HStack {
                        Text("\(viewModel.characterCount) / \(viewModel.maxCharacterLimitValue)")
                            .font(.caption)
                            .foregroundColor(viewModel.isOverLimit ? theme.error : theme.textSecondary)
                        Spacer()
                        if viewModel.isOverLimit {
                            Text("Too long")
                                .font(.caption)
                                .foregroundColor(theme.error)
                        }
                    }

                    if let validationMessage = viewModel.validationMessage {
                        Text(validationMessage)
                            .font(.caption)
                            .foregroundColor(theme.error)
                    }
                }
                
                // Mode Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Explanation Mode")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(ExplanationMode.allCases) { mode in
                            ModeButton(
                                mode: mode,
                                isSelected: viewModel.selectedMode == mode
                            ) {
                                viewModel.selectedMode = mode
                            }
                        }
                    }
                }
                
                // Safety Context (multiselect)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Content type (optional)")
                        .font(.headline)
                        .foregroundColor(theme.textPrimary)
                    Text("Select if your text is legal, medical, or financial. Adds a disclaimer.")
                        .font(.caption)
                        .foregroundColor(theme.textSecondary)
                    HStack(spacing: 12) {
                        ForEach(SafetyContext.allCases) { context in
                            SafetyContextChip(
                                context: context,
                                isSelected: viewModel.selectedSafetyContexts.contains(context)
                            ) {
                                viewModel.toggleSafetyContext(context)
                            }
                        }
                    }
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(theme.error)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(theme.error.opacity(0.15))
                        .cornerRadius(8)
                }
                
                // Explain Button
                Button {
                    Task {
                        await viewModel.explain()
                    }
                } label: {
                    HStack {
                        if viewModel.isExplaining {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Explain")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canExplain ? theme.primary : theme.inactive)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.canExplain)
                
                Spacer()
            }
            .padding()
            .background(theme.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $viewModel.showResult) {
                if let result = viewModel.result {
                    ResultView(response: result)
                }
            }
        }
    }
}

struct SafetyContextChip: View {
    let context: SafetyContext
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.appTheme) private var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: context.icon)
                    .font(.caption)
                Text(context.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? theme.primary.opacity(0.25) : theme.surface)
            .foregroundColor(isSelected ? theme.primary : theme.textPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ModeButton: View {
    let mode: ExplanationMode
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.appTheme) private var theme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                Text(mode.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? theme.primary.opacity(0.25) : theme.surface)
            .foregroundColor(isSelected ? theme.primary : theme.textPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    HomeView()
}
