//
//  Word+CoreDataProperties.swift
//  DictionaryApp
//
//  Created by smartcodingschool on 8/4/22.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var def: String?
    @NSManaged public var word: String?
    @NSManaged public var index: String?
    @NSManaged public var lists: NSSet?

}

// MARK: Generated accessors for lists
extension Word {

    @objc(addListsObject:)
    @NSManaged public func addToLists(_ value: List)

    @objc(removeListsObject:)
    @NSManaged public func removeFromLists(_ value: List)

    @objc(addLists:)
    @NSManaged public func addToLists(_ values: NSSet)

    @objc(removeLists:)
    @NSManaged public func removeFromLists(_ values: NSSet)

}

extension Word : Identifiable {

}
