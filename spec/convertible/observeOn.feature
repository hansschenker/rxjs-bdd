Feature: observeOn

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.count = 0
  And source.subscribe()

Scenario: ScheduleNext
  Given subscription.active == true
  When source.next(value)
  Then scheduler.schedule(deliverNext(value), delay)
  And pending.count = pending.count + 1
  And emit nothing

Scenario: ScheduleComplete
  Given subscription.active == true
  When source.complete()
  Then scheduler.schedule(deliverComplete(), delay)
  And pending.count = pending.count + 1

Scenario: ScheduleError
  Given subscription.active == true
  When source.error(err)
  Then scheduler.schedule(deliverError(err), delay)
  And pending.count = pending.count + 1

Scenario: DeliverNext
  Given pending.count > 0
  When scheduler.runNext(value)
  Then pending.count = pending.count - 1
  And emit value

Scenario: DeliverComplete
  Given pending.count > 0
  When scheduler.runComplete()
  Then pending.count = pending.count - 1
  And complete

Scenario: DeliverError
  Given pending.count > 0
  When scheduler.runError(err)
  Then pending.count = pending.count - 1
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And scheduler.cancelAll()
  And pending.count = 0
  And subscription.active = false

