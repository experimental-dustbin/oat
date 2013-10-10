require File.expand_path('../cloudformation', File.dirname(__FILE__))
require File.expand_path('./compilercommons', File.dirname(__FILE__))

class BoxServersCompiler < CompilerCommons

  attr_reader :boxes

  ##
  # Same initialization strategy as all the other compilers.

  def initialize(dsl_string, os_connector)
    super(dsl_string)
    @os_connector = os_connector
    initialize_components
  end

  ##
  # We need to create a +ServerComponent+ instance for each box definition.

  def initialize_components
    raise StandardError, "Boxes are already initialized." if @boxes
    if ast.boxes.nil?
      @boxes = []
    else
      @boxes = ast.boxes.value.map do |box_def|
        pool_data = component_data_hash(box_def, defaults_hash['security-groups'])
        vm_spec = box_def.vm_spec
        box_components = (1..vm_spec.count.value).map do |vm_index|
          box_component = ServerComponent.new("#{vm_spec.name}-#{vm_index}",
           defaults_hash['ssh-key-name'], defaults_hash['pem-file'],
           @os_connector, pool_data)
        end
      end.flatten
    end
  end

end