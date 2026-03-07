// View+Extension.swift
// IOSStarter
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import SwiftUI

extension View {

    // MARK: - Conditional Modifiers

    /// Applies the given transform only when the condition is true.
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .if(isHighlighted) { $0.bold().foregroundStyle(.yellow) }
    /// ```
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Loading Overlay

    /// Overlays a `ProgressView` and dims the view when `isLoading` is true.
    func loadingOverlay(_ isLoading: Bool) -> some View {
        overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.4)
                }
            }
        }
        .disabled(isLoading)
    }

    // MARK: - Error Alert

    /// Presents a dismissible error alert driven by an optional `String` binding.
    func errorAlert(message: Binding<String?>) -> some View {
        alert(
            "Error",
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
            ),
            actions: {
                Button("OK", role: .cancel) { message.wrappedValue = nil }
            },
            message: {
                if let msg = message.wrappedValue {
                    Text(msg)
                }
            }
        )
    }

    // MARK: - Rounded Card

    /// Applies a rounded card appearance (background + corner radius + shadow).
    func cardStyle(
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4
    ) -> some View {
        self
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: shadowRadius, x: 0, y: 2)
    }

    // MARK: - Navigation Hiding

    /// Hides the navigation bar back button label, showing only the chevron.
    func hideBackButtonLabel() -> some View {
        navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EmptyView()
                }
            }
    }
}
