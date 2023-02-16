//
//  Schedule+Entity.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 2023-01-30.
//

import Foundation
import CoreData
import Models

extension Schedule: Storable {

    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Schedule")
    }
    
    @objc(ScheduleEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged var id: UUID
        @NSManaged var name: String
        @NSManaged var team: Team.Entity
        @NSManaged var repeats: Data?
        @NSManaged var nearestDate: Date?
    }
    
    init(_ entity: Entity) {
        var repeats: [Repeat] = []
        if let r = entity.repeats,
           let reps = JSONHelper.shared.decode([Repeat].self, from: r) {
            repeats = reps
        }
        self.init(id: entity.id, name: entity.name, team: .init(entity.team), repeats: repeats, nearestDate: entity.nearestDate)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.name = name
        entity.team =  team.entity(context)
        entity.repeats = JSONHelper.shared.encode(value: repeats)
        entity.nearestDate = nearestDate
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Schedule.first(in: context, key: "id", value: id.uuidString)
    }
}
