# frozen_string_literal: true
class Admin::Tickets::MainController < BackController
  prepend_view_path('app/templates/back/tickets/views')

  # GET /admin/events
  def index
    @tickets = Ticket.search(search_terms(params[:ticket_contains])).order(sort_column => sort_direction).page(params[:page]).per(params[:per_page])
  end

  # GET /admin/events/:id
  def show
    # @event = Event.find(params[:id])

    # render layout: false
  end

  private

  def sort_column
    params[:sort] || 'id'
  end
  helper_method :sort_column

  def sort_direction
    params[:direction] || 'desc'
  end
  helper_method :sort_direction
  helper_method :sort_direction
end