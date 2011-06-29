#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------
# Compatible: SketchUp 7 (PC)
#             (other versions untested)
#-------------------------------------------------------------------------------
#
# CHANGELOG
# 1.2.0 - 29.06.2011
#    * Renamed "Set Insertion Point" to "Set Origin"
#
# 1.1.0 - 06.09.2010
#    * Requires TT_Lib2.2.0
#    * Replaced old menus with new Set Insertion Point
#
# 1.0.0 - 30.08.2010
#    * Initial release.
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'TT_Lib2/core.rb'

TT::Lib.compatible?('2.2.0', 'TT Axes Tools')

#-------------------------------------------------------------------------------

module TT::Plugins::AxesTools  
  
  ### CONSTANTS ### ------------------------------------------------------------
  
  VERSION = '1.2.0'.freeze
  #VERSION = TT::Version.new(1,2,0).freeze # TT_Lib 2.6
  
  
  ### MODULE VARIABLES ### -----------------------------------------------------
  
  # Preference
  @settings = TT::Settings.new('TT_Axes_Tools')
  @settings[:x, 'Center']
  @settings[:y, 'Center']
  @settings[:z, 'Center']
  
  
  ### MENU & TOOLBARS ### ------------------------------------------------------
  
  unless file_loaded?( File.basename(__FILE__) )
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
  
  
  def self.reload
    load __FILE__
  end
  
end # module

#-------------------------------------------------------------------------------

file_loaded( File.basename(__FILE__) )

#-------------------------------------------------------------------------------