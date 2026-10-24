Feature: debounceTime

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And pending.exists = false
  And task.scheduled = false
  And source.subscribe()

Scenario: ScheduleTask
  Given subscription.active == true
  And task.scheduled == false
  When source.next(value)
  Then pending.value = value
  And pending.exists = true
  And lastTime = now
  And task.scheduled = true
  And task.schedule(dueTime)
  And emit nothing

Scenario: RecordLaterValue
  Given subscription.active == true
  And task.scheduled == true
  When source.next(value)
  Then pending.value = value
  And pending.exists = true
  And lastTime = now
  And emit nothing

Scenario: TaskFiresBeforeDeadline
  Given task.scheduled == true
  And now < lastTime + dueTime
  When task.fire()
  Then task.schedule(lastTime + dueTime - now)
  And emit nothing

Scenario: TaskFiresAtDeadline
  Given task.scheduled == true
  And now >= lastTime + dueTime
  When task.fire()
  Then task.scheduled = false
  And emit pending.value
  And pending.exists = false

Scenario: CompleteWithPending
  Given subscription.active == true
  And pending.exists == true
  When source.complete()
  Then task.cancel()
  And task.scheduled = false
  And emit pending.value
  And pending.exists = false
  And complete

Scenario: CompleteWithoutPending
  Given subscription.active == true
  And pending.exists == false
  When source.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then pending.exists = false
  And task.cancel()
  And task.scheduled = false
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And task.cancel()
  And pending.exists = false
  And subscription.active = false

