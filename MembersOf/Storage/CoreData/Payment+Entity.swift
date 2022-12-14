//
//  Payment+Entity.swift
//  MembersOf
//
//  Created by Ravil Khusainov on 9/14/22.
//

import Foundation
import CoreData
import Models

extension Payment: Storable {
    
    static func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Payment")
    }
    
    @objc(PaymentEntity)
    final class Entity: NSManagedObject {
        
        @NSManaged public var id: UUID
        @NSManaged public var currency: String
        @NSManaged public var amount: NSDecimalNumber
        @NSManaged public var date: Date
        @NSManaged public var debt: Debt.Entity?
    }
    
    init(_ entity: Entity) {
        let debt = entity.debt == nil ? nil : Debt(entity.debt!)
        self.init(id: entity.id, currency: entity.currency, amount: entity.amount.decimalValue, date: entity.date, debt: debt)
    }
    
    func entity(_ context: NSManagedObjectContext) -> Entity {
        let entity = find(in: context) ?? Entity(context: context)
        entity.id = id
        entity.currency = currency
        entity.amount = .init(decimal: amount)
        entity.date = date
        return entity
    }
    
    func find(in context: NSManagedObjectContext) -> Entity? {
        Payment.first(in: context, key: "id", value: id.uuidString)
    }
}
