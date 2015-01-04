//
//  OrderedDictionary.swift
//
//  Created by Berik Visschers, on 2015-01-03.
//  Copyright (c) 2015 Berik Visschers. All rights reserved.
//

struct OrderedDictionary<Key: Hashable, Value>: CollectionType, DictionaryLiteralConvertible {
    typealias Index = Int
    typealias Element = (key: Key, value: Value)
    
    private var _keys = [Key]()
    var keys: [Key] { return _keys }

    private var _storage = [Key: Value]()
    var values: [Value] {
        return keys.map { self._storage[$0]! }
    }
    
    var startIndex: Index { return 0 }
    var endIndex: Index { return self.keys.endIndex }
    
    var count: Int { return self.keys.count }
    var isEmpty: Bool { return self.keys.isEmpty }
    
    var first: Element? {
        if let key = keys.first {
            if let value = values.first {
                return (key, value)
            }
        }
        return nil
    }
    
    var last: Element? {
        if let key = keys.last {
            if let value = values.last {
                return (key, value)
            }
        }
        return nil
    }

    func indexForKey(key: Key) -> Index? { return find(keys, key) }

    init() {}
    
    init(_ orderedDictionary: OrderedDictionary<Key, Value>) {
        self._keys = orderedDictionary._keys
        self._storage = orderedDictionary._storage
    }
    
    init(dictionaryLiteral elements: (Key, Value)...) {
        for element in elements {
            _keys.append(element.0)
            _storage[element.0] = element.1
        }
    }
    
    func generate() -> GeneratorOf<Element> {
        var keysGenerator = keys.generate()
        var valuesGenerator = values.generate()
        return GeneratorOf {
            if let key = keysGenerator.next() {
                if let value = valuesGenerator.next() {
                    return (key, value)
                }
            }
            return nil
        }
    }
    
    mutating func append(#key: Key, value: Value) {
        if _storage[key] == nil {
            _keys.append(key)
        }
        _storage[key] = value
    }
        
    mutating func removeLast() -> Element {
        let key = _keys.removeLast()
        let value = _storage.removeValueForKey(key)!
        return (key, value)
    }
    
    mutating func insert(newElement: Element, atIndex index: Index) {
        let (key, value) = newElement
        if _storage[key] == nil {
            _keys.insert(key, atIndex: index)
        }
        _storage[key] = value
    }
    
    mutating func updateValue(value: Value, forKey key: Key) -> Value? {
        if _storage[key] == nil {
            _keys.append(key)
        }
        
        return _storage.updateValue(value, forKey: key)
    }
    
    mutating func removeAtIndex(index: Index) {
        let key = _keys.removeAtIndex(index)
        _storage.removeValueForKey(key)
    }
    
    mutating func removeValueForKey(key: Key) -> Value? {
        if let position = find(keys, key) {
            _keys.removeAtIndex(position)
        }
        return _storage.removeValueForKey(key)
    }
    
    mutating func removeAll(keepCapacity: Bool = false) {
        _keys.removeAll(keepCapacity: keepCapacity)
        _storage.removeAll(keepCapacity: keepCapacity)
    }
    
    subscript(position: Index) -> Element {
        get {
            let key = keys[position]
            return (key, _storage[key]!)
        }
        set(newValue) {
            let (key, value) = newValue
            if find(keys, key) == nil {
                _keys.append(key)
            }
            _storage[key] = value
        }
    }
    
    subscript(key: Key) -> Value? {
        get {
            return _storage[key]
        }
        set(newValue) {
            if let value = newValue {
                if _storage[key] == nil {
                    _keys.append(key)
                }
                _storage[key] = value
            } else {
                if let index = find(self.keys, key) {
                    _keys.removeAtIndex(index)
                    _storage.removeValueForKey(key)
                }
            }
        }
    }
    
    mutating func sort(isOrderedBefore: (Element, Element) -> Bool) {
        return _keys.sort {
            let lhs = ($0, self._storage[$0]!)
            let rhs = ($1, self._storage[$1]!)
            return isOrderedBefore(lhs, rhs)
        }
    }
    
    func map<U>(transform: (Element) -> U) -> [U] {
        var result = [U]()
        for element in self {
            result.append(transform(element))
        }
        return result
    }
    
    func filter(includeElement: (Element) -> Bool) -> OrderedDictionary<Key, Value> {
        var result = OrderedDictionary<Key, Value>()
        for element in self {
            if includeElement(element) {
                result.append(element)
            }
        }
        return result
    }
    
    func reverse() -> OrderedDictionary {
        var result = OrderedDictionary<Key, Value>()
        result._keys = keys.reverse()
        result._storage = _storage
        return result
    }
}

extension OrderedDictionary: Printable, DebugPrintable {
    var debugDescription: String {
        return description
    }

    var description: String {
        var result = "{\n"
        for (index, (key, value)) in enumerate(self) {
            result += "[\(index)]: \(key) => \(value)\n"
        }
        result += "}"
        return result
    }
}

func ==<Key: Equatable, Value: Equatable>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> Bool {
    return lhs.keys == rhs.keys && lhs.values == rhs.values
}

func +=<Key, Value>(inout lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) {
    for element in rhs {
        lhs.append(key: element.key, value: element.value)
    }
}

func +<Key, Value>(lhs: OrderedDictionary<Key, Value>, rhs: OrderedDictionary<Key, Value>) -> OrderedDictionary<Key, Value> {
    var dict = OrderedDictionary<Key, Value>(lhs)
    dict += rhs
    return dict
}
