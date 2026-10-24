Feature: windowToggle

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And windows.count = 0
  And openings.subscribe()
  And source.subscribe()

Scenario: RouteValue
  Given subscription.active == true
  When source.next(value)
  Then windows.nextAll(value)
  And emit nothing

Scenario: OpeningEmits
  Given subscription.active == true
  When openings.next(opening)
  Then windows.open(opening)
  And windows.count = windows.count + 1
  And emit windows.get(opening)
  And closing.subscribe(opening)

Scenario: ClosingEmits
  Given subscription.active == true
  And windows.count > 0
  When closing.next(opening)
  Then closing.unsubscribe(opening)
  And windows.complete(opening)
  And windows.count = windows.count - 1

Scenario: ClosingCompletes
  Given subscription.active == true
  And windows.count > 0
  When closing.complete(opening)
  Then closing.unsubscribe(opening)
  And windows.complete(opening)
  And windows.count = windows.count - 1

Scenario: OpeningsComplete
  Given subscription.active == true
  When openings.complete()
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then windows.completeAll()
  And openings.unsubscribe()
  And closing.unsubscribeAll()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then windows.errorAll(err)
  And openings.unsubscribe()
  And closing.unsubscribeAll()
  And error err

Scenario: ErrorOpenings
  Given subscription.active == true
  When openings.error(err)
  Then windows.errorAll(err)
  And closing.unsubscribeAll()
  And source.unsubscribe()
  And error err

Scenario: ErrorClosing
  Given subscription.active == true
  When closing.error(err, opening)
  Then windows.errorAll(err)
  And openings.unsubscribe()
  And source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And openings.unsubscribe()
  And closing.unsubscribeAll()
  And windows.unsubscribeAll()
  And subscription.active = false

