#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'extensions.rb'

module TT
 module Plugins
  module AxesTools

  # Plugin information
  PLUGIN_ID       = 'TT_Axes_Tools'.freeze
  PLUGIN_NAME     = 'Axes Tools'.freeze
  PLUGIN_VERSION  = '1.3.2'.freeze

  # Resource paths
  FILENAMESPACE = File.basename(__FILE__, '.rb')
  PATH_ROOT     = File.dirname(__FILE__).freeze
  PATH          = File.join(PATH_ROOT, FILENAMESPACE).freeze


  unless file_loaded?(__FILE__)
    loader = File.join(PATH, 'core')
    ex = SketchupExtension.new(PLUGIN_NAME, loader)
    ex.description = 'Bulk adjustments of axes.'
    ex.version     = PLUGIN_VERSION
    ex.copyright   = 'Thomas Thomassen © 2010-2022'
    ex.creator     = 'Thomas Thomassen (thomas@thomthom.net)'
    Sketchup.register_extension(ex, true)
  end

  end # module AxesTools
 end # module Plugins
end # module TT

file_loaded(__FILE__)
