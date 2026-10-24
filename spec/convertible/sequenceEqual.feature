Feature: sequenceEqual

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And a.queue.length = 0
  And b.queue.length = 0
  And a.completed = false
  And b.completed = false
  And source.subscribe()
  And compareTo.subscribe()

Scenario: SourceValueQueued
  Given b.queue.length == 0
  And b.completed == false
  When source.next(value)
  Then a.queue.push(value)
  And a.queue.length = a.queue.length + 1
  And emit nothing

Scenario: SourceValueAfterCompareToDrained
  Given b.queue.length == 0
  And b.completed == true
  When source.next(value)
  Then emit false
  And complete
  And source.unsubscribe()

Scenario: SourceValueMatches
  Given b.queue.length > 0
  And comparator(value, b.queue.head) == true
  When source.next(value)
  Then b.queue.shift()
  And b.queue.length = b.queue.length - 1
  And emit nothing

Scenario: SourceValueMismatch
  Given b.queue.length > 0
  And comparator(value, b.queue.head) == false
  When source.next(value)
  Then emit false
  And complete
  And source.unsubscribe()
  And compareTo.unsubscribe()

Scenario: CompareToValueQueued
  Given a.queue.length == 0
  And a.completed == false
  When compareTo.next(value)
  Then b.queue.push(value)
  And b.queue.length = b.queue.length + 1
  And emit nothing

Scenario: CompareToValueAfterSourceDrained
  Given a.queue.length == 0
  And a.completed == true
  When compareTo.next(value)
  Then emit false
  And complete
  And compareTo.unsubscribe()

Scenario: CompareToValueMatches
  Given a.queue.length > 0
  And comparator(a.queue.head, value) == true
  When compareTo.next(value)
  Then a.queue.shift()
  And a.queue.length = a.queue.length - 1
  And emit nothing

Scenario: CompareToValueMismatch
  Given a.queue.length > 0
  And comparator(a.queue.head, value) == false
  When compareTo.next(value)
  Then emit false
  And complete
  And source.unsubscribe()
  And compareTo.unsubscribe()

Scenario: SourceCompletesCompareToActive
  Given b.completed == false
  When source.complete()
  Then a.completed = true

Scenario: SourceCompletesBothDrained
  Given b.completed == true
  And a.queue.length == 0
  And b.queue.length == 0
  When source.complete()
  Then emit true
  And complete

Scenario: SourceCompletesWithLeftovers
  Given b.completed == true
  And (a.queue.length > 0 or b.queue.length > 0)
  When source.complete()
  Then emit false
  And complete

Scenario: CompareToCompletesSourceActive
  Given a.completed == false
  When compareTo.complete()
  Then b.completed = true

Scenario: CompareToCompletesBothDrained
  Given a.completed == true
  And a.queue.length == 0
  And b.queue.length == 0
  When compareTo.complete()
  Then emit true
  And complete

Scenario: CompareToCompletesWithLeftovers
  Given a.completed == true
  And (a.queue.length > 0 or b.queue.length > 0)
  When compareTo.complete()
  Then emit false
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then a.queue.clear()
  And b.queue.clear()
  And compareTo.unsubscribe()
  And error err

Scenario: ErrorCompareTo
  Given subscription.active == true
  When compareTo.error(err)
  Then a.queue.clear()
  And b.queue.clear()
  And source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And compareTo.unsubscribe()
  And a.queue.clear()
  And b.queue.clear()
  And subscription.active = false

