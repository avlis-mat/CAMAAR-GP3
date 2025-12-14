module ApplicationHelper
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
