//
//  SocialMediaRow.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/26/22.
//

import SwiftUI
import Models

struct SocialMediaRow: View {
    
    let social: Social
    let style: Style
    let onDelete: () -> Void
    
    init(_ social: Social, style: Style = .plain, onDelete: @escaping () -> Void = {}) {
        self.social = social
        self.style = style
        self.onDelete = onDelete
    }
    
    var body: some View {
        switch style {
        case .fancy:
            HStack {
                HStack {
                    Text(social.media.rawValue.capitalized)
                    Spacer()
                    Text(social.account)
                        .font(.headline)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.4).gradient)
                        .shadow(radius: 3)
                )
            }
        default:
            HStack {
                Text(social.media.rawValue)
                Spacer()
                Text(social.account)
                    .font(.headline)
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
            }
        }
    }
}

struct NewSocialMediaRow: View {
    
    let media: Social.Media
    let style: SocialMediaRow.Style
    @Binding var account: String
    let onSubmit: () -> Void
    
    init(media: Social.Media, style: SocialMediaRow.Style = .plain, account: Binding<String>, onSubmit: @escaping () -> Void = {}) {
        self.media = media
        self.style = style
        self._account = account
        self.onSubmit = onSubmit
    }
    
    @FocusState private var focus
    
    var body: some View {
        HStack {
            Text(media.rawValue)
            Spacer()
            TextField("Account", text: $account)
                .multilineTextAlignment(.trailing)
                .keyboardType(.emailAddress)
                .textContentType(.nickname)
                .autocorrectionDisabled()
                .autocapitalization(.none)
            #if os(iOS)
                .focused($focus)
            #endif
            Button {
                onSubmit()
            } label: {
                Image(systemName: "checkmark.circle")
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            .disabled(account.count < 3)
        }
        .onAppear {
            focus = true
        }
    }
}

extension SocialMediaRow {
    enum Style {
        case plain
        case fancy
    }
}

struct SocialMediaRow_Previews: PreviewProvider {
    static let media = Social(id: UUID(), media: .instagram, account: "rawillk", order: 0, memberId: nil, teamId: nil)
    static var previews: some View {
        VStack {
            List {
                SocialMediaRow(media)
                NewSocialMediaRow(media: .facebook, account: .constant("red"))
            }
            SocialMediaRow(media, style: .fancy)
        }
    }
}
