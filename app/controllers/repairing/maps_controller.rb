class Repairing::MapsController < ApplicationController
  before_action :set_repairing_map, only: [:show, :edit, :update, :destroy]

  def search_addr
    @repairing_map = Repairing::Map.find(params[:id])

    @location = Geocoder.coordinates(params[:q])
    @location1 = Geocoder.coordinates(params[:q1]) unless params[:q1].empty? || params[:q] == params[:q1]
    # @location = [49.23531, 28.45757]
    # @location1 = [49.23644, 28.4703]

    respond_to do |format|
      if @location1
        @repair = @repairing_map.repairs.new(title: params[:q], coordinates: [@location, @location1], address: params[:q], address_to: params[:q1])
        @repair.save!

        format.json { render json: Repairing::GeojsonBuilder.build_repair(@repair) }
        # format.js { render :search_street }
      elsif @location
        @repair = @repairing_map.repairs.new(title: params[:q], coordinates: @location, address: params[:q])
        @repair.save!

        geoJson = []
        geoJson << Repairing::GeojsonBuilder.build_repair_point(@repair)
        format.json { render json: Repairing::GeojsonBuilder.build_repair_point(@repair) }
        # format.js { render :search_house }
      else
        format.js
      end
    end
  end

  def geo_json
    geoJson = []

    repairing_map = Repairing::Map.find(params[:id])

    repairing_map.repairs.each do |repair|
      geoJson << Repairing::GeojsonBuilder.build_repair(repair)
    end

    respond_to do |format|
      format.json { render json: geoJson}
    end
  end

  # GET /repairing/maps
  # GET /repairing/maps.json
  def index
    @repairing_maps = Repairing::Map.all
  end

  # GET /repairing/maps/1
  # GET /repairing/maps/1.json
  def show
  end

  # GET /repairing/maps/new
  def new
    @repairing_map = Repairing::Map.new
  end

  # GET /repairing/maps/1/edit
  def edit
  end

  # POST /repairing/maps
  # POST /repairing/maps.json
  def create
    @repairing_map = Repairing::Map.new(repairing_map_params)

    respond_to do |format|
      if @repairing_map.save
        format.html { redirect_to @repairing_map, notice: 'Map was successfully created.' }
        format.json { render :show, status: :created, location: @repairing_map }
      else
        format.html { render :new }
        format.json { render json: @repairing_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /repairing/maps/1
  # PATCH/PUT /repairing/maps/1.json
  def update
    respond_to do |format|
      if @repairing_map.update(repairing_map_params)
        format.html { redirect_to @repairing_map, notice: 'Map was successfully updated.' }
        format.json { render :show, status: :ok, location: @repairing_map }
      else
        format.html { render :edit }
        format.json { render json: @repairing_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repairing/maps/1
  # DELETE /repairing/maps/1.json
  def destroy
    @repairing_map.destroy
    respond_to do |format|
      format.html { redirect_to repairing_maps_url, notice: 'Map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_repairing_map
      @repairing_map = Repairing::Map.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def repairing_map_params
      params.require(:repairing_map).permit(:title, :town)
    end
end
