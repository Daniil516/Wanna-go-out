class SubscriptionsController < ApplicationController
  # Задаем родительский event для подписки
  before_action :set_event, only: [:create, :destroy]
  # Задаем подписку, которую юзер хочет удалить
  before_action :set_subscription, only: [:destroy]

  # POST /subscriptions or /subscriptions.json
  def create
    # Болванка для новой подписки
    @new_subscription = @event.subscriptions.build(subscription_params)
    @new_subscription.user = current_user

    if check_captcha(@new_subscription) && @new_subscription.save
      SubscriptionNotificationJob.perform_later(@new_subscription)
      # Если сохранилась, редиректим на страницу самого события
      redirect_to @event, notice: I18n.t('controllers.subscriptions.created')
    else
      # если ошибки — рендерим шаблон события
      render 'events/show', alert: I18n.t('controllers.subscriptions.error')
    end
  end

  # DELETE /subscriptions/1 or /subscriptions/1.json
  def destroy
    message = {notice: I18n.t('controllers.subscriptions.destroyed')}
    if current_user_can_edit?(@subscription)
      @subscription.destroy
    else
      message = {alert: I18n.t('controllers.subscriptions.error')}
    end

    redirect_to @event, message
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = @event.subscriptions.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def check_captcha(model)
    signed_in? || verify_recaptcha(model: model)
  end

  # Only allow a list of trusted parameters through.
  def subscription_params
    # .fetch разрешает в params отсутствие ключа :subscription
    params.fetch(:subscription, {}).permit(:user_email, :user_name)
  end
end
