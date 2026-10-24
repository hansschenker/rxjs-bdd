Feature: expand

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And active.count = 0
  And buffer.length = 0
  And source.completed = false
  And source.subscribe()

Scenario: ExpandSourceValue
  Given subscription.active == true
  And active.count < concurrent
  When source.next(value)
  Then emit value
  And inner.subscribe(project(value))
  And active.count = active.count + 1

Scenario: BufferSourceValue
  Given subscription.active == true
  And active.count >= concurrent
  When source.next(value)
  Then buffer.push(value)
  And buffer.length = buffer.length + 1
  And emit nothing

Scenario: ExpandInnerValue
  Given active.count > 0
  And active.count < concurrent
  When inner.next(value)
  Then emit value
  And inner.subscribe(project(value))
  And active.count = active.count + 1

Scenario: BufferInnerValue
  Given active.count >= concurrent
  When inner.next(value)
  Then buffer.push(value)
  And buffer.length = buffer.length + 1
  And emit nothing

Scenario: InnerCompletesWithBuffer
  Given active.count > 0
  And buffer.length > 0
  When inner.complete()
  Then emit buffer.head
  And inner.subscribe(project(buffer.head))
  And buffer.shift()
  And buffer.length = buffer.length - 1

Scenario: InnerCompletesOthersActive
  Given active.count > 1
  And buffer.length == 0
  When inner.complete()
  Then active.count = active.count - 1

Scenario: LastInnerCompletesSourceActive
  Given active.count == 1
  And buffer.length == 0
  And source.completed == false
  When inner.complete()
  Then active.count = 0

Scenario: LastInnerCompletesAfterSourceCompleted
  Given active.count == 1
  And buffer.length == 0
  And source.completed == true
  When inner.complete()
  Then active.count = 0
  And complete

Scenario: CompleteSourceIdle
  Given subscription.active == true
  And active.count == 0
  And buffer.length == 0
  When source.complete()
  Then complete

Scenario: CompleteSourceBusy
  Given subscription.active == true
  And (active.count > 0 or buffer.length > 0)
  When source.complete()
  Then source.completed = true

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then buffer.clear()
  And inner.unsubscribeAll()
  And error err

Scenario: ErrorInner
  Given active.count > 0
  When inner.error(err)
  Then buffer.clear()
  And inner.unsubscribeAll()
  And source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And inner.unsubscribeAll()
  And buffer.clear()
  And subscription.active = false

