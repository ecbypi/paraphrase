## Next Release

* Add convenience class-level API for pre-processing query params
* Pre-process params and then scrub them from
* Rename `Scope` to the more appropriate `Mapping`
* Mark `Mapping` and `ActiveModel` classes as private API
* Add ability to define scopes in the `Query` subclass via `Paraphrase::Repository`
  (see README)
* Refactor `Query.source` to be a regular class attribute
* Require `Paraphrase::Query` be initialized with an `ActiveRecord::Relation`
  instance. Ensure this happens in `Paraphrase::Syntax`.

## 0.9.0 / 5-2-2014

* Define methods to process query params on a subclass of `Paraphrase::Params`
  that also handles filtering blank query params.
* `Query.keys` and `Query#keys` expose the keys that have been mapped.

## 0.8.0 / 2-5-2014

* Remove `ActiveSupport::Notifications`
* Remove delegation to `Query#results`
* Rename `Query#results` to `Query#result`
* Add support for use with form builders
* Remove `:require` option in `map`
* Change method signature of `map`. Now accepts a list of keys followed by a
  hash of options. the `:to` option points to the name of the scope that should
  be called with the values of the supplied keys.
* Determine the name of the source ActiveRecord::Base sublcass from the name of
  the query class
* Remove `register_mapping` method added to `ActiveRecord::Base`.

## 0.7.0 / 1-25-2014

* Add Rails 4 support

## 0.5.0 / 8-7-2012

* Cleanup `ScopeMapping` class
* Add ability to query from an existing `ActiveRecord::Relation` instance
  (typically an association).
* Update syntax for generating mappings.

## 0.4.0 / 7-6-2012

* Setup `Query#params` to be `HashWithIndifferentAccess`.
* Gut out `Paraphrase` module methods. These were for use cases I had planned
  for but have yet to encounter.
* Model's query class is now stored on the model itself.

## 0.3.2 / 7-5-2012

* Cache `Query#results`
* Setup `Query#method_missing` to proxy to `Query#results`
* Setup `Query#respond_to?` to check `Query#results`

## 0.3.1 / 7-5-2012

* Fix for rails 3.0

## 0.3.0 / 7-5-2012

* Allow `nil` values to be passed to scoped using `:allow_nil` option.
* Require/whitelist individual keys of a compound key.
* Update `Paraphrase::Syntax.register_mapping` to update an existing mapping to
avoid errors when a model class is reloaded during development.

## 0.2.0 / 6-22-2012

* Initial release

