Feature: delay

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.count = 0
  And source.completed = false
  And source.subscribe()

Scenario: ScheduleValue
  Given subscription.active == true
  When source.next(value)
  Then timer.start(value, due)
  And pending.count = pending.count + 1
  And emit nothing

Scenario: TimerFiresMorePending
  Given pending.count > 1
  When timer.fire(value)
  Then emit value
  And pending.count = pending.count - 1

Scenario: TimerFiresLastPendingSourceActive
  Given pending.count == 1
  And source.completed == false
  When timer.fire(value)
  Then emit value
  And pending.count = 0

Scenario: TimerFiresLastPendingAfterSourceCompleted
  Given pending.count == 1
  And source.completed == true
  When timer.fire(value)
  Then emit value
  And pending.count = 0
  And complete

Scenario: CompleteWithPending
  Given subscription.active == true
  And pending.count > 0
  When source.complete()
  Then source.completed = true

Scenario: CompleteWithoutPending
  Given subscription.active == true
  And pending.count == 0
  When source.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then timer.cancelAll()
  And pending.count = 0
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And timer.cancelAll()
  And pending.count = 0
  And subscription.active = false

