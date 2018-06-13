require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{self.table_name}')"
    DB[:conn].execute(sql).collect do |column|
      column["name"]
    end.compact
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|column| column == "id"}.join(", ")
  end

  def values_for_insert
    values = self.class.column_names.collect do |column|
      if column != "id"
        "'#{send(column)}'"
      end
    end
    values.compact.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert});"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}';"
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    hash.keys #returns array of keys [:key]
    hash.keys[0] #returns :key
    key = hash.keys[0].to_s #returns key
    value = hash[hash.keys[0]] #returns value
    if value.class != String
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = #{value};"
    else
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}';"
    end
    DB[:conn].execute(sql)
  end



end
