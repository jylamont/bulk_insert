require 'active_record'
require "bulk_insert/version"

module BulkInsert
  class Handler
    attr_accessor :table_name, :return_value, :uses_transaction
    attr_reader :column_names

    def self.with_transaction(table_name, column_names, return_value = "*")
      new(table_name, column_names, return_value).tap do |handler|
        handler.uses_transaction = true
      end
    end

    def initialize(table_name, column_names, return_value = "*")
      raise "table_name must be present" if table_name.nil? || table_name.empty?
      raise "column_names must be present" if column_names.nil? || column_names.empty?

      self.table_name = table_name
      self.column_names = column_names
      self.return_value = return_value
    end

    def column_names=(value)
      @column_names = Array(value)
      @column_names_lookup = {}

      @column_names.each_with_index do |name, i|
        @column_names_lookup[name] = i
      end

      @column_names
    end

    def insert(rows)
      raise "rows must be present" if rows.nil? || rows.empty?

      sql = generate_sql(rows)
      self.uses_transaction ? perform_sql_in_transaction(sql) : perform_sql(sql)
    end

    private
    def generate_sql(rows)
      values_sql = generate_values_sql(rows)
      %(INSERT INTO #{self.table_name} (#{self.column_names.join(', ')}) VALUES #{values_sql} RETURNING #{self.return_value})
    end

    def generate_values_sql(rows)
      @cached_value_sql ||= begin
        t = @column_names.map { "?" }.join(", ")
        "(#{t})"
      end

      rows.map do |row|
        array = [@cached_value_sql] + @column_names.map { |n| row[n] }
        ActiveRecord::Base.send(:sanitize_sql_array, array)
      end.join(', ')
    end

    def perform_sql(sql)
      ActiveRecord::Base.connection.execute(sql).to_a
    end

    def perform_sql_in_transaction(sql)
      r = nil
      ActiveRecord::Base.transaction do
        r = ActiveRecord::Base.connection.execute(sql).to_a
      end

      r
    end
  end
end
