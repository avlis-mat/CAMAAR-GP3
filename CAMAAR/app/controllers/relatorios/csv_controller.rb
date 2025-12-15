require 'csv'

# Controller responsável pela geração de relatórios em formato CSV.
# Permite exportar respostas de formulários para análise externa.
# Apenas administradores podem acessar este controller.
class Relatorios::CsvController < ApplicationController
  before_action :require_login
  before_action :require_admin
  
  # Gera e envia relatório CSV de respostas de um formulário.
  # As respostas são anonimizadas (identificadas apenas como "Respondente N").
  #
  # @return [void]
  # @note Efeito colateral:
  #   - Gera arquivo CSV com respostas do formulário
  #   - Envia arquivo como download para o navegador
  def show
    @formulario = Formulario.find(params[:id])
    
    respond_to do |format|
      format.csv do
        csv_data = gerar_csv_relatorio
        
        send_data csv_data,
                  filename: "#{@formulario.titulo.parameterize}-#{Date.today}.csv",
                  type: 'text/csv; charset=utf-8; header=present',
                  disposition: 'attachment'
      end
    end
  end
  
  private
  
  # Gera o conteúdo CSV do relatório de respostas.
  #
  # @return [String] conteúdo CSV formatado
  # @note O CSV contém:
  #   - Headers: Respondente, Data/Hora e uma coluna por questão
  #   - Linhas: uma por usuário que respondeu, com respostas anonimizadas
  def gerar_csv_relatorio
    # Headers do CSV (anônimo)
    headers = ['Respondente', 'Data/Hora']
    
    @formulario.modelo.questoes.order(:ordem).each_with_index do |questao, index|
      # Truncar enunciado longo para o header
      headers << "Q#{index + 1}: #{questao.enunciado.truncate(50)}"
    end
    
    # Gerar CSV
    CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
      csv << headers
      
      # Agrupar respostas por usuário
      respostas_por_usuario = @formulario.respostas
                                         .includes(:usuario, :questao, :questao_opcao)
                                         .group_by(&:usuario_id)
      
      # Uma linha por usuário
      respostas_por_usuario.each_with_index do |(usuario_id, respostas), index|
        #usuario = respostas.first.usuario
        
        linha = [
          "Respondente #{index + 1}",
          respostas.first.respondido_em.strftime('%d/%m/%Y %H:%M')
        ]
        
        # Ordenar respostas pela ordem das questões
        respostas_ordenadas = respostas.sort_by { |r| r.questao.ordem }
        
        # Adicionar resposta de cada questão
        respostas_ordenadas.each do |resposta|
          if resposta.questao.tipo == 'dissertativa'
            # Texto da resposta dissertativa
            linha << (resposta.conteudo || '-')
          else
            # Texto da opção selecionada
            linha << (resposta.questao_opcao&.texto || '-')
          end
        end
        
        csv << linha
      end
    end
  end
end
