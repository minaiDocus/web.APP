class BaseMailer < ActionMailer::Base
  prepend_view_path "app/views/mailers"
end