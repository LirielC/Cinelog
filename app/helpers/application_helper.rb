module ApplicationHelper
  include Pagy::Frontend
  
  # Helper customizado para paginação com estilo
  def pagy_nav_custom(pagy)
    html = %(<nav class="pagination-custom" role="navigation" aria-label="Paginação"><ul class="pagination">)

    # Botão Previous
    if pagy.prev
      html += %(<li class="page-item prev"><a href="?page=#{pagy.prev}" class="page-link">‹ Anterior</a></li>)
    else
      html += %(<li class="page-item prev disabled"><span class="page-link">‹ Anterior</span></li>)
    end

    # Números das páginas (1 até last)
    (1..pagy.last).each do |page|
      if page == pagy.page
        html += %(<li class="page-item active"><span class="page-link">#{page}</span></li>)
      else
        html += %(<li class="page-item"><a href="?page=#{page}" class="page-link">#{page}</a></li>)
      end
    end

    # Botão Next
    if pagy.next
      html += %(<li class="page-item next"><a href="?page=#{pagy.next}" class="page-link">Próxima ›</a></li>)
    else
      html += %(<li class="page-item next disabled"><span class="page-link">Próxima ›</span></li>)
    end

    html += %(</ul></nav>)
    html.html_safe
  end
  
  # Exibe o título do filme no idioma atual
  def exibir_titulo(filme)
    filme.titulo_traduzido(I18n.locale)
  end
  
  # Exibe a sinopse do filme no idioma atual
  def exibir_sinopse(filme, opcoes = {})
    sinopse = filme.sinopse_traduzida(I18n.locale)
    return '' if sinopse.blank?
    
    if opcoes[:truncate]
      truncate(sinopse, length: opcoes[:truncate])
    else
      sinopse
    end
  end
end
