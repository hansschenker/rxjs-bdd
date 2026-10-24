Feature: groupBy

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And groups.clear()
  And groups.subscribers = 0
  And outer.subscribed = true
  And source.subscribe()

Scenario: ValueWithNewKey
  Given subscription.active == true
  And groups.has(keySelector(value)) == false
  And durationSelector.configured == false
  When source.next(value)
  Then groups.create(keySelector(value))
  And emit groups.get(keySelector(value))
  And groups.next(keySelector(value), value)

Scenario: ValueWithNewKeyAndDuration
  Given subscription.active == true
  And groups.has(keySelector(value)) == false
  And durationSelector.configured == true
  When source.next(value)
  Then groups.create(keySelector(value))
  And duration.subscribe(keySelector(value))
  And emit groups.get(keySelector(value))
  And groups.next(keySelector(value), value)

Scenario: ValueWithExistingKey
  Given subscription.active == true
  And groups.has(keySelector(value)) == true
  When source.next(value)
  Then groups.next(keySelector(value), value)
  And emit nothing

Scenario: GroupSubscribed
  Given groups.has(key) == true
  When group.subscribe(key)
  Then groups.subscribers = groups.subscribers + 1

Scenario: DurationEmits
  Given groups.has(key) == true
  When duration.next(key)
  Then groups.complete(key)
  And groups.delete(key)
  And duration.unsubscribe(key)

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then groups.completeAll()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then groups.errorAll(err)
  And error err

Scenario: ErrorDuration
  Given groups.has(key) == true
  When duration.error(err, key)
  Then groups.errorAll(err)
  And source.unsubscribe()
  And error err

Scenario: OuterUnsubscribesWithActiveGroups
  Given subscription.active == true
  And groups.subscribers > 0
  When subscriber.unsubscribe()
  Then outer.subscribed = false
  And subscription.active = false

Scenario: OuterUnsubscribesWithoutActiveGroups
  Given subscription.active == true
  And groups.subscribers == 0
  When subscriber.unsubscribe()
  Then outer.subscribed = false
  And source.unsubscribe()
  And groups.clear()
  And subscription.active = false

Scenario: GroupUnsubscribesOthersRemain
  Given groups.subscribers > 1
  When group.unsubscribe(key)
  Then groups.subscribers = groups.subscribers - 1

Scenario: LastGroupUnsubscribesOuterGone
  Given groups.subscribers == 1
  And outer.subscribed == false
  When group.unsubscribe(key)
  Then groups.subscribers = 0
  And source.unsubscribe()
  And groups.clear()

Scenario: LastGroupUnsubscribesOuterActive
  Given groups.subscribers == 1
  And outer.subscribed == true
  When group.unsubscribe(key)
  Then groups.subscribers = 0

