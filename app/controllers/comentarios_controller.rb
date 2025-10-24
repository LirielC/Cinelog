class ComentariosController < ApplicationController
  before_action :set_filme

  def create
    @comentario = @filme.comentarios.build(comentario_params)
    if usuario_signed_in?
      @comentario.usuario = current_usuario
      @comentario.nome_autor = current_usuario.nome if @comentario.nome_autor.blank?
    end

    if @comentario.save
      redirect_to @filme, notice: 'Comentário adicionado.'
    else
      redirect_to @filme, alert: 'Erro ao adicionar comentário.'
    end
  end

  def destroy
    @comentario = @filme.comentarios.find(params[:id])
    authorize @comentario # Usa a policy para verificar permissão
    
    @comentario.destroy
    redirect_to @filme, notice: 'Comentário removido.'
  rescue Pundit::NotAuthorizedError
    redirect_to @filme, alert: 'Você não tem permissão para remover este comentário.'
  end

  private

  def set_filme
    @filme = Filme.find(params[:filme_id])
  end

  def comentario_params
    params.require(:comentario).permit(:conteudo, :nome_autor)
  end
end
