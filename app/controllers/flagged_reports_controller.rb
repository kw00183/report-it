class FlaggedReportsController < ApplicationController
    rescue_from Pagy::OverflowError, with: :redirect_to_last_page
    rescue_from Pagy::VariableError, with: :redirect_to_last_page
    before_action :get_search_values, only: [:index]

    def index
      @form_submit_path = '/flagged-reports'
      @admin_flagged_search_type = session[:admin_flagged_search_type]
      @admin_flagged_search_term = session[:admin_flagged_search_term]
      @pagy, @flagged_reports = pagy(Report.order('created_at DESC').search(session[:admin_flagged_search_type], session[:admin_flagged_search_term]).where(status: "Flagged", active_status: "active"), items: 10, size: [1,0,0,1])
    end

    private
    # Redirects to the last page when exception thrown
    def redirect_to_last_page(exception)
        redirect_to url_for(page: exception.pagy.last)
    end

    # Sets the search type and term for the session using the search parameters
    def get_search_values
      if params[:admin_flagged_search_term]
        session[:admin_flagged_search_type] = params[:admin_flagged_search_type]
        session[:admin_flagged_search_term] = params[:admin_flagged_search_term]
      end
    end

end
