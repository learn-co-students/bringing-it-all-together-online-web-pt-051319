class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed    
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
      
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
      SQL
      
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      
    DB[:conn].execute(sql, self.name, self.breed)
    
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
    self
  end
  
  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end
  
  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_id(number)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, number).map { |row| Dog.new_from_db(row) }.first
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    
    if !dog.empty?
      self.new_from_db(dog[0])
    else
      self.create(name: name, breed: breed)
    end
    
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    
    dog = DB[:conn].execute(sql, name).first
    
    Dog.new_from_db(dog)
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed, self.id)
      
  end
    
end