class CreateListenerStates < ActiveRecord::Migration[8.0]
  def change
    create_table :listener_states do |t|
      t.boolean :running

      t.timestamps
    end
  end
end
