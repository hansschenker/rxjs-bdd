Feature: zip

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And queues.clear()
  And inputs.subscribeAll()

Scenario: QueueValue
  Given subscription.active == true
  And queues.othersNonEmpty(index) == false
  When input.next(value, index)
  Then queues.push(index, value)
  And emit nothing

Scenario: EmitTuple
  Given subscription.active == true
  And queues.othersNonEmpty(index) == true
  And queues.completedDrainsOnShift() == false
  When input.next(value, index)
  Then queues.push(index, value)
  And emit project(queues.shiftAll())

Scenario: EmitTupleAndComplete
  Given subscription.active == true
  And queues.othersNonEmpty(index) == true
  And queues.completedDrainsOnShift() == true
  When input.next(value, index)
  Then queues.push(index, value)
  And emit project(queues.shiftAll())
  And complete
  And inputs.unsubscribeAll()

Scenario: InputCompletesEmptyQueue
  Given subscription.active == true
  And queues.length(index) == 0
  When input.complete(index)
  Then complete
  And inputs.unsubscribeAll()

Scenario: InputCompletesNonEmptyQueue
  Given subscription.active == true
  And queues.length(index) > 0
  When input.complete(index)
  Then completed.add(index)

Scenario: ErrorInput
  Given subscription.active == true
  When input.error(err, index)
  Then queues.clear()
  And inputs.unsubscribeAll()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then inputs.unsubscribeAll()
  And queues.clear()
  And subscription.active = false

