class NormalizeNewFaceKind < ActiveRecord::Migration
  def up
    Item.where(kind: "New face").update_all(kind: NewFace.name)
  end
end
