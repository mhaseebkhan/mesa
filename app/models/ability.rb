class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
      user ||= User.new # guest user (not logged in)
      case user.role?
      when ROLE_MASTER
        can :manage, :all
	can :delete_inactive_users, User
        cannot :view_pending_mesas, :all
      when ROLE_ADMIN
       	can :manage, :all
        cannot :view_pending_mesas, :all
      when ROLE_LEADER
	can :manage, :all
	cannot :view_pending_mesas, :all
	cannot :view_others_mesas, :all
      else
	cannot :manage, :all
	cannot :delete_inactive_users, User
	#user is common
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
