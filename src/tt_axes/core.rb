#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
begin
  require 'TT_Lib2/core.rb'
rescue LoadError => e
  module TT
    if @lib2_update.nil?
      url = 'http://www.thomthom.net/software/sketchup/tt_lib2/errors/not-installed'
      options = {
        :dialog_title => 'TT_Lib² Not Installed',
        :scrollable => false, :resizable => false, :left => 200, :top => 200
      }
      w = UI::WebDialog.new(options)
      w.set_size(500, 300)
      w.set_url("#{url}?plugin=#{File.basename(__FILE__)}")
      w.show
      @lib2_update = w
    end
  end
end


if defined?(TT::Lib) && TT::Lib.compatible?('2.7.0', TT::Plugins::AxesTools::PLUGIN_NAME)

module TT::Plugins::AxesTools

  @settings = TT::Settings.new(PLUGIN_ID)
  @settings.set_default(:x, 'Center')
  @settings.set_default(:y, 'Center')
  @settings.set_default(:z, 'Center')


  unless file_loaded?(__FILE__)
    menu = TT.menu('Plugins').add_submenu(PLUGIN_NAME)
    menu.add_item('Set Origin for Selected')   { self.set_origin_for_selected }
    menu.add_item('Set Origin for All Components and Groups')   { self.set_origin_for_all }
  end

  def self.set_origin_for_selected
    model = Sketchup.active_model

    definitions = []
    model.selection.each { |e|
      definitions << TT::Instance.definition(e) if TT::Instance.is?(e)
    }
    definitions.uniq!

    self.set_origin(model, definitions)
  end

  def self.set_origin_for_all
    model = Sketchup.active_model

    definitions = model.definitions.reject { |d| d.image? }

    self.set_origin(model, definitions)
  end

  # @param [Sketchup::Model] model
  # @param [Array<Sketchup::ComponentDefinition>] definitions
  def self.set_origin(model, definitions)
    prompts = ['X (Red): ', 'Y (Green): ', 'Z (Blue): ']
    defaults = [@settings[:x], @settings[:y], @settings[:z]]
    list = ['Left|Center|Right', 'Front|Center|Back', 'Top|Center|Bottom']
    result = UI.inputbox(prompts, defaults, list, 'Set Origin')
    return if result == false

    x, y, z = result
    @settings[:x] = x
    @settings[:y] = y
    @settings[:z] = z

    i = TT.const_get("BB_#{x.upcase}_#{y.upcase}_#{z.upcase}")
    TT::Model.start_operation('Set Component Origin')
    definitions.each { |d|
      begin
        pt = TT::Bounds.point(d.bounds, i)
        TT::Definition.set_origin(d, pt)
      rescue => error
        puts error.message
        puts error.backtrace.join("\n")
      end
    }
    model.commit_operation
  end


  ### DEBUG ### ----------------------------------------------------------------

  # @note Debug method to reload the plugin.
  #
  # @example
  #   TT::Plugins::AxesTools.reload
  #
  # @param [Boolean] tt_lib Reloads TT_Lib2 if +true+.
  #
  # @return [Integer] Number of files reloaded.
  def self.reload(tt_lib = false)
    original_verbose = $VERBOSE
    $VERBOSE = nil
    TT::Lib.reload if tt_lib
    load __FILE__
    if defined?(PATH) && File.exist?(PATH)
      x = Dir.glob(File.join(PATH, '*.rb')).each { |file|
        load file
      }
      x.length + 1
    else
      1
    end
  ensure
    $VERBOSE = original_verbose
  end

end # module

end # if TT_Lib

file_loaded(__FILE__)
