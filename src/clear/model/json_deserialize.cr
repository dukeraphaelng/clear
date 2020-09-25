# This module declare all the methods and macro related to deserializing json in `Clear::Model`
module Clear::Model::JSONDeserialize
  macro included
    macro included # When included into Model
      macro inherited #Polymorphism
        macro finished
          columns_to_instance_vars
        end
      end

      macro finished
        columns_to_instance_vars
      end
    end
  end
end

# Used internally to deserialise json
macro columns_to_instance_vars
  # :nodoc:
  struct Assigner
    include JSON::Serializable

    {% for name, settings in COLUMNS %}
      @[JSON::Field(presence: true)]
      getter {{name.id}} : {{settings[:type]}} {% unless settings[:type].resolve.nilable? %} | Nil {% end %}
      
      @[JSON::Field(ignore: true)]
      getter? {{name.id}}_present : Bool
    {% end %}

    # Create a new empty model and fill the columns with object's instance variables
    def create(permit, mass_assignment)
      assign_columns({{@type}}.new, permit, mass_assignment)
    end

    # Update the inputted model and assign the columns with object's instance variables
    def update(model, permit, mass_assignment)
      assign_columns(model, permit, mass_assignment)
    end

    macro finished
      # Assign properties to the model inputted with object's instance variables
      protected def assign_columns(model, permit : Enumerable(String | Symbol), mass_assignment : Bool)
        {% for name, settings in COLUMNS %}
          if self.{{name.id}}_present? && ((mass_assignment && permit.size == 0) ? true : (permit.any? { |p| p == {{name.stringify.id}} || p == {{name.id.symbolize}} }))
            %value = self.{{name.id}}
            {% if settings[:type].resolve.nilable? %}
              model.{{name.id}} = %value
            {% else %}
              model.{{name.id}} = %value unless %value.nil?
            {% end %}
          end
        {% end %}

        model
      end
    end
  end

  # Create a new empty model and fill the columns from json
  #
  # Returns the new model
  def self.from_json(string_or_io : String | IO, permit : Enumerable(String | Symbol) = [] of String | Symbol, mass_assignment : Bool = true)
    Assigner.from_json(string_or_io).create(permit, mass_assignment)
  end

  # Create a new model from json and save it. Returns the model.
  #
  # The model may not be saved due to validation failure;
  # check the returned model `errors?` and `persisted?` flags.
  def self.create_from_json(string_or_io : String | IO, permit : Enumerable(String | Symbol) = [] of String | Symbol, mass_assignment : Bool = true)
    mdl = self.from_json(string_or_io, permit, mass_assignment)
    mdl.save
    mdl
  end

  # Create a new model from json and save it. Returns the model.
  #
  # Returns the newly inserted model
  # Raises an exception if validation failed during the saving process.
  def self.create_from_json!(string_or_io : String | IO, permit : Enumerable(String | Symbol) = [] of String | Symbol, mass_assignment : Bool = true)
    self.from_json(string_or_io, permit, mass_assignment).save!
  end

  # Set the fields from json passed as argument
  def set_from_json(string_or_io : String | IO, permit : Enumerable(String | Symbol) = [] of String | Symbol, mass_assignment : Bool = true)
    Assigner.from_json(string_or_io).update(self, permit, mass_assignment)
  end

  # Set the fields from json passed as argument and call `save` on the object
  def update_from_json(string_or_io : String | IO, permit : Enumerable(String | Symbol) = [] of String | Symbol, mass_assignment : Bool = true)
    mdl = set_from_json(string_or_io, permit, mass_assignment)
    mdl.save
    mdl
  end

  # Set the fields from json passed as argument and call `save!` on the object
  def update_from_json!(string_or_io : String | IO, permit : Enumerable(String | Symbol) = [] of String | Symbol, mass_assignment : Bool = true)
    set_from_json(string_or_io, permit, mass_assignment).save!
  end
end
