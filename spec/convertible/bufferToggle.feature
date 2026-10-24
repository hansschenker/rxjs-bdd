Feature: bufferToggle

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And buffers.count = 0
  And openings.subscribe()
  And source.subscribe()

Scenario: RouteValue
  Given subscription.active == true
  When source.next(value)
  Then buffers.pushAll(value)
  And emit nothing

Scenario: OpeningEmits
  Given subscription.active == true
  When openings.next(opening)
  Then buffers.open(opening)
  And buffers.count = buffers.count + 1
  And closing.subscribe(opening)
  And emit nothing

Scenario: ClosingEmits
  Given subscription.active == true
  And buffers.count > 0
  When closing.next(opening)
  Then closing.unsubscribe(opening)
  And emit buffers.at(opening)
  And buffers.close(opening)
  And buffers.count = buffers.count - 1

Scenario: ClosingCompletesSilently
  Given subscription.active == true
  When closing.complete(opening)
  Then nothing

Scenario: OpeningsComplete
  Given subscription.active == true
  When openings.complete()
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then output.emitEach(buffers)
  And openings.unsubscribe()
  And closing.unsubscribeAll()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then buffers.clear()
  And openings.unsubscribe()
  And closing.unsubscribeAll()
  And error err

Scenario: ErrorOpenings
  Given subscription.active == true
  When openings.error(err)
  Then buffers.clear()
  And closing.unsubscribeAll()
  And error err

Scenario: ErrorClosing
  Given subscription.active == true
  When closing.error(err, opening)
  Then buffers.clear()
  And openings.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And openings.unsubscribe()
  And closing.unsubscribeAll()
  And buffers.clear()
  And subscription.active = false

