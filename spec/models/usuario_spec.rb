require 'rails_helper'

RSpec.describe Usuario, type: :model do
  # ============================================
  # ASSOCIAÇÕES
  # ============================================
  describe 'associações' do
    it { should have_many(:filmes).dependent(:nullify) }
    it { should have_many(:comentarios).dependent(:nullify) }
  end

  # ============================================
  # VALIDAÇÕES
  # ============================================
  describe 'validações' do
    subject { build(:usuario) }

    it { should validate_presence_of(:nome) }
    it { should validate_presence_of(:email) }
    
    it 'valida unicidade do email' do
      create(:usuario, email: 'teste@example.com')
      usuario_duplicado = build(:usuario, email: 'teste@example.com')
      expect(usuario_duplicado).not_to be_valid
      expect(usuario_duplicado.errors[:email]).to be_present
    end

    it 'aceita email válido' do
      usuario = build(:usuario, email: 'valido@example.com')
      expect(usuario).to be_valid
    end

    it 'rejeita email inválido' do
      usuario = build(:usuario, email: 'email_invalido')
      expect(usuario).not_to be_valid
    end
  end

  # ============================================
  # ENUM PAPEL
  # ============================================
  describe 'enum papel' do
    it 'define papéis corretamente' do
      expect(Usuario.new).to respond_to(:papel)
      expect(Usuario.new).to respond_to(:usuario?)
      expect(Usuario.new).to respond_to(:moderador?)
      expect(Usuario.new).to respond_to(:admin?)
    end

    it 'permite criar usuário com papel usuario' do
      usuario = create(:usuario, papel: 'usuario')
      expect(usuario.papel).to eq('usuario')
    end

    it 'permite criar usuário com papel admin' do
      admin = create(:usuario, :admin)
      expect(admin.papel).to eq('admin')
    end

    it 'permite criar usuário com papel moderador' do
      moderador = create(:usuario, :moderador)
      expect(moderador.papel).to eq('moderador')
    end
  end

  # ============================================
  # MÉTODOS
  # ============================================
  describe '#admin?' do
    it 'retorna true para usuário admin' do
      admin = create(:usuario, :admin)
      expect(admin.admin?).to be true
    end

    it 'retorna false para usuário comum' do
      usuario = create(:usuario)
      expect(usuario.admin?).to be false
    end

    it 'retorna false para moderador' do
      moderador = create(:usuario, :moderador)
      expect(moderador.admin?).to be false
    end
  end

  describe '#moderador?' do
    it 'retorna true para moderador' do
      moderador = create(:usuario, :moderador)
      expect(moderador.moderador?).to be true
    end

    it 'retorna false para usuário comum' do
      usuario = create(:usuario)
      expect(usuario.moderador?).to be false
    end

    it 'retorna false para admin' do
      admin = create(:usuario, :admin)
      expect(admin.moderador?).to be false
    end
  end

  # ============================================
  # DEVISE
  # ============================================
  describe 'Devise' do
    it 'requer senha com no mínimo 6 caracteres' do
      usuario = build(:usuario, password: '123', password_confirmation: '123')
      expect(usuario).not_to be_valid
      expect(usuario.errors[:password]).to be_present
    end

    it 'requer confirmação de senha' do
      usuario = build(:usuario, password: 'senha123', password_confirmation: 'senha456')
      expect(usuario).not_to be_valid
      expect(usuario.errors[:password_confirmation]).to be_present
    end

    it 'autentica com credenciais válidas' do
      usuario = create(:usuario, email: 'teste@example.com', password: 'senha123', password_confirmation: 'senha123')
      expect(Usuario.find_for_database_authentication(email: 'teste@example.com')).to eq(usuario)
    end
  end
end
