class DeactivatedReportsController < ApplicationController
  include Search
  rescue_from Pagy::OverflowError, with: :redirect_to_last_page
  rescue_from Pagy::VariableError, with: :redirect_to_last_page

  def index
    @search_page = :admin_deactivated_report
    get_search_values @search_page
    get_search_categories @search_page
    @search_submit_path = deactivated_reports_path

    if params[:commit] == 'Clear'
      self.set_submit_fields('clear', @search_page)
      @pagy, @deactivated_reports = pagy(Report.order('created_at DESC').where.not(active_status: 0), items: 10, size: [1,0,0,1])
    elsif params[:commit] == 'Search Dates' && params[:admin_deactivated_report_start_date].present? && params[:admin_deactivated_report_end_date].present? && params[:admin_deactivated_report_start_date] <= params[:admin_deactivated_report_end_date]
      self.set_submit_fields('dates', @search_page)
      @pagy, @deactivated_reports = pagy(Report.order('created_at DESC').search_dates(session[:admin_deactivated_report_start_date], session[:admin_deactivated_report_end_date]).where.not(active_status: 0), items: 10, size: [1,0,0,1])
    elsif params[:commit] == 'Search Dates' && ((!params[:admin_deactivated_report_start_date].present? || !params[:admin_deactivated_report_end_date].present?) || params[:admin_deactivated_report_start_date] > params[:admin_deactivated_report_end_date])
      @invalid_date = true
    else
      self.set_submit_fields('attribute', @search_page)
      @pagy, @deactivated_reports = pagy(Report.order('created_at DESC').search(session[:admin_deactivated_report_search_type], session[:admin_deactivated_report_search_term]).where.not(active_status: 0), items: 10, size: [1,0,0,1])
    end

    session[:admin_deactivated_report_search_radio_value] == 'Dates' ? self.set_radio_div('dates') : self.set_radio_div('attribute')
  end

  private
  # Redirects to the last page when exception thrown
  def redirect_to_last_page(exception)
      redirect_to url_for(page: exception.pagy.last)
  end

end
