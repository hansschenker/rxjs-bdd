Feature: sampleTime

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.exists = false
  And source.subscribe()
  And interval.start(period)

Scenario: StoreLatestValue
  Given subscription.active == true
  When source.next(value)
  Then pending.value = value
  And pending.exists = true
  And emit nothing

Scenario: IntervalTicksWithPending
  Given pending.exists == true
  When interval.tick()
  Then emit pending.value
  And pending.exists = false

Scenario: IntervalTicksWithoutPending
  Given pending.exists == false
  When interval.tick()
  Then emit nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then pending.exists = false
  And interval.cancel()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then pending.exists = false
  And interval.cancel()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And interval.cancel()
  And pending.exists = false
  And subscription.active = false

