### Please describe found weak places below.

#### Security issues

1. When creating transaction, all params are permitted, this is dangerous because someone can modify the HTML form and provide their own `to amount`, we should explicitly specify which attributes we allow with strong parameters.
2. No authentication or authorization found, which means anyone can access the form and crate transactions. Suggestion: use Devise and Pundit to enforce authentication/authorization
#### Performance issues

1. No pagination is being used when retrieving transactions (in `TransactionsController#index`), this could cause huge performance issue, especially when we have millions of transactions in db.
Solution: use `kaminari` (or some similar pagination gem)

2. Calling `Manager.all.sample` in `TransactionsController` is not efficient, this requires loading all Manager objects from the database into the memory and then select a random record. A more efficient version is: `Manager.find(Manager.ids.sample)`. Even though it sends 2 SQL queries to database, it's actually faster and more memory efficient. Another method is to use `RAND()` provided by the db but some says it's actually a bit slower than the above method.
3. N+1 problem in `views/transactions/index.html.erb`, for each transaction, there is a SQL query to get manager.
Solution: use eager loading in `TransactionsController#index` loading to fix (with `includes(:manager)`)
#### Code issues

1. Duplicate code for `Manager.all.sample` in `TransactionsController`, refactor it into a `get_manager` method so we can reuse (and change it to the better version as mentioned in Point 2 of Performance Issue section)
2. Method `full_name` in Manager model can be refactored using Decorator pattern, it's just for displaying purpose so we might not want it to be inside the model.
3. Method `client_full_name` in Transaction model can also be refactored similarly
4. `Transaction.new` is duplicated in multiple methods, use `before_action` to simplify it
5. Method to set manager in `TransactionsController#create` is always called, it should only be called when we can't save the transaction and rendering the extra view again

6. The code for rendering error in views is quite duplicated, refactoring into a helper method called `error_message_for` in `TranscationsHelper` to shorten the code
#### Others

1. From address in `application_mailer.rb` is hard-coded, we should use ENV variables so it can be changed easily without updating the code
2. Instead of
```
<% if transaction.manager %>
  <%= transaction.manager.full_name %>
<% end %>
```

We can shorten it to `transaction.manager&.full_name`

3. No client side validation on the Form to create new transaction, and no valid errors shown when user accidentally enters an amount > 100 USD while trying to create a small transaction type. No errors shown is because the first_name and last_name validation failed, but no place to show those error messages. This confuses users.