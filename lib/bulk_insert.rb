require 'active_record'
require "bulk_insert/version"

module BulkInsert
  class Handler
    attr_accessor :table_name, :column_names, :return_value, :uses_transaction, :connection_source

    def self.with_transaction(table_name, column_names, return_value = "*")
      new(table_name, column_names, return_value).tap do |handler|
        handler.uses_transaction = true
      end
    end

    def initialize(table_name, column_names, return_value = "*")
      raise "table_name must be present" if table_name.nil? || table_name.empty?
      raise "column_names must be present" if column_names.nil? || column_names.empty?

      self.table_name = table_name
      self.column_names = Array(column_names).map(&:to_s)
      self.return_value = return_value
      self.connection_source = ActiveRecord::Base
    end

    def insert(rows)
      raise "rows must be present" if rows.nil? || rows.empty?

      sql = generate_sql(rows)
      self.uses_transaction ? perform_sql_in_transaction(sql) : perform_sql(sql)
    end

    private
    def generate_sql(rows)
      values_sql = generate_values_sql(rows)

      column_names_sql = "(#{self.column_names.join(', ')})"
      %(INSERT INTO #{self.table_name} #{column_names_sql} VALUES #{values_sql} RETURNING #{self.return_value})
    end

    def generate_values_sql(rows)
      rows.map do |row|
        row = Hash[row.map{ |k, v| [k.to_s, v] }]
        values = @column_names.map { |n| row[n] }
        connection_source.send(:sanitize_sql_array, [cached_value_sql, *values])
      end.join(', ')
    end

    def perform_sql(sql)
      connection_source.connection.execute(sql).to_a
    end

    def perform_sql_in_transaction(sql)
      stmt_result = nil
      connection_source.transaction do
        stmt_result = connection_source.connection.execute(sql).to_a
      end
      stmt_result
    end

    def cached_value_sql
      @cached_value_sql ||= begin
        t = @column_names.map { "?" }.join(", ")
        "(#{t})"
      end
    end
  end
end
