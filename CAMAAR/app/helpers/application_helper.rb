# Módulo de helpers compartilhados da aplicação.
# Contém métodos auxiliares utilizados nas views.
module ApplicationHelper
    # Retorna a classe CSS baseada na taxa de resposta.
    #
    # @param taxa [Float] taxa de resposta em percentual (0-100)
    # @return [String] classe CSS:
    #   - "success" para taxas entre 80 e 100
    #   - "warning" para taxas entre 50 e 79.9
    #   - "danger" para taxas abaixo de 50
    def taxa_classe(taxa)
    case taxa
    when 80..100
      "success"
    when 50..79.9
      "warning"
    else
      "danger"
    end
  end
end
