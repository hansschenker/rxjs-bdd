Feature: distinct

Scenario: SubscribeWithFlushes
  Given subscription.active == false
  And flushes.configured == true
  When subscriber.subscribe()
  Then subscription.active = true
  And keys.clear()
  And source.subscribe()
  And flushes.subscribe()

Scenario: SubscribeWithoutFlushes
  Given subscription.active == false
  And flushes.configured == false
  When subscriber.subscribe()
  Then subscription.active = true
  And keys.clear()
  And source.subscribe()

Scenario: NewKey
  Given subscription.active == true
  And keys.has(keySelector(value)) == false
  When source.next(value)
  Then keys.add(keySelector(value))
  And emit value

Scenario: SeenKey
  Given subscription.active == true
  And keys.has(keySelector(value)) == true
  When source.next(value)
  Then emit nothing

Scenario: FlushesEmits
  Given subscription.active == true
  When flushes.next()
  Then keys.clear()

Scenario: FlushesCompletes
  Given subscription.active == true
  When flushes.complete()
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then keys.clear()
  And flushes.unsubscribe()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then keys.clear()
  And flushes.unsubscribe()
  And error err

Scenario: ErrorFlushes
  Given subscription.active == true
  When flushes.error(err)
  Then keys.clear()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And flushes.unsubscribe()
  And keys.clear()
  And subscription.active = false

