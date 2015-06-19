# method_caching

method_caching is a simple Ruby library for caching instance method of a class (using Rails.cache as cache store)

## Installation

```bash
  gem install method_caching
```

or add to Gemfile

```bash
  gem "method_caching"
```

## Usage

### With ActiveRecord

```ruby
class User < ActiveRecord::Base
  method_caching

  def full_name
    "#{first_name} #{last_name}"
  end
  cache_method :full_name, clear_on: :save # Clear cache for method full_name whenever method 'save' is called
end
```

### Without ActiveRecord (Mongoid, etc)

```ruby
class User
  include MethodCaching::Generic
  method_caching

  def full_name
    "#{first_name} #{last_name}"
  end
  cache_method :full_name, clear_on: :save # Clear cache for method full_name whenever method 'save' is called
end
```

### Custom Identifier

By default, method_caching will use the record's id as the default identifier to generate the cache key. You can change the default identifier by passing custom identifier

```ruby
class User < ActiveRecord::Base
  method_caching :custom_identifier
end
```

## Contributing to method_caching

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Huy Ha. See LICENSE.txt for further details.