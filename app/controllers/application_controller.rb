class ApplicationController < ActionController::Base
    def after_sign_in_path_for(resource)
        if current_user.is_resident?
            resident_path
        else
            root_path
        end
      end
end
