class Photo < ActiveRecord::Base
  extend Ext::GroupFor

  ajaxful_rateable :stars => 5, :cache_column => :rating_average

  belongs_to :album
  has_many :photo_tags, :dependent => :destroy
  has_many :tags, :through => :photo_tags
  
  mount_uploader :attachment, FileUploader

  before_create :exif_read
  before_update :exif_write
  after_create :set_title

  attr_accessor :tag_list

  scope :visible, where(:public => true)
  scope :untouched, :conditions => "photos.description IS NULL AND photos.id NOT IN ( SELECT photo_id FROM photo_tags)", :include => :album 
  scope :previous, lambda { |p,a| { :conditions => ["id < :id AND album_Id = :album ", { :id => p, :album => a } ], :limit => 1, :order => "id DESC"} }
  scope :next, lambda { |p,a| { :conditions => ["id > :id AND album_Id = :album ", { :id => p, :album => a } ], :limit => 1, :order => "id ASC"} }

  def to_param
    "#{id}-#{title.parameterize}"
  end
  
  def tag(title)
    return if self.tags.collect{|tag|tag.title}.include?( title )
    self.photo_tags.create(:tag => Tag.find_or_create_by_title( :title => title) )
    self.reload
  end
  
  def untag(title)
    return if !self.tags.collect{|tag|tag.title}.include?( title )
    # perhaps not the best way but it finds the correct PhotoTag and deletes it
    self.photo_tags.select{|photo_tag|
      photo_tag.tag.title == title
    }.each {|photo_tag|photo_tag.destroy}
    self.reload
  end

  def tag_list
    return self.tags.order('title').map{ |t| t.title }.sort.join(" ")
  end

  def tag_list=(tags)
    ts = Array.new
    tags.split(" ").each do |tag|
      ts.push( Tag.find_or_create_by_title( :title => tag.downcase) )
    end
    self.tags = ts
  end

  def _delete
    0
  end
  

  private

  def set_title
    a=self.attachment.file.basename
    update_attribute(:title, a.titleize)
    self.title = self.attachment.file.basename.titleize unless self.title
  end

  def exif_read
    photo = MiniExiftool.new(self.attachment.file.file)
    self.longitude = photo.GPSLongitude if self.longitude.nil?
    self.latitude = photo.GPSLatitude if self.latitude.nil?
    self.title = photo.DocumentName if self.title.nil?
    self.description = photo.ImageDescription if self.description.nil? && photo.ImageDescription != 'Exif_JPEG_PICTURE'
    self.tag_list = (self.tags.empty? ? "" : self.album.tag_list) + " " + (photo.Keywords.nil? ? "" : photo.Keywords.to_a.map { |tag| tag.gsub(" ", "_") }.join(" "))
  end
  
  def exif_write
    # should only write if tags are changed as images can be large and thus ExifTool will take a while to write to the file
    photo = MiniExiftool.new(self.attachment.file.file)
    photo.GPSLongitude = self.longitude
    photo.GPSLatitude = self.latitude
    photo.DocumentName = self.title
    photo.ImageDescription = self.description
    photo.Keywords = self.tags
    photo.save
  end

end
