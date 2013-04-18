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
      w = UI::WebDialog.new( options )
      w.set_size( 500, 300 )
      w.set_url( "#{url}?plugin=#{File.basename( __FILE__ )}" )
      w.show
      @lib2_update = w
    end
  end
end


#-------------------------------------------------------------------------------

if defined?( TT::Lib ) && TT::Lib.compatible?( '2.7.0', 'Axes Tools' )

module TT::Plugins::AxesTools  
  
  ### MODULE VARIABLES ### -----------------------------------------------------
  
  # Preference
  @settings = TT::Settings.new('TT_Axes_Tools')
  @settings.set_default(:x, 'Center')
  @settings.set_default(:y, 'Center')
  @settings.set_default(:z, 'Center')
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( __FILE__ )
    m = TT.menu('Plugins').add_submenu('Axes Tools')
    m.add_item('Set Origin')   { self.set_origin }
  end
  
  
  ### MAIN SCRIPT ### ----------------------------------------------------------
  
  
  def self.set_origin
    model = Sketchup.active_model
    
    # Prompt user for input
    prompts = ['X (Red): ', 'Y (Green): ', 'Z (Blue): ']
    defaults = [ @settings[:x], @settings[:y], @settings[:z] ]
    list = ['Left|Center|Right', 'Front|Center|Back', 'Top|Center|Bottom']
    result = UI.inputbox( prompts, defaults, list, 'Set Origin' )
    return if result == false
    
    x, y, z = result
    @settings[:x] = x
    @settings[:y] = y
    @settings[:z] = z

    bb_const = "TT::BB_#{x.upcase}_#{y.upcase}_#{z.upcase}"
    i = eval( bb_const )
    
    if model.selection.empty?
      definitions = model.definitions.reject { |d| d.image? }
    else
      definitions = []
      for e in model.selection
        definitions << TT::Instance.definition( e ) if TT::Instance.is?( e )
      end
      definitions.uniq!
    end
    
    TT::Model.start_operation('Set Insertion Point')
    for d in definitions
      begin
        pt = TT::Bounds.point( d.bounds, i )
        TT::Definition.set_origin( d, pt )
      rescue => error
        puts error.message
        puts error.backtrace.join("\n")
      end
    end
    model.commit_operation
  end
  
  
  ### DEBUG ### ----------------------------------------------------------------
  
  def self.axes
    t = Sketchup.active_model.selection[0].transformation
    puts "### AXES ###"
    puts "X: #{t.xaxis.inspect} - #{(t.xaxis == X_AXIS).inspect} - #{(t.xaxis.samedirection?(X_AXIS)).inspect}"
    puts "Y: #{t.yaxis.inspect} - #{(t.yaxis == Y_AXIS).inspect} - #{(t.yaxis.samedirection?(Y_AXIS)).inspect}"
    puts "Z: #{t.zaxis.inspect} - #{(t.zaxis == Z_AXIS).inspect} - #{(t.zaxis.samedirection?(Z_AXIS)).inspect}"
  end

  
  # @note Debug method to reload the plugin.
  #
  # @example
  #   TT::Plugins::AxesTools.reload
  #
  # @param [Boolean] tt_lib Reloads TT_Lib2 if +true+.
  #
  # @return [Integer] Number of files reloaded.
  # @since 1.0.0
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    TT::Lib.reload if tt_lib
    # Core file (this)
    load __FILE__
    # Supporting files
    if defined?( PATH ) && File.exist?( PATH )
      x = Dir.glob( File.join(PATH, '*.{rb,rbs}') ).each { |file|
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

#-------------------------------------------------------------------------------

file_loaded( __FILE__ )

#-------------------------------------------------------------------------------