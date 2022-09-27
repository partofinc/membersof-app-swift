//
//  EventEditView.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 9/27/22.
//

import SwiftUI

struct EventEditView: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        Form {
            TextField("Name", text: $viewModel.name)
        }
    }
}

struct EventEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventEditView(viewModel: .init(event:
                    .init(id: UUID(), name: "One time", createDate: .now, startDate: .now, estimatedEndDate: nil, endDate: nil, team: Mock.teams.first!, memberships: [])
                                          ))
        }
    }
}
