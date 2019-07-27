class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize (name: name, breed: breed, id: id)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql) 
  end
  
  def self.drop_table
    sql =  <<-SQL 
      DROP TABLE dogs
        SQL
    DB[:conn].execute(sql) 
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self
  end
  
  def self.create(dog_hash)
    dog = Dog.new(dog_hash)
    dog.save
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
     dog_row = DB[:conn].execute(sql, id).flatten
     self.new_from_db(dog_row)
  end
  
   def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
     dog_row = DB[:conn].execute(sql, name).flatten
     self.new_from_db(dog_row)
  end
  
  def self.find_or_create_by(dog_hash)
    name = dog_hash[:name]
    self.find_by_name(name) 
    binding.pry
  end
  
end