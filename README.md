# currentuser-data

This is an experimental project. It should not be used for now.

## Usage

### Users

To define the connected application use:

```ruby
Currentuser::Data::User.application_id = 'my_application_id'
```

Then you can use ActiveResource API. Note that only a small part of this API is available:

```ruby
# Create a user
user = Currentuser::Data::User.new(email: 'email@example.org', password 'my password')
user.save

# Delete all users in the application (available only for test applications)
Currentuser::Data::User.delete(:clear)
```

### Application

To retrieve data of your application:

```ruby
Currentuser::Data::Application.application_id = 'my_application_id'
application = Currentuser::Data::Application.current
```

## Contributing to currentuser-data (not recommended yet)

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

### Tests

Setting `CURRENTUSER_APPLICATION_ID_FOR_TESTS` is required to run all the tests. The given id should correspond to a
 Currentuser application with the following properties:

* _test_ should be set to true
* _url_ can be set to any value

## Copyright

Copyright (c) 2014 eric-currentuser. See LICENSE.txt for
further details.

