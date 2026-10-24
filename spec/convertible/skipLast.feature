Feature: skipLast

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And ring.clear()
  And ring.length = 0
  And source.subscribe()

Scenario: BufferValue
  Given subscription.active == true
  And ring.length < count
  When source.next(value)
  Then ring.push(value)
  And ring.length = ring.length + 1
  And emit nothing

Scenario: EmitOldestBufferedValue
  Given subscription.active == true
  And ring.length == count
  When source.next(value)
  Then emit ring.shift()
  And ring.push(value)

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then ring.clear()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then ring.clear()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And ring.clear()
  And subscription.active = false

