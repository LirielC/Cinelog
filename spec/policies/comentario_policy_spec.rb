require 'rails_helper'

RSpec.describe ComentarioPolicy do
  let(:autor) { create(:usuario) }
  let(:outro) { create(:usuario) }
  let(:admin) { create(:usuario, :admin) }
  let(:moderador) { create(:usuario, :moderador) }
  let(:filme) { create(:filme, usuario: autor) }
  let(:comentario) { create(:comentario, filme: filme, usuario: autor) }
  let(:comentario_anonimo) { create(:comentario, filme: filme, usuario: nil) }

  subject { described_class }

  # ============================================
  # CREATE
  # ============================================
  permissions :create? do
    it 'permite usuário autenticado' do
      expect(subject).to permit(autor, comentario)
    end

    it 'permite visitante anônimo' do
      expect(subject).to permit(nil, comentario)
    end
  end

  # ============================================
  # DESTROY
  # ============================================
  permissions :destroy? do
    it 'permite admin deletar qualquer comentário' do
      expect(subject).to permit(admin, comentario)
    end

    it 'permite moderador deletar qualquer comentário' do
      expect(subject).to permit(moderador, comentario)
    end

    it 'permite autor deletar seu próprio comentário' do
      expect(subject).to permit(autor, comentario)
    end

    it 'nega outro usuário deletar comentário alheio' do
      expect(subject).not_to permit(outro, comentario)
    end

    it 'permite admin deletar comentário anônimo' do
      expect(subject).to permit(admin, comentario_anonimo)
    end

    it 'permite moderador deletar comentário anônimo' do
      expect(subject).to permit(moderador, comentario_anonimo)
    end

    it 'nega usuário comum deletar comentário anônimo' do
      expect(subject).not_to permit(outro, comentario_anonimo)
    end
  end

  # ============================================
  # UPDATE
  # ============================================
  permissions :update? do
    it 'nega qualquer atualização (comentários não são editáveis)' do
      expect(subject).not_to permit(autor, comentario)
      expect(subject).not_to permit(admin, comentario)
      expect(subject).not_to permit(moderador, comentario)
    end
  end
end
