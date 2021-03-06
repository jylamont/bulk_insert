# BulkInsert

Quick and dirty mass-insert with ActiveRecord and PostgreSQL. This gem assumes that all data being inserted has already been validated, and that table and column names have been checked for SQL injection vulnerabilities.

## Installation

Add this line to your application's Gemfile:

    gem 'bulk_insert'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bulk_insert

## Usage

```ruby
BulkInsert::Handler.new(table_name, [*column_names]).insert([*rows])
```

For example, to insert 10 comments into your database you can use the following...

```ruby
BulkInsert::Handler.new("comments", ["id", "author_id", "text", "created_at"]).insert([
  {"id" => 1, "author_id" => 1, "text" => "Hello world!", "created_at" => "now"},
  ...
])
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
