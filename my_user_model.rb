require 'sqlite3'

class User
   
    def self.initialize_db
        begin
            @db = SQLite3::Database.open "users.db"
            @db.execute "CREATE TABLE IF NOT EXISTS users
            (Id INTEGER PRIMARY KEY, 
            firstname TEXT,
            lastname TEXT,
            age INT,  
            password TEXT, 
            email TEXT)"
            
        rescue SQLite3::Exception => e 
            puts "Exception occurred"
            puts e
        end
    end

    def self.create(user_info)
        initialize_db()
        begin
          @db.execute "INSERT INTO users(firstname, lastname, age, password, email) VALUES(?, ?, ?, ?, ?)", [user_info]
          p get(@db.last_insert_row_id)
          return @db.last_insert_row_id
        rescue  SQLite3::Exception => e
          return nil
        end
      end
    
    
    def self.get(user_id)
        initialize_db()
        user = Hash.new()
        stm = @db.prepare("SELECT * FROM users WHERE rowid=?")
        stm.bind_params(user_id.to_i)
        rs = stm.execute.next
        if rs != nil
          stm.columns.each_with_index do |col, i|
            user[col] = rs[i]
          end
        end
        return user
        
    end 


    def self.all
        initialize_db()
        all_users = []
        stm = @db.prepare "SELECT * FROM users"
        rs = stm.execute
        rs.each do |row|
          user = Hash.new()
          stm.columns.each_with_index do |col, i|
            user[col] = row[i]
          end
          all_users.push(user)
        end
        return all_users
    end
  

    def self.update(user_id, attribute, value)
        initialize_db()
        stm = @db.prepare("UPDATE users SET " + attribute + "=? WHERE rowid=?")
        stm.bind_params(value, user_id.to_i)
        stm.execute
        return get(user_id)
      end
    
    def self.destroy(user_id)
        initialize_db
        stm = @db.prepare("DELETE FROM users WHERE rowid=?")
        stm.bind_params(user_id.to_i)
        stm.execute
    end

    def close
    @db.close if @db
  end

end




