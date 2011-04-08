class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username

      t.database_authenticatable :null => false
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      t.lockable
      t.token_authenticatable
      t.timestamps
    end
  end
  
  def self.down
    drop_table :users
  end
end
