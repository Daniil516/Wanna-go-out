class EventPolicy < ApplicationPolicy
  def edit?
    destroy?
  end

  def update?
    destroy?
  end

  def destroy?
    @record.user == @user
  end

  def show?
    true#Я не знаю как вынести pincode_guard сюда :)
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
