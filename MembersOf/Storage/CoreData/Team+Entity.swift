

import Foundation
import CoreData

extension Team: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Team")
    }
    
    @objc(TeamEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var name: String
        @NSManaged public var brief: String
        @NSManaged public var createDate: Date
        @NSManaged public var social: Set<Social.Entity>?
        @NSManaged public var crew: Set<Supervisor.Entity>?
    }
    
    init(_ entity: Entity) {
        id = entity.id
        name = entity.name
        brief = entity.brief
        createDate = entity.createDate
        social = entity.social == nil ? [] : entity.social!.map(Social.init)
        crew = entity.crew == nil ? [] : entity.crew!.map(Supervisor.init)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.name = name
        entity.brief = brief
        entity.createDate = createDate
        entity.social = Set(social.map{$0.entity(context)})
        entity.crew = Set(crew.map{$0.entity(context)})
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Team.first(in: context, key: "id", value: id.uuidString)
    }
}

extension Team.Entity {
    func accessable(by member: Member) -> Bool {
        guard let crew else { return false }
        return crew.contains(where: {$0.member.id == member.id})
    }
}
