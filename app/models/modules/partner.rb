class Modules::Partner
  include Mongoid::Document

  field :name, type: String
  field :url, type: String
  field :order_logo, type: Integer
  field :category, type: String
  field :publish_on, type: Mongoid::Boolean

  scope :by_category, -> (type) { where(category: type) }
  scope :get_publish_partners, -> { where(publish_on: true) }

  before_create :set_order_logo

  validates_presence_of :name
  validates_presence_of :logo, on: :create

  mount_uploader :logo, PartnerLogoUploader
  skip_callback :update, :store_previous_model_for_logo

  # def self.get_publish_partners
  #   where(publish_on: true).order(order_logo: :desc)
  # end

  def set_order_logo
    count = Modules::Partner.count
    self.order_logo = count + 1
  end
end
