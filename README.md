# currentuser-data

This is an experimental project. It should not be used for now.

## Configuration

To define the connected project use:

```ruby
Currentuser::Data::BaseResource.project_id = 'my_project_id'
```

## Usage

### Users

You can use ActiveResource API. Note that only a small part of this API is available:

```ruby
# Create a user
user = Currentuser::Data::User.new(email: 'email@example.org', password 'my password')
user.save

# Delete all users in the project (available only for test projects)
Currentuser::Data::User.delete(:clear)
```

### Project

To retrieve data from your project:

```ruby
# Retrieve basic information
project = Currentuser::Data::Project.current
project.name

# Retrieve users
users = project.users('your project secret key')
users.first.email
```

## Testing

See in `lib/currentuser/data/test/helpers` some module to includes to your Test class. Use `UseReadApi` if don't add
 any data, or `UseWriteApi` if you add data.

 **The content of your test project will be deleted at the end of each test.**
 (note that if the given project is not a *test* project, the test will fail and its content will not be deleted)

```ruby
require 'test_helper'

Currentuser::Data::Test::UseReadApi.currentuser_project_id_for_tests = 'my_test_project_id'

class MyTest <ActiveSupport::TestCase
  include Currentuser::Data::Test::UseWriteApi

  test 'foo' do
    Currentuser::Data::User.create(email: 'email@example.org', password: 'password')
  end
end

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

Setting `CURRENTUSER_PROJECT_ID_FOR_TESTS` is required to run all the tests. The given id should correspond to a
 Currentuser project with the following properties:

* _test_ should be set to true
* _url_ can be set to any value

Optionally you can set `CURRENTUSER_SECRET_KEY_FOR_TESTS` (the secret key of the test project) and even more tests will be run.

## Copyright

Copyright (c) 2014 eric-currentuser. See LICENSE.txt for
further details.

