class Dog

	attr_accessor :name, :breed, :id

	def initialize(name:, breed:, id: nil)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT
			);
		SQL

		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute('DROP TABLE IF EXISTS dogs;')
	end

	def self.create(attrs_hash)
		self.new(
			name: attrs_hash[:name],
			breed: attrs_hash[:breed]
		).tap{ |dog| dog.save }
	end

	def self.new_from_db(row)
		self.new(
			name: row[1],
			breed: row[2],
			id: row[0]
		)
	end

	def self.find_by_id(id)
		self.new_from_db(DB[:conn].execute('SELECT * FROM dogs WHERE id = ?', id).flatten)
	end

	def self.find_or_create_by(name:, breed:)
		row = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed).flatten
		# binding.pry
		row.empty? ? self.create(name: name, breed: breed) : self.new_from_db(row)
	end

	def self.find_by_name(name)
		self.new_from_db(DB[:conn].execute('SELECT * FROM dogs WHERE name = ?', name)[0])
	end

	def save
		DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?,?);', self.name, self.breed)
		self.id = DB[:conn].execute('SELECT id FROM dogs ORDER BY id DESC LIMIT 1').flatten[0]
		self
	end

	def update
		DB[:conn].execute('UPDATE dogs SET name = ?, breed = ?;', self.name, self.breed)
	end

end