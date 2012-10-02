module StripedRails
  class Page < ActiveRecord::Base
    extend FriendlyId
    friendly_id :title, use: :slugged
    attr_accessible :title, :content, :menu_order
    validates_presence_of :title, :slug, :content, :menu_order
    validates_length_of :title, in: 1..255
    validates_numericality_of :menu_order
    scope :ordered, order('menu_order')
  end
end