class BoatsController < ApplicationController
  before_action :set_boat, only: [:show, :edit, :update, :destroy]

  # GET /boats
  # GET /boats.json
  def index
    if !params.include?(:city)
      @boats = Boat.geocoded
    elsif params[:location] == "" && params[:start_date] == ""
      @boats = Boat.geocoded
    else
      @boats = search(params)
    end
###
    #Boat.geocoded # returns boats with coordinates

    @markers = Boat.geocoded.map do |boat|
      {
        lat: boat.latitude,
        lng: boat.longitude,
        infoWindow: render_to_string(partial: "info_window", locals: { boat: boat }),
        image_url: helpers.asset_url("http://res.cloudinary.com/majel45/image/upload/c_fill,h_50,w_50/#{boat.photo.key}")
      }
    end
  end

  def search(params)
   boats = Boat.near(params[:location], params[:distance])
   boats.select { |boat| boat.capacity >= params[:guests].to_i && boat.available?(params[:start_date], params[:end_date]) }
  end

  # GET /boats/1
  # GET /boats/1.json
  def show
  end

  # GET /boats/new
  def new
    @boat = Boat.new
  end

  # GET /boats/1/edit
  def edit
  end

  # POST /boats
  # POST /boats.json
  def create
    @boat = Boat.new(boat_params)
    @boat.user = current_user

    respond_to do |format|
      if @boat.save
        format.html { redirect_to @boat, notice: 'Boat was successfully created.' }
        format.json { render :show, status: :created, location: @boat }
      else
        format.html { render :new }
        format.json { render json: @boat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /boats/1
  # PATCH/PUT /boats/1.json
  def update
    respond_to do |format|
      if @boat.update(boat_params)
        format.html { redirect_to @boat, notice: 'Boat was successfully updated.' }
        format.json { render :show, status: :ok, location: @boat }
      else
        format.html { render :edit }
        format.json { render json: @boat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boats/1
  # DELETE /boats/1.json
  def destroy
    @boat.destroy
    respond_to do |format|
      format.html { redirect_to boats_url, notice: 'Boat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_boat
      @boat = Boat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def boat_params
      params.require(:boat).permit(:user_id_id, :location, :capacity, :description, :price, :photo)
    end
end
