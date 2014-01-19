require 'active_record'
require "bulk_insert/version"

module BulkInsert
  class Handler
    attr_accessor :table_name, :column_names, :return_value, :uses_transaction

    def self.with_transaction(table_name, column_names, return_value = "*")
      new(table_name, column_names, return_value).tap do |handler|
        handler.uses_transaction = true
      end
    end

    def initialize(table_name, column_names, return_value = "*")
      raise "table_name must be present" if table_name.nil? || table_name.empty?
      raise "column_names must be present" if column_names.nil? || column_names.empty?

      self.table_name = table_name
      self.column_names = Array(column_names).map(&:to_sym)
      self.return_value = return_value
    end

    def insert(rows)
      raise "rows must be present" if rows.nil? || rows.empty?

      sql = generate_sql(rows)
      self.uses_transaction ? perform_sql_in_transaction(sql) : perform_sql(sql)
    end

    private
    def generate_sql(rows)
      column_names_sql = self.column_names.map(&:to_s).join(', ')
      column_names_sql = "(#{column_names_sql})"
      values_sql       = generate_values_sql(rows)

      %(INSERT INTO #{self.table_name} #{column_names_sql} VALUES #{values_sql} RETURNING #{self.return_value})
    end

    def generate_values_sql(rows)
      @cached_value_sql ||= begin
        t = @column_names.map { "?" }.join(", ")
        "(#{t})"
      end

      rows.map do |row|
        values = @column_names.map { |n| row[n] || row[n.to_s] }
        ActiveRecord::Base.send(:sanitize_sql_array, [@cached_value_sql, *values])
      end.join(', ')
    end

    def perform_sql(sql)
      ActiveRecord::Base.connection.execute(sql).to_a
    end

    def perform_sql_in_transaction(sql)
      stmt_result = nil
      ActiveRecord::Base.transaction do
        stmt_result = ActiveRecord::Base.connection.execute(sql).to_a
      end
      stmt_result
    end
  end
end
