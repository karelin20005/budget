require 'carrierwave/mongoid'
class Modules::Slider
  include Mongoid::Document

  after_update :reprocess_image, :if => :cropping?
  # before_save :set_sl_order
  scope :get_slider_by_order, -> {order("sl_order ASC")}


  validates :text,:sl_order, presence: true
  validates :sl_order, uniqueness: true
  validates :link, format: { with: /(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/,
                             message: I18n.t('activerecord.attributes.invalid.link') }, allow_blank: true

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  field :link, type: String
  field :text, type: String
  field :sl_order, type:Integer

  mount_uploader :img, SliderUploader

  skip_callback :update, :store_previous_model_for_img

  def profile_geometry
    img = MiniMagick::Image.open(self.img.path)
    @geometry = {:width => img[:width], :height => img[:height] }
  end

  def cropping?
    !crop_x.blank? and !crop_y.blank? and !crop_w.blank? and !crop_h.blank?
  end

  def delete_image_file!
    self.remove_img!;
  end

  def set_sl_order
    last_order = Modules::Slider.order("sl_order desc").limit(1).first
    unless last_order.nil?
      self.sl_order = last_order.sl_order + 1
    else
      self.sl_order = 1
    end

  end

  private

  def reprocess_image
    img1 = MiniMagick::Image.open(self.img.path)
    crop_params = "#{crop_w}x#{crop_h}+#{crop_x}+#{crop_y}"
    img1.crop(crop_params)
    img1.write(self.img.slider.path)
  end

end
