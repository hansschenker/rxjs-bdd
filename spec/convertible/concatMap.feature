Feature: concatMap

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And inner.active = false
  And queue.length = 0
  And source.completed = false
  And source.subscribe()

Scenario: AdmitValue
  Given subscription.active == true
  And inner.active == false
  When source.next(value)
  Then inner.active = true
  And inner.subscribe(project(value))

Scenario: QueueValue
  Given subscription.active == true
  And inner.active == true
  When source.next(value)
  Then queue.push(value)
  And queue.length = queue.length + 1
  And emit nothing

Scenario: ForwardInnerValue
  Given inner.active == true
  When inner.next(value)
  Then emit value

Scenario: InnerCompletesWithQueue
  Given inner.active == true
  And queue.length > 0
  When inner.complete()
  Then inner.subscribe(project(queue.shift()))
  And queue.length = queue.length - 1

Scenario: InnerCompletesIdle
  Given inner.active == true
  And queue.length == 0
  And source.completed == false
  When inner.complete()
  Then inner.active = false

Scenario: InnerCompletesAfterSourceCompleted
  Given inner.active == true
  And queue.length == 0
  And source.completed == true
  When inner.complete()
  Then inner.active = false
  And complete

Scenario: CompleteSourceIdle
  Given subscription.active == true
  And inner.active == false
  And queue.length == 0
  When source.complete()
  Then complete

Scenario: CompleteSourceBusy
  Given subscription.active == true
  And (inner.active == true or queue.length > 0)
  When source.complete()
  Then source.completed = true

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then queue.clear()
  And inner.unsubscribe()
  And error err

Scenario: ErrorInner
  Given inner.active == true
  When inner.error(err)
  Then queue.clear()
  And source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And inner.unsubscribe()
  And queue.clear()
  And subscription.active = false

