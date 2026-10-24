Feature: takeLast

Scenario: SubscribePositiveCount
  Given subscription.active == false
  And count > 0
  When subscriber.subscribe()
  Then subscription.active = true
  And buffer.clear()
  And buffer.length = 0
  And source.subscribe()

Scenario: SubscribeNonPositiveCount
  Given subscription.active == false
  And count <= 0
  When subscriber.subscribe()
  Then complete

Scenario: BufferValue
  Given subscription.active == true
  And buffer.length < count
  When source.next(value)
  Then buffer.push(value)
  And buffer.length = buffer.length + 1
  And emit nothing

Scenario: BufferValueDroppingOldest
  Given subscription.active == true
  And buffer.length == count
  When source.next(value)
  Then buffer.shift()
  And buffer.push(value)
  And emit nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then output.emitEach(buffer)
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then buffer.clear()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And buffer.clear()
  And subscription.active = false

