// Verificador de duplicatas de filmes em tempo real
document.addEventListener('DOMContentLoaded', function() {
  const tituloInput = document.getElementById('filme_titulo');
  const anoInput = document.getElementById('filme_ano_lancamento');
  
  if (!tituloInput) return; // Não está na página de formulário
  
  // Criar elemento para mostrar avisos
  const avisoContainer = document.createElement('div');
  avisoContainer.id = 'aviso-duplicatas';
  avisoContainer.className = 'aviso-duplicatas';
  avisoContainer.style.display = 'none';
  tituloInput.parentNode.insertBefore(avisoContainer, tituloInput.nextSibling);
  
  let timeoutId;
  
  // Função para verificar duplicatas
  function verificarDuplicatas() {
    const titulo = tituloInput.value.trim();
    const ano = anoInput ? anoInput.value : null;
    
    if (titulo.length < 3) {
      avisoContainer.style.display = 'none';
      return;
    }
    
    const params = new URLSearchParams({
      titulo: titulo
    });
    
    if (ano) {
      params.append('ano_lancamento', ano);
    }
    
    fetch(`/filmes/verificar_duplicata?${params}`, {
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.encontrou_duplicatas && data.filmes.length > 0) {
        mostrarAviso(data.filmes);
      } else {
        avisoContainer.style.display = 'none';
      }
    })
    .catch(error => {
      console.error('Erro ao verificar duplicatas:', error);
    });
  }
  
  // Função para mostrar aviso de duplicatas
  function mostrarAviso(filmes) {
    let html = `
      <div class="alert alert-warning duplicata-warning">
        <strong>⚠️ Atenção:</strong> Encontramos ${filmes.length} filme(s) similar(es):
        <ul class="lista-duplicatas">
    `;
    
    filmes.forEach(filme => {
      html += `
        <li>
          <a href="${filme.url}" target="_blank" class="link-duplicata">
            <strong>${filme.titulo}</strong> (${filme.ano_lancamento || 'Ano não informado'})
            ${filme.diretor ? ' - Dir: ' + filme.diretor : ''}
          </a>
        </li>
      `;
    });
    
    html += `
        </ul>
        <small>Verifique se não é o mesmo filme antes de continuar.</small>
      </div>
    `;
    
    avisoContainer.innerHTML = html;
    avisoContainer.style.display = 'block';
  }
  
  // Event listeners com debounce
  tituloInput.addEventListener('input', function() {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(verificarDuplicatas, 800); // 800ms de delay
  });
  
  if (anoInput) {
    anoInput.addEventListener('change', verificarDuplicatas);
  }
});
