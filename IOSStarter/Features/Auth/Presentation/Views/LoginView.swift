// LoginView.swift
// IOSStarter — Auth Presentation View
//
// Copyright (c) 2024 Leandro Perez <contacto@sonholab.com>

import SwiftUI

struct LoginView: View {

    @State private var viewModel: LoginViewModel
    @FocusState private var focusedField: LoginField?

    private enum LoginField: Hashable {
        case email, password
    }

    let onLoginSuccess: (User) -> Void

    // MARK: - Init

    init(
        viewModel: LoginViewModel,
        onLoginSuccess: @escaping (User) -> Void
    ) {
        self._viewModel   = State(wrappedValue: viewModel)
        self.onLoginSuccess = onLoginSuccess
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    formSection
                    loginButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .loadingOverlay(viewModel.isLoading)
            .onChange(of: viewModel.viewState) { _, newState in
                if case .success(let user) = newState {
                    onLoginSuccess(user)
                }
            }
            .alert(
                "Login Failed",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.dismissError() } }
                )
            ) {
                Button("OK", role: .cancel) { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "swift")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
                .padding(.bottom, 8)

            Text("IOSStarter")
                .font(.largeTitle.bold())

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            // Email
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField("you@example.com", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                SecureField("••••••••", text: $viewModel.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { submitLogin() }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var loginButton: some View {
        Button(action: submitLogin) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Sign In")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.white)
            .background(
                viewModel.isLoginEnabled
                    ? Color.accentColor
                    : Color.accentColor.opacity(0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!viewModel.isLoginEnabled)
    }

    // MARK: - Actions

    private func submitLogin() {
        focusedField = nil
        Task { await viewModel.login() }
    }
}
