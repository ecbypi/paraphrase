# Changelog

## Unreleased

## [0.13.0] - 2018-04-09
### Removed
* Support for ruby < 2.3
* Support for rails < 4.2

## [0.12.0] - 2015-02-07
### Added
* Add Rails 4.2 support
* Add `Pararhase::Query#model_name` to support `action_view` 4.2

## [0.11.0] - 2014-09-17

* Enable setting default values in param processors. The following will now
  work:

```ruby
class PostQuery < Paraphrase::Query
  map :sort, to: :sorted_by

  param :sort do
    params[:sort].presence || "newest"
  end

  scope :sorted_by do |sort_direction|
    sort_direction == "newest" ? relation.order(created_at: :desc) : relation.order(:created_at)
  end
end
```

## [0.10.0] - 2014-07-03

* Change `Paraphrase::Query.source` to be a regular class attribute, removing
  the DSL method `source` for defining the source.
* Add convenience class-level API for pre-processing query params.
* Rename `Params` to `ParamsFilter`. Always define a `ParamsFilter` subclass
  for each `Paraphrase::Query` subclass on inheritance.
* Make params filtering consistent. Run custom method defiend on `ParamsFilter`
  and then call `scrub` on the return value. Previously, `scrub` would not be
  called if a custom method was defined.
* Rename `Scope` to the more appropriate `Mapping`.
* Mark `Mapping` and `ActiveModel` classes as private API
* Add `Paraphrase::Repository` for defining model scopes in a
  `Paraphrase::Query` subclass.  Scopes can be defined by re-opening the
  `Repository` class available in any `Paraphrase::Query` subclass or using
  `Query.scope` DSL. See README for more.
* Require `Paraphrase::Query` be initialized with an instance of
  `ActiveRecord::Relation`. Update `Paraphrase::Syntax`

## [0.9.0] - 2014-05-02

* Define methods to process query params on a subclass of `Paraphrase::Params`
  that also handles filtering blank query params.
* `Query.keys` and `Query#keys` expose the keys that have been mapped.

## [0.8.0] - 2014-02-05

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

## [0.7.0] - 2014-01-25

* Add Rails 4 support

## [0.5.0] - 2012-08-07

* Cleanup `ScopeMapping` class
* Add ability to query from an existing `ActiveRecord::Relation` instance
  (typically an association).
* Update syntax for generating mappings.

## [0.4.0] - 2012-07-06

* Setup `Query#params` to be `HashWithIndifferentAccess`.
* Gut out `Paraphrase` module methods. These were for use cases I had planned
  for but have yet to encounter.
* Model's query class is now stored on the model itself.

## [0.3.2] - 2012-07-05

* Cache `Query#results`
* Setup `Query#method_missing` to proxy to `Query#results`
* Setup `Query#respond_to?` to check `Query#results`

## [0.3.1] - 2012-07-05

* Fix for rails 3.0

## [0.3.0] - 2012-07-05

* Allow `nil` values to be passed to scoped using `:allow_nil` option.
* Require/whitelist individual keys of a compound key.
* Update `Paraphrase::Syntax.register_mapping` to update an existing mapping to
avoid errors when a model class is reloaded during development.

## [0.2.0] - 2012-06-22

* Initial release

