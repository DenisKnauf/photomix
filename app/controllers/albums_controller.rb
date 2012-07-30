class AlbumsController < ApplicationController
  before_filter :check_public_access
  skip_before_filter :authenticate_user!, :only => [:index, :show]
  
  def index
    add_breadcrumb t('activerecord.models.album.popular'), collections_path, :title => t('activerecord.models.album.popular')
    add_breadcrumb t('activerecord.actions.create', :model => I18n.t('activerecord.models.album.single')), new_album_path,
                   :title => t('activerecord.actions.create', :model => I18n.t('activerecord.models.album.single')),
                   :li_icon => 'icon-plus-sign'

    if params[:tag_id]
      @albums = Album.where(:conditions => [ "id IN ( SELECT DISTINCT photos.album_id FROM photos WHERE photos.id IN ( SELECT photo_id FROM photo_tags WHERE photo_tags.tag_id = :q) )", { :q => Tag.find( params[:tag_id] ).id } ]).order('title')
    elsif params[:q]
      #search = params[:q]
      #search = search.split("AND").map{|q|q.strip}
      #@albums = Album.find(:all, :select => 'DISTINCT albums.id, albums.title', :limit => 20, :conditions => {  :tags => {:title => search}}, :joins => 'LEFT OUTER JOIN photos ON albums.id = photos.album_id LEFT OUTER JOIN photo_tags ON photos.id = photo_tags.photo_id LEFT OUTER JOIN tags ON photo_tags.tag_id = tags.id', :order => "albums.title ASC" )
      #@albums = Album.find(:all, :select => 'DISTINCT album_id', :conditions => [ "title LIKE :q OR description LIKE :q OR id IN ( SELECT DISTINCT photos.album_id FROM photos WHERE photos.description LIKE :q OR photos.title LIKE :q OR photos.id IN ( SELECT photo_id FROM photo_tags LEFT OUTER JOIN tags ON photo_tags.tag_id = tags.id WHERE tags.title LIKE :q) )", { :q => '%' + params[:q] + '%' } ], :order => 'title')
      params[:q].split(" AND ").each {|q|
        qphotos = Photo.find(:all, :select => 'DISTINCT album_id', :conditions => [ "description LIKE :q OR title LIKE :q OR id IN ( SELECT photo_id FROM photo_tags LEFT OUTER JOIN tags ON photo_tags.tag_id = tags.id WHERE tags.title LIKE :q)", { :q => '%' + q + '%' } ])
        qalbums = Album.find(:all, :conditions => ['title LIKE :q OR description LIKE :q OR id IN (:ids)', { :ids => qphotos.map{|p|p.album_id}, :q => '%' + q + '%'  }], :order => 'title' )
        if @albums
          @albums = @albums & qalbums
        else
          @albums = qalbums
        end
      }
    else
      @albums = Album.popular.page(@page).per(@per_page)
    end
    respond_to do |format|
      format.html
      format.json  { render :json => @albums }
      format.xml  { render :xml => @albums }
    end
  end

  def untouched
    @albums = Album.untouched()
    respond_to do |format|
      format.html
      format.json  { render :json => @albums }
      format.xml  { render :xml => @albums }
    end
  end
  
  def show
    @album = Album.find( params[:id])
    @photos = @album.photos.popular

    respond_to do |format|
      format.html
      format.json  { render :json => @album }
      format.xml  { render :xml => @album }
      format.pdf { render :pdf => @album.title }
    end
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new(params[:album])

    if @album.save
      flash[:notice] = "Album created! Now add some nice photos."
      if params[:collection_id]
        @album.collections << Collection.find( params[:collection_id] )
        redirect_to upload_collection_album_photos_path(params[:collection_id], @album )
      else
        redirect_to upload_album_photos_path( @album )
      end
    else
      render :action => :new
    end
  end

  def edit
    @album = Album.find( params[:id])
  end

  def update
    @album = Album.find( params[:id])
    if @album.update_attributes(params[:album])
      flash[:notice] = "Album updated!"
      if params[:collection_id]
        redirect_to collection_album_path(params[:collection_id], @album )
      else
        redirect_to @album
      end
    else
      render :action => :edit
    end
  end
  
  def destroy
    @album = Album.find( params[:id])
    if @album.destroy
      if params[:collection_id]
        redirect_to collection_path(params[:collection_id] )
      else
        redirect_to albums_path
      end
    else
      redirect_to @album
    end
  end

  def rate
    @album = Album.find(params[:id])
    @album.rate(params[:stars], current_user, params[:dimension])
    render :json => {:id => @album.wrapper_dom_id(params), :width => 125}
  end
  
end
