Feature: repeatWhen

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And executing = true
  And notifier.created = false
  And notifier.completed = false
  And source.subscribe()

Scenario: ForwardValue
  Given executing == true
  When source.next(value)
  Then emit value

Scenario: SourceCompletesFirstTime
  Given executing == true
  And notifier.created == false
  When source.complete()
  Then executing = false
  And notifier.created = true
  And notifier.subscribe(completions)
  And completions.next()

Scenario: SourceCompletesAgain
  Given executing == true
  And notifier.created == true
  And notifier.completed == false
  When source.complete()
  Then executing = false
  And completions.next()

Scenario: SourceCompletesAfterNotifierCompleted
  Given executing == true
  And notifier.completed == true
  When source.complete()
  Then complete

Scenario: NotifierEmits
  Given executing == false
  When notifier.next()
  Then executing = true
  And source.subscribe()

Scenario: NotifierCompletesWhileWaiting
  Given executing == false
  When notifier.complete()
  Then notifier.completed = true
  And complete

Scenario: NotifierCompletesWhileExecuting
  Given executing == true
  When notifier.complete()
  Then notifier.completed = true

Scenario: ErrorSource
  Given executing == true
  When source.error(err)
  Then notifier.unsubscribe()
  And error err

Scenario: ErrorNotifier
  Given notifier.created == true
  When notifier.error(err)
  Then source.unsubscribe()
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And notifier.unsubscribe()
  And subscription.active = false

