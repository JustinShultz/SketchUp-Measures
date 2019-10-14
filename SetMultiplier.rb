######################################################################
#  Copyright (c) 2008-2016, Alliance for Sustainable Energy.  
#  All rights reserved.
#  
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#  
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#  
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
######################################################################

# Each user script is implemented within a class that derives from OpenStudio::Ruleset::UserScript
class SetMultiplier < OpenStudio::Ruleset::ModelUserScript

  # override name to return the name of your script
  def name
    return "Set Thermal Zone Multiplier"
  end
  
  # returns a vector of arguments, the runner will present these arguments to the user
  # then pass in the results on run
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new
    mult = OpenStudio::Ruleset::OSArgument::makeIntegerArgument("mult", true)
    mult.setDisplayName("Zone Multiplier for Selected Zones ")
    mult.setDefaultValue(1)
    args << mult
    return args
  end


  # override run to implement the functionality of your script
  # model is an OpenStudio::Model::Model, runner is a OpenStudio::Ruleset::UserScriptRunner
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
   
    if not runner.validateUserArguments(arguments(model),user_arguments)  
      return false
    end

    continue_operation = runner.yesNoPrompt("This will set the multiplier in the selected thermal zones. Click Yes to proceed, click No to cancel.")
    if not continue_operation
      puts "Operation canceled, your model was not altered."
      runner.registerAsNotApplication("Operation canceled, your model was not altered.")
      return true
    end

    thermal_zones = model.getThermalZones

    mult = runner.getIntegerArgumentValue("mult",user_arguments)
    
    any_in_selection = false
    
    thermal_zones.each do |thermal_zone|
      next if not runner.inSelection(thermal_zone)
      any_in_selection = true
      puts "#{thermal_zone.name.to_s} has been selected."
      thermal_zone.multiplier = mult
      end
    end

    if not any_in_selection
      runner.registerAsNotApplication("No thermal zones in current selection. Please select thermal zones.")
    end
    
    return true
  end

end

# this call registers your script with the OpenStudio SketchUp plug-in
SetMultiplier.new.registerWithApplication