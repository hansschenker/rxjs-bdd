Feature: retryWhen

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And executing = true
  And notifier.created = false
  And source.subscribe()

Scenario: ForwardValue
  Given executing == true
  When source.next(value)
  Then emit value

Scenario: CompleteSource
  Given executing == true
  When source.complete()
  Then complete

Scenario: SourceErrorsFirstTime
  Given executing == true
  And notifier.created == false
  When source.error(err)
  Then executing = false
  And notifier.created = true
  And notifier.subscribe(errors)
  And errors.next(err)

Scenario: SourceErrorsAgain
  Given executing == true
  And notifier.created == true
  When source.error(err)
  Then executing = false
  And errors.next(err)

Scenario: NotifierEmits
  Given executing == false
  When notifier.next()
  Then executing = true
  And source.subscribe()

Scenario: NotifierCompletesWhileWaiting
  Given executing == false
  When notifier.complete()
  Then complete

Scenario: NotifierCompletesWhileExecuting
  Given executing == true
  When notifier.complete()
  Then source.unsubscribe()
  And complete

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

