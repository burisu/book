class CreateBasis < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    create_table :user_sessions do |t|
      t.timestamps
    end

    create_table :groups do |t|
      t.string :name
      t.timestamps
    end

    create_table :labels do |t|
      t.string :name
      t.string :description
      t.timestamps
    end

    create_table :tags do |t|
      t.belongs_to :label
      t.belongs_to :tagged, :polymorphic => true
      t.timestamps
    end

    create_table :event_natures do |t|
    end

    create_table :events do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

    create_table : do |t|
    end

  end
end
