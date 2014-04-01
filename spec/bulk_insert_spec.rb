require 'spec_helper'

describe BulkInsert::Handler do
  it "should accept a table name, column names, and a return value" do
    subject = BulkInsert::Handler.new("test_name", ["id", "name", "created_at"], "id")
    subject.table_name.should == "test_name"
    subject.column_names.should == [:id, :name, :created_at]
    subject.return_value.should == "id"
  end

  it "should raise an exception when either table name or column names are missing" do
    expect { BulkInsert::Handler.new("test_name", ["id", "name", "created_at"]) }.to_not raise_error

    expect { BulkInsert::Handler.new(nil, ["id", "name", "created_at"]) }.to raise_error
    expect { BulkInsert::Handler.new("", ["id", "name", "created_at"]) }.to raise_error

    expect { BulkInsert::Handler.new("test_name", nil) }.to raise_error
    expect { BulkInsert::Handler.new("test_name", []) }.to raise_error
  end

  describe :insert do
    it "should pass a well formated insert statement to perform_sql" do
      subject = BulkInsert::Handler.new("employees", ["id", "name", "hero", "created_at"])

      expected_sql = "INSERT INTO employees (id, name, hero, created_at) VALUES (1, 'James', 't', 'now'), (2, 'Chris', 'f', 'now') RETURNING *"
      subject.should_receive(:perform_sql).with(expected_sql)

      subject.insert([{"id" => 1, "name" => "James", "hero" => true, "created_at" => "now"}, {"id" => 2, "name" => "Chris", "hero" => false, "created_at" => "now"}])
    end

    it "should also work with symbol column names" do
      subject = BulkInsert::Handler.new("employees", ["id", "name", "created_at"])

      expected_sql = "INSERT INTO employees (id, name, created_at) VALUES (1, 'James', 'now'), (2, 'Chris', 'now') RETURNING *"
      subject.should_receive(:perform_sql).with(expected_sql)

      subject.insert([
        {id: 1, name: "James", created_at: "now"},
        {id: 2, name: "Chris", created_at: "now"}
      ])
    end

    it "should raise an error if rows is empty" do
      subject = BulkInsert::Handler.new("employees", ["id", "name", "created_at"])
      expect { subject.insert(nil) }.to raise_error
      expect { subject.insert([]) }.to raise_error
    end

    context "when BulkInsert::Handler#with_transaction is defined" do
      it "should run through a transaction" do
        subject = BulkInsert::Handler.with_transaction("employees", ["id", "name", "created_at"])

        expected_sql = "INSERT INTO employees (id, name, created_at) VALUES (1, 'James', 'now'), (2, 'Chris', 'now') RETURNING *"
        subject.should_receive(:perform_sql_in_transaction).with(expected_sql)

        subject.insert([{"id" => 1, "name" => "James", "created_at" => "now"}, {"id" => 2, "name" => "Chris", "created_at" => "now"}])
      end
    end
  end
end