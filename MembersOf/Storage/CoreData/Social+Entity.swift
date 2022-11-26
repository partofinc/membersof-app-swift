

import Foundation
import CoreData
import Models

extension Social: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Social")
    }
    
    @objc(SocialEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var media: String
        @NSManaged public var account: String
        @NSManaged public var order: Int32
        @NSManaged public var team: Team.Entity?
        @NSManaged public var member: Member.Entity?
    }
    
    init(_ entity: Entity) {
        self.init(id: entity.id, media: .init(rawValue: entity.media)!, account: entity.account, order: Int(entity.order), memberId: entity.member?.id, teamId: entity.team?.id)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.media = media.rawValue
        entity.account = account
        entity.order = Int32(order)
        if let id = teamId {
            entity.team = Team.first(in: context, key: "id", value: id.uuidString)
        }
        if let id = memberId {
            entity.member = Member.first(in: context, key: "id", value: id.uuidString)
        }
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Social.first(in: context, key: "id", value: id.uuidString)
    }
}
