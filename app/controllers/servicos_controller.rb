class ServicosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:tmdb_lookup]

  def tmdb_lookup
    titulo = params[:titulo]
    resultado = ServicoTmdb.buscar_por_titulo(titulo)
    if resultado[:erro]
      render json: { erro: resultado[:erro] }, status: :bad_request
    else
      render json: resultado
    end
  end
end
