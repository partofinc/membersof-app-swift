//
//  Debt+Entity.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 9/14/22.
//

import Foundation
import CoreData
import Models

extension Debt: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Debt")
    }
    
    @objc(DebtEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var currency: String
        @NSManaged public var amount: NSDecimalNumber
    }
    
    init(_ entity: Entity) {
        self.init(id: entity.id, currency: entity.currency, amount: entity.amount.decimalValue)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.currency = currency
        entity.amount = .init(decimal: amount)
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Debt.first(in: context, key: "id", value: id.uuidString)
    }
}
