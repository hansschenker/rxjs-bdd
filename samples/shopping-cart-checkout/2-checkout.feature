Feature: ShoppingCartCheckout

Scenario: AddItem
  Given stage == "shopping"
  When cart.addItem(price)
  Then cart.count = cart.count + 1
  And cart.total = cart.total + price
  And emit nothing

Scenario: RemoveItem
  Given stage == "shopping"
  And cart.count > 0
  When cart.removeItem(price)
  Then cart.count = cart.count - 1
  And cart.total = cart.total - price
  And emit nothing

Scenario: CheckoutWithItems
  Given stage == "shopping"
  And cart.count > 0
  When customer.checkout()
  Then stage = "review"
  And emit checkout.review(cart.total)

Scenario: CheckoutEmptyCart
  Given stage == "shopping"
  And cart.count == 0
  When customer.checkout()
  Then emit checkout.rejected("EmptyCart")

Scenario: ConfirmOrder
  Given stage == "review"
  When customer.confirm()
  Then stage = "awaitingPayment"
  And emit payment.request(cart.total)

Scenario: CancelFromReview
  Given stage == "review"
  When customer.cancel()
  Then stage = "cancelled"
  And emit order.cancelled("CustomerCancelled")
  And complete

Scenario: PaymentAuthorized
  Given stage == "awaitingPayment"
  When payment.authorized(reference)
  Then stage = "confirmed"
  And emit order.placed(reference)
  And complete

Scenario: PaymentDeclinedRetry
  Given stage == "awaitingPayment"
  And payment.declines + 1 < maxRetries
  When payment.declined(reason)
  Then payment.declines = payment.declines + 1
  And emit payment.request(cart.total)

Scenario: PaymentDeclinedFinal
  Given stage == "awaitingPayment"
  And payment.declines + 1 >= maxRetries
  When payment.declined(reason)
  Then error PaymentFailed

Scenario: CancelFromPayment
  Given stage == "awaitingPayment"
  When customer.cancel()
  Then stage = "cancelled"
  And emit order.cancelled("CustomerCancelled")
  And complete
