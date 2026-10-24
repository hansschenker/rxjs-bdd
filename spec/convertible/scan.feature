Feature: scan

Scenario: SubscribeWithSeed
  Given subscription.active == false
  And seed.provided == true
  When subscriber.subscribe()
  Then subscription.active = true
  And acc = seed
  And hasAcc = true
  And index = 0
  And source.subscribe()

Scenario: SubscribeWithoutSeed
  Given subscription.active == false
  And seed.provided == false
  When subscriber.subscribe()
  Then subscription.active = true
  And hasAcc = false
  And index = 0
  And source.subscribe()

Scenario: FirstValueBecomesAccumulator
  Given subscription.active == true
  And hasAcc == false
  When source.next(value)
  Then acc = value
  And hasAcc = true
  And index = index + 1
  And emit acc

Scenario: AccumulateValue
  Given subscription.active == true
  And hasAcc == true
  When source.next(value)
  Then acc = accumulator(acc, value, index)
  And index = index + 1
  And emit acc

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then hasAcc = false
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And hasAcc = false
  And subscription.active = false

