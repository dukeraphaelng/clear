macro __generate_from_json_methods__
  COLUMNS

  struct Assigner
    include JSON::Serializable

    {% for name, settings in COLUMNS %}
      getter {{name.id}} : {{settings[:type]}}?
    {% end %}

    def new_with_json
      generate_from_json({{@type}}.new) # Loop through instance variables and assign to the newly created orm instance
    end

    def update_with_json(to_update_model)
      generate_from_json(to_update_model) # Loop through instance variables and assign to the orm instance you are updating
    end

    macro finished
      private def generate_from_json(model)
        {% for name, settings in COLUMNS %}
          model.{{name.id}} = @{{name.id}}.not_nil! unless @{{name.id}}.nil?
        {% end %}

        model
      end
    end
  end

  # # Usage

  def self.pure_from_json(string_or_io)
    Assigner.from_json(string_or_io)
  end

  def self.new_from_json(string_or_io)
    Assigner.from_json(string_or_io).new_with_json
  end

  def self.update_from_json(model, string_or_io)
    Assigner.from_json(string_or_io).update_with_json(model)
  end
end

module Clear::Model::ClassMethods
  macro included # When included into Model
    macro included # When included into final Model
      macro inherited #Polymorphism
        macro finished
          __generate_from_json_methods__
        end
      end

      macro finished
        __generate_from_json_methods__
      end
    end
  end
end
