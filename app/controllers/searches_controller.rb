class SearchesController < ApplicationController
  before_action :set_search, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  #load_and_authorize_resource 
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
	search_user(tags=true,skill=true,name=true)
	@mesa_id = params[:mesa_id]
        render partial: '/searches/searched_users_for_chair' , layout: false 
  end

  def search_keys
	search_user(tags=true,skill=true,name=true)
        render partial: '/searches/searched_users' , layout: false 
  end

  def search_by_name
	@users_array = Array.new
	unless params[:search_key] == ""
		@searched_user = params[:search_key]
		searched_users = Array.new
		users = User.where("name LIKE ?", "%#{params[:search_key]}%").all
		searched_users << users if users
		unconcious_users = UnconciousUser.where("name LIKE ?", "%#{params[:search_key]}%").all
		searched_users << unconcious_users if unconcious_users
		unless searched_users.empty?
				searched_users.flatten!.uniq!
		        	searched_users.collect {|user| @users_array << user.get_primary_info}
		end
	end
        render partial: '/searches/searched_editable_users' , layout: false 
  end

  def filter_users
	@searched_user = params[:search_string]
	@users_array = Array.new
	searched_users = Array.new
	if params[:user_role] == ROLE_UNCONCIOUS.to_s
		unconcious_users = UnconciousUser.all
        	searched_users << unconcious_users if unconcious_users
	else
		users = User.eager_load(:roles).where( 'roles.id = ?', params[:user_role])
		searched_users << users if users
	end
	unless searched_users.empty?
			searched_users.flatten!.uniq!
                	searched_users.collect {|user| @users_array << user.get_primary_info}
	end
	 render partial: '/searches/searched_editable_users' , layout: false 
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

    def search_user(user_tags,user_skills,user_name)
    search_keys = params[:search_keys]
	searched_users = Array.new
        @users_array = Array.new
        if search_keys
		search_keys.each do |key|
			# search in tags
				if user_tags
					tags = Tag.where("name LIKE ?","%#{key}%")
					tags.collect{|tag| searched_users << tag.users} unless tags.empty?
				end
			# search  in skills
				if user_skills
					skills = Skill.where("name LIKE ?","%#{key}%")
					skills.collect{|skill| searched_users << skill.users} unless skills.empty?
				end
			# search in name
				if user_name
					searched_users.flatten!
					users = User.where("name LIKE ?","%#{key}%").load
					searched_users << users unless users.empty?
					searched_users.flatten!
				end
				
		end
 		unless searched_users.empty?
			searched_users.uniq!  
                	searched_users.collect {|user| @users_array << user.get_primary_info}
		end
	end
    end
end
