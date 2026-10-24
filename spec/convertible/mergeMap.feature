Feature: mergeMap

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And active.count = 0
  And queue.length = 0
  And source.completed = false
  And source.subscribe()

Scenario: AdmitValue
  Given subscription.active == true
  And active.count < concurrent
  When source.next(value)
  Then inner.subscribe(project(value))
  And active.count = active.count + 1

Scenario: QueueValue
  Given subscription.active == true
  And active.count >= concurrent
  When source.next(value)
  Then queue.push(value)
  And queue.length = queue.length + 1
  And emit nothing

Scenario: ForwardInnerValue
  Given active.count > 0
  When inner.next(value)
  Then emit value

Scenario: InnerCompletesWithQueue
  Given active.count > 0
  And queue.length > 0
  When inner.complete()
  Then inner.subscribe(project(queue.shift()))
  And queue.length = queue.length - 1

Scenario: InnerCompletesOthersActive
  Given active.count > 1
  And queue.length == 0
  When inner.complete()
  Then active.count = active.count - 1

Scenario: LastInnerCompletesSourceActive
  Given active.count == 1
  And queue.length == 0
  And source.completed == false
  When inner.complete()
  Then active.count = 0

Scenario: LastInnerCompletesAfterSourceCompleted
  Given active.count == 1
  And queue.length == 0
  And source.completed == true
  When inner.complete()
  Then active.count = 0
  And complete

Scenario: CompleteSourceIdle
  Given subscription.active == true
  And active.count == 0
  And queue.length == 0
  When source.complete()
  Then complete

Scenario: CompleteSourceBusy
  Given subscription.active == true
  And (active.count > 0 or queue.length > 0)
  When source.complete()
  Then source.completed = true

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then queue.clear()
  And inner.unsubscribeAll()
  And error err

Scenario: ErrorInner
  Given active.count > 0
  When inner.error(err)
  Then queue.clear()
  And inner.unsubscribeAll()
  And source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And inner.unsubscribeAll()
  And queue.clear()
  And subscription.active = false

