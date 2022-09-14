//
//  ClubDetailView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 8/3/22.
//

import SwiftUI

struct TeamDetailView: View {
    
    @StateObject var viewModel: ViewModel
    @State var subscribed = false
    @State private var sheet: Sheet?
    @State private var removingSocial = false
    @State private var socialToRemove: Social?
    @FocusState private var addingSocial: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(viewModel.brief)
                    .font(.title3)
                Button {
                    sheet = .brief
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .padding()
                        .font(.headline)
                }
                socialMedia
                subscription
                Group {
                    crew
                }
                .disabled(!subscribed)
                .opacity(subscribed ? 1 : 0.5)
                footer
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(viewModel.name)
        .toolbar {
            ToolbarItem {
                Button {
                    sheet = .name
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .name:
                TextEditDialogView(title: "Name", text: viewModel.name) {
                    viewModel.update(name: $0)
                }
                .presentationDetents([.medium])
            case .brief:
                TextEditDialogView(title: "Description", text: viewModel.brief) {
                    viewModel.update(brief: $0)
                }
                .presentationDetents([.medium])
            case .supervisor(let supervisor):
                SupervisorView(viewModel: .init(supervisor), save: {viewModel.update($0)}, delete: {viewModel.delete($0)})
                    .presentationDetents([.medium])
            case .newSupervisor:
                NewSupervisorView(viewModel: .init(viewModel.team))
                    .presentationDetents([.medium])
            }
        }
        .animation(.easeInOut, value: viewModel.socials)
    }
    
    @ViewBuilder
    private var socialMedia: some View {
        Text("Social media")
            .font(.title2)
            .padding(.top)
        ForEach(viewModel.socials) { social in
            SocialMediaRow(social, style: .fancy, edit: .constant(true)) {
                socialToRemove = social
                removingSocial = true
            }
            .padding(.bottom, 5)
        }
        .confirmationDialog(
            socialToRemove == nil ? "" : socialToRemove!.title,
            isPresented: $removingSocial,
            titleVisibility: .visible,
            presenting: socialToRemove,
            actions: { social in
                Button("Delete", role: .destructive) {
                    viewModel.delete(social)
                }
                Button("Cancel", role: .cancel) {}
        })
        if let media = viewModel.media {
            HStack {
                HStack {
                    Text(media.rawValue.capitalized)
                    Spacer()
                    TextField("Account", text: $viewModel.account)
                        .multilineTextAlignment(.trailing)
                        .focused($addingSocial)
                        .keyboardType(.emailAddress)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            viewModel.addSocial()
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.4).gradient)
                        .shadow(radius: 3)
                )
                Button {
                    viewModel.addSocial()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.headline)
                }
            }
            .padding(.bottom, 5)
        }
        if !viewModel.socialMedias.isEmpty {
            Menu {
                ForEach(viewModel.socialMedias) { media in
                    Button(media.rawValue.capitalized) {
                        viewModel.media = media
                        addingSocial = true
                    }
                }
            } label: {
                Label("Add", systemImage: "plus")
                    .font(.headline)
                    .padding()
            }
        }
    }
    
    @ViewBuilder
    private var subscription: some View {
        Text("Subscription")
            .font(.title2)
            .padding(.top)
        HStack {
            Text("Tier")
            Spacer()
            Text(subscribed ? "$5/Month" : "Free")
                .font(.headline)
        }
        .padding(.top, 5)
        if subscribed {
            HStack {
                Text("Next payment")
                Spacer()
                Text("December 22")
                    .font(.headline)
            }
            .padding(.top, 5)
            HStack {
                Text("Managed by")
                Spacer()
                Text("Yanis Y.")
                    .font(.headline)
            }
            .padding(.top, 5)
            Button(role: .destructive) {
                subscribed.toggle()
            } label: {
                Label("Cancel", systemImage: "xmark")
                    .padding()
            }
        } else {
            Button {
                subscribed.toggle()
            } label: {
                Label("Upgrade", systemImage: "lock.open")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red.opacity(0.5).gradient)
                            .shadow(radius: 3)
                    )
            }
            .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private var paymentSection: some View {
        Text("Payment")
            .font(.title2)
            .padding(.top)
        Button {
            
        } label: {
            Label("Connect Stripe", systemImage: "link")
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red.opacity(0.5).gradient)
                        .shadow(radius: 3)
                )
        }
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    private var crew: some View {
        Text("Crew")
            .font(.title2)
            .padding(.top)
        ForEach(viewModel.crew) { supervisor in
            Button {
                sheet = .supervisor(supervisor)
            } label: {
                HStack {
                    Text(supervisor.member.fullName)
                        .font(.headline)
                    Spacer()
                    Text(supervisor.role.rawValue.capitalized)
                        .font(.body)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.7).gradient)
                        .shadow(radius: 3)
                )
            }
            .buttonStyle(.plain)
        }
        ForEach(viewModel.invites) { invite in
            Button {
                
            } label: {
                HStack {
                    Text(invite.title)
                        .font(.headline)
                    Spacer()
                    Text(invite.role!.rawValue.capitalized)
                        .font(.body)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.4).gradient)
                        .shadow(radius: 3)
                )
            }
            .buttonStyle(.plain)
        }
        Button {
            sheet = .newSupervisor
        } label: {
            Label("Add", systemImage: "plus")
                .font(.headline)
                .padding()
        }
    }
    
    @ViewBuilder
    private var notesSection: some View {
        Text("Notes")
            .font(.title2)
            .padding(.top)
        Button {
            
        } label: {
            Label("Add", systemImage: "plus")
                .font(.headline)
                .padding()
        }
    }
    
    @ViewBuilder
    private var footer: some View {
        Button {
            viewModel.deleteTeam()
            dismiss()
        } label: {
            HStack {
                Spacer()
                Text("Delete team")
                Spacer()
            }
        }
        .padding()
        .foregroundColor(.red)
    }
}

struct ClubDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TeamDetailView(viewModel: .init(team: Mock.teams.first!))
        }
    }
}
