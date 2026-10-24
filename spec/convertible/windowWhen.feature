Feature: windowWhen

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And window.create()
  And emit window.asObservable()
  And closing.subscribe()
  And source.subscribe()

Scenario: RouteValue
  Given subscription.active == true
  When source.next(value)
  Then window.next(value)
  And emit nothing

Scenario: ClosingEmits
  Given subscription.active == true
  When closing.next()
  Then closing.unsubscribe()
  And window.complete()
  And window.create()
  And emit window.asObservable()
  And closing.subscribe()

Scenario: ClosingCompletes
  Given subscription.active == true
  When closing.complete()
  Then closing.unsubscribe()
  And window.complete()
  And window.create()
  And emit window.asObservable()
  And closing.subscribe()

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then window.complete()
  And closing.unsubscribe()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then window.error(err)
  And closing.unsubscribe()
  And error err

Scenario: ErrorClosing
  Given subscription.active == true
  When closing.error(err)
  Then window.error(err)
  And source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And closing.unsubscribe()
  And window.release()
  And subscription.active = false

