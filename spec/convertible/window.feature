Feature: window

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And window.create()
  And emit window.asObservable()
  And source.subscribe()
  And boundary.subscribe()

Scenario: RouteValue
  Given subscription.active == true
  When source.next(value)
  Then window.next(value)
  And emit nothing

Scenario: BoundaryEmits
  Given subscription.active == true
  When boundary.next()
  Then window.complete()
  And window.create()
  And emit window.asObservable()

Scenario: BoundaryCompletes
  Given subscription.active == true
  When boundary.complete()
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then window.complete()
  And boundary.unsubscribe()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then window.error(err)
  And boundary.unsubscribe()
  And error err

Scenario: ErrorBoundary
  Given subscription.active == true
  When boundary.error(err)
  Then window.error(err)
  And source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And boundary.unsubscribe()
  And window.unsubscribe()
  And subscription.active = false

