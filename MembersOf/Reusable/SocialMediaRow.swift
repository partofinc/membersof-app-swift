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
            GroupBox {
                HStack {
                    Text(social.media.rawValue.capitalized)
                    Spacer()
                    Text(social.account)
                        .font(.headline)
                }
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
    @Binding var account: String
    
    @FocusState private var focus
    
    var body: some View {
        HStack {
            Text(media.rawValue)
            Spacer()
            TextField("Account", text: $account)
                .multilineTextAlignment(.trailing)
                .textContentType(.username)
                .autocorrectionDisabled()
            #if os(iOS)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .focused($focus)
            #endif
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
    static let media = Social(id: UUID(), media: .instagram, account: "rawillk", createDate: .now, memberId: nil, teamId: nil)
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
