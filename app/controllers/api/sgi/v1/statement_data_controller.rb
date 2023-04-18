# frozen_string_literal: true

class Api::Sgi::V1::StatementDataController < SgiApiController
  def show
    @piece = Pack::Piece.find(params[:id])
    
    if @piece
      render json: { success: true, piece: @piece, operations: @piece.detected_operations }, status: 200
    else
      render json: { success: false, message: 'Pièce introuvable' }, status: 404
    end
  end
end
