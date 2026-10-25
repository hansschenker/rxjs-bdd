# Shopping-cart checkout — Readable BDD

The business use case modelled as a state machine that reacts to customer and
payment-gateway events over time. This is the **Readable BDD** layer: unrestricted
prose in Given / When / Then shape, the same form the operator catalog uses.

The checkout moves through four live stages — `shopping`, `review`, `awaitingPayment`
— and two terminal stages — `confirmed` and `cancelled`. A declined payment is
retried up to `maxRetries` times before the checkout fails.

```text
State
  stage            shopping | review | awaitingPayment | confirmed | cancelled
  cart.count       number of items in the cart
  cart.total       running order total
  payment.declines declined payment attempts so far
  maxRetries       how many payment attempts are allowed (3)
```

## Shopping

```text
Given the cart is in the shopping stage
When the customer adds an item at a price
Then increase the item count by one
     add the price to the order total
     emit nothing

Given the cart is in the shopping stage and holds at least one item
When the customer removes an item at a price
Then decrease the item count by one
     subtract the price from the order total
     emit nothing

Given the cart is in the shopping stage and holds at least one item
When the customer starts checkout
Then move to the review stage
     emit a review summary with the order total

Given the cart is in the shopping stage and is empty
When the customer starts checkout
Then reject the checkout as an empty cart
     stay in the shopping stage
```

## Review

```text
Given the checkout is in the review stage
When the customer confirms the order
Then move to the awaiting-payment stage
     request payment for the order total

Given the checkout is in the review stage
When the customer cancels
Then move to the cancelled stage
     emit an order-cancelled notice
     complete
```

## Awaiting payment

```text
Given the checkout is awaiting payment
When the gateway authorizes the payment with a reference
Then move to the confirmed stage
     emit an order-placed notice with the reference
     complete

Given the checkout is awaiting payment and another attempt is allowed
When the gateway declines the payment
Then count the declined attempt
     request payment again for the order total

Given the checkout is awaiting payment and no further attempt is allowed
When the gateway declines the payment
Then fail the checkout with a payment error

Given the checkout is awaiting payment
When the customer cancels
Then move to the cancelled stage
     emit an order-cancelled notice
     complete
```
