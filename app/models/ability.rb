class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
      user ||= User.new # guest user (not logged in)
      case user.role?
      when ROLE_MASTER
        can :manage, :all
        can :view_pending_mesas, :all
      when ROLE_ADMIN
       	can :manage, [User,Mission]
	can :admin_users, :all
        can :view_others_mesas, :all #, Mission.others_mesa(1) do |mesa|
	    # puts mesa.inspect
#	end
        can :create_mesa, :all
      when ROLE_LEADER
	can :manage, Mission
	can :create_mesa, :all
      when ROLE_CURATOR
      else
	#user is common-flagger
      end
    # #  can :admin_users, :all
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
