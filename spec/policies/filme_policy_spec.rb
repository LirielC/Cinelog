require 'rails_helper'

RSpec.describe FilmePolicy do
  let(:autor) { create(:usuario) }
  let(:outro) { create(:usuario) }
  let(:admin) { create(:usuario, :admin) }
  let(:moderador) { create(:usuario, :moderador) }
  let(:filme) { create(:filme, usuario: autor) }

  subject { described_class }

  # ============================================
  # INDEX
  # ============================================
  permissions :index? do
    it 'permite qualquer usuário' do
      expect(subject).to permit(outro, Filme)
    end

    it 'permite visitante (nil)' do
      expect(subject).to permit(nil, Filme)
    end
  end

  # ============================================
  # SHOW
  # ============================================
  permissions :show? do
    it 'permite qualquer usuário' do
      expect(subject).to permit(outro, filme)
    end

    it 'permite visitante (nil)' do
      expect(subject).to permit(nil, filme)
    end
  end

  # ============================================
  # CREATE
  # ============================================
  permissions :create? do
    it 'permite usuário autenticado' do
      expect(subject).to permit(outro, Filme)
    end

    it 'nega visitante não autenticado' do
      expect(subject).not_to permit(nil, Filme)
    end
  end

  # ============================================
  # UPDATE
  # ============================================
  permissions :update? do
    it 'permite autor do filme' do
      expect(subject).to permit(autor, filme)
    end

    it 'permite admin' do
      expect(subject).to permit(admin, filme)
    end

    it 'permite moderador' do
      expect(subject).to permit(moderador, filme)
    end

    it 'nega outro usuário comum' do
      expect(subject).not_to permit(outro, filme)
    end

    it 'nega visitante não autenticado' do
      expect(subject).not_to permit(nil, filme)
    end
  end

  # ============================================
  # DESTROY
  # ============================================
  permissions :destroy? do
    it 'permite admin' do
      expect(subject).to permit(admin, filme)
    end

    it 'permite autor do filme' do
      expect(subject).to permit(autor, filme)
    end

    it 'nega moderador' do
      expect(subject).not_to permit(moderador, filme)
    end

    it 'nega outro usuário comum' do
      expect(subject).not_to permit(outro, filme)
    end

    it 'nega visitante não autenticado' do
      expect(subject).not_to permit(nil, filme)
    end
  end
end
