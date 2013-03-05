class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_locale

  helper FastGettext::Translation
  include FastGettext::Translation

protected

  def current_city
    @current_city ||= begin
      if params[:city_id].present?
        City.find(params[:city_id])
      elsif cookies[:city_id].present?
        City.find(cookies[:city_id])
      else
        city = City.geolocate(request.remote_addr) || City.default
        cookies[:city_id] = city.id
        city
      end
    end
  end
  helper_method :current_city

  def load_locale
    I18n.locale = current_city.locale
  end

end
