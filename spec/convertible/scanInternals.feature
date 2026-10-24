Feature: scanInternals

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

Scenario: FirstValueEmitting
  Given subscription.active == true
  And hasAcc == false
  And emitOnNext == true
  When source.next(value)
  Then acc = value
  And hasAcc = true
  And index = index + 1
  And emit acc

Scenario: FirstValueSilent
  Given subscription.active == true
  And hasAcc == false
  And emitOnNext == false
  When source.next(value)
  Then acc = value
  And hasAcc = true
  And index = index + 1
  And emit nothing

Scenario: AccumulateEmitting
  Given subscription.active == true
  And hasAcc == true
  And emitOnNext == true
  When source.next(value)
  Then acc = accumulator(acc, value, index)
  And index = index + 1
  And emit acc

Scenario: AccumulateSilent
  Given subscription.active == true
  And hasAcc == true
  And emitOnNext == false
  When source.next(value)
  Then acc = accumulator(acc, value, index)
  And index = index + 1
  And emit nothing

Scenario: CompleteEmittingAccumulator
  Given subscription.active == true
  And emitOnComplete == true
  And hasAcc == true
  When source.complete()
  Then emit acc
  And complete

Scenario: CompleteSilent
  Given subscription.active == true
  And (emitOnComplete == false or hasAcc == false)
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

