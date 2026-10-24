Feature: combineAll

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And collecting = true
  And inners.count = 0
  And ready.count = 0
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
  And active.count = inners.count
  And inners.subscribeAll()

Scenario: InnerFirstValueNotAllReady
  Given collecting == false
  And latest.has(index) == false
  And ready.count + 1 < inners.count
  When inner.next(value, index)
  Then latest.set(index, value)
  And ready.count = ready.count + 1
  And emit nothing

Scenario: InnerFirstValueAllReady
  Given collecting == false
  And latest.has(index) == false
  And ready.count + 1 == inners.count
  When inner.next(value, index)
  Then latest.set(index, value)
  And ready.count = ready.count + 1
  And emit project(latest.values())

Scenario: InnerLaterValue
  Given collecting == false
  And latest.has(index) == true
  When inner.next(value, index)
  Then latest.set(index, value)
  And emit project(latest.values())

Scenario: InnerCompletesOthersActive
  Given collecting == false
  And active.count > 1
  When inner.complete(index)
  Then active.count = active.count - 1

Scenario: LastInnerCompletes
  Given collecting == false
  And active.count == 1
  When inner.complete(index)
  Then active.count = 0
  And complete

Scenario: ErrorOuter
  Given collecting == true
  When source.error(err)
  Then inners.clear()
  And error err

Scenario: ErrorInner
  Given collecting == false
  When inner.error(err, index)
  Then inners.unsubscribeAll()
  And error err

Scenario: UnsubscribeWhileCollecting
  Given collecting == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And inners.clear()
  And subscription.active = false

Scenario: UnsubscribeWhileCombining
  Given collecting == false
  When subscriber.unsubscribe()
  Then inners.unsubscribeAll()
  And latest.clear()
  And subscription.active = false

