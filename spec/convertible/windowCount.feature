Feature: windowCount

Scenario: SubscribeSource
  Given subscription.active == false
  When subscriber.subscribe()
  Then subscription.active = true
  And windows.open()
  And emit windows.newest()
  And count = 0
  And source.subscribe()

Scenario: RouteValue
  Given subscription.active == true
  And (count - windowSize + 1 < 0 or (count - windowSize + 1) % startWindowEvery != 0)
  And (count + 1) % startWindowEvery != 0
  When source.next(value)
  Then windows.nextAll(value)
  And count = count + 1

Scenario: RouteValueAndCloseOldest
  Given subscription.active == true
  And count - windowSize + 1 >= 0
  And (count - windowSize + 1) % startWindowEvery == 0
  And (count + 1) % startWindowEvery != 0
  When source.next(value)
  Then windows.nextAll(value)
  And windows.completeOldest()
  And count = count + 1

Scenario: RouteValueAndOpenWindow
  Given subscription.active == true
  And (count - windowSize + 1 < 0 or (count - windowSize + 1) % startWindowEvery != 0)
  And (count + 1) % startWindowEvery == 0
  When source.next(value)
  Then windows.nextAll(value)
  And count = count + 1
  And windows.open()
  And emit windows.newest()

Scenario: RouteValueCloseOldestAndOpenWindow
  Given subscription.active == true
  And count - windowSize + 1 >= 0
  And (count - windowSize + 1) % startWindowEvery == 0
  And (count + 1) % startWindowEvery == 0
  When source.next(value)
  Then windows.nextAll(value)
  And windows.completeOldest()
  And count = count + 1
  And windows.open()
  And emit windows.newest()

Scenario: CompleteSource
  Given subscription.active == true
  When source.complete()
  Then windows.completeAll()
  And complete

Scenario: ErrorSource
  Given subscription.active == true
  When source.error(err)
  Then windows.errorAll(err)
  And error err

Scenario: Unsubscribe
  Given subscription.active == true
  When subscriber.unsubscribe()
  Then source.unsubscribe()
  And windows.release()
  And subscription.active = false

