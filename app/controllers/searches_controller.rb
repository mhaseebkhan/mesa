class SearchesController < ApplicationController
  before_action :set_search, only: [:show, :edit, :update, :destroy]

  # GET /searches
  # GET /searches.json
  def index
   # @searches = Search.all
  end

  # GET /searches/1
  # GET /searches/1.json
  def show
  end

  # GET /searches/new
  def new
    @search = Search.new
  end

  # GET /searches/1/edit
  def edit
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = Search.new(search_params)

    respond_to do |format|
      if @search.save
        format.html { redirect_to @search, notice: 'Search was successfully created.' }
        format.json { render :show, status: :created, location: @search }
      else
        format.html { render :new }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /searches/1
  # PATCH/PUT /searches/1.json
  def update
    respond_to do |format|
      if @search.update(search_params)
        format.html { redirect_to @search, notice: 'Search was successfully updated.' }
        format.json { render :show, status: :ok, location: @search }
      else
        format.html { render :edit }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search.destroy
    respond_to do |format|
      format.html { redirect_to searches_url, notice: 'Search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def search_keys_for_chair
	search_user
	@mesa_id = params[:mesa_id]
        render partial: '/searches/searched_users_for_chair' , layout: false 
  end

  def search_keys
	search_user
        render partial: '/searches/searched_users' , layout: false 
  end

 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search
      @search = Search.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params[:search]
    end

    def search_user
    search_keys = params[:search_keys]
	searched_users = Array.new
        @users_array = Array.new
        if search_keys
		search_keys.each do |key|
			# search in tags
				tags = Tag.find_by_name(key)
				searched_users << tags.users if tags
			# search  in skills
				skills = Skill.find_by_name(key)
				searched_users << skills.users if skills
			# search in name
				searched_users.flatten!
				users = User.find_by_name(key)
				searched_users << users if users
		end
		unless searched_users.empty?
			searched_users.uniq!  
                	searched_users.collect {|user| @users_array << user.get_primary_info(user.id)}
		end
	end
    end
end
