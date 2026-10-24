Feature: buffer

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And buffer.clear()
  And source.subscribe()
  And closing.subscribe()

Scenario: AppendValue
  Given subscription.active == true
  When source.next(value)
  Then buffer.push(value)
  And emit nothing

Scenario: ClosingEmits
  Given subscription.active == true
  When closing.next()
  Then emit buffer
  And buffer.clear()

Scenario: ClosingCompletes
  Given subscription.active == true
  When closing.complete()
  Then nothing

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then emit buffer
  And closing.unsubscribe()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then buffer.clear()
  And closing.unsubscribe()
  And error err

Scenario: ErrorClosing
  Given subscription.active == true
  When closing.error(err)
  Then buffer.clear()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And closing.unsubscribe()
  And buffer.clear()
  And subscription.active = false

