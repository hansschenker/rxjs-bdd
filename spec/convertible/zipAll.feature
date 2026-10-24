Feature: zipAll

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And collecting = true
  And inners.count = 0
  And source.subscribe()

Scenario: CollectInner
  Given collecting == true
  When source.next(value)
  Then inners.collect(value)
  And inners.count = inners.count + 1
  And emit nothing

Scenario: OuterCompletesWithoutInners
  Given collecting == true
  And inners.count == 0
  When source.complete()
  Then collecting = false
  And complete

Scenario: OuterCompletesWithInners
  Given collecting == true
  And inners.count > 0
  When source.complete()
  Then collecting = false
  And queues.clear()
  And inners.subscribeAll()

Scenario: QueueValue
  Given collecting == false
  And queues.othersNonEmpty(index) == false
  When inner.next(value, index)
  Then queues.push(index, value)
  And emit nothing

Scenario: EmitTuple
  Given collecting == false
  And queues.othersNonEmpty(index) == true
  And queues.completedDrainsOnShift() == false
  When inner.next(value, index)
  Then queues.push(index, value)
  And emit project(queues.shiftAll())

Scenario: EmitTupleAndComplete
  Given collecting == false
  And queues.othersNonEmpty(index) == true
  And queues.completedDrainsOnShift() == true
  When inner.next(value, index)
  Then queues.push(index, value)
  And emit project(queues.shiftAll())
  And complete
  And inners.unsubscribeAll()

Scenario: InnerCompletesEmptyQueue
  Given collecting == false
  And queues.length(index) == 0
  When inner.complete(index)
  Then complete
  And inners.unsubscribeAll()

Scenario: InnerCompletesNonEmptyQueue
  Given collecting == false
  And queues.length(index) > 0
  When inner.complete(index)
  Then completed.add(index)

Scenario: ErrorOuter
  Given collecting == true
  When source.error(err)
  Then inners.clear()
  And error err

Scenario: ErrorInner
  Given collecting == false
  When inner.error(err, index)
  Then queues.clear()
  And inners.unsubscribeAll()
  And error err

Scenario: UnsubscribeWhileCollecting
  Given collecting == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And inners.clear()
  And subscription.active = false

Scenario: UnsubscribeWhileZipping
  Given collecting == false
  When subscriber.unsubscribe()
  Then inners.unsubscribeAll()
  And queues.clear()
  And subscription.active = false

