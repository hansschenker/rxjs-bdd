Feature: joinAllInternals

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And collecting = true
  And inners.clear()
  And source.subscribe()

Scenario: CollectInner
  Given collecting == true
  When source.next(value)
  Then inners.collect(value)
  And emit nothing

Scenario: OuterCompletes
  Given collecting == true
  When source.complete()
  Then collecting = false
  And joined.subscribe(joinFn(inners))

Scenario: JoinedEmits
  Given collecting == false
  When joined.next(value)
  Then emit project(value)

Scenario: JoinedCompletes
  Given collecting == false
  When joined.complete()
  Then complete

Scenario: ErrorOuter
  Given collecting == true
  When source.error(err)
  Then inners.clear()
  And error err

Scenario: ErrorJoined
  Given collecting == false
  When joined.error(err)
  Then error err

Scenario: UnsubscribeWhileCollecting
  Given collecting == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And inners.clear()
  And subscription.active = false

Scenario: UnsubscribeWhileJoined
  Given collecting == false
  When subscriber.unsubscribe()
  Then joined.unsubscribe()
  And subscription.active = false

