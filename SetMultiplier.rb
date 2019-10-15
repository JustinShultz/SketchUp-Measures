######################################################################
#  Written by Justin Shultz.  
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
    mult.setDisplayName("Selected Zones Multiplier  ")
    mult.setDefaultValue(1)
    args << mult

    return args
  end

  # override run to implement the functionality of your script
  # model is an OpenStudio::Model::Model, runner is a OpenStudio::Ruleset::UserScriptRunner
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # check that the input if valid
    if not runner.validateUserArguments(arguments(model),user_arguments)  
      return false
    end

    # check the user means to execute this action 
    continue_operation = runner.yesNoPrompt("This will set the multiplier in the selected thermal zones. Click Yes to proceed, click No to cancel.")
    if not continue_operation
      puts "Operation canceled, your model was not altered!"
      runner.registerAsNotApplicable("Operation canceled, your model was not altered.")
      return true
    end

    # get the mult valuable from inputs
    mult = runner.getIntegerArgumentValue("mult",user_arguments)
    puts "The zone multiplier has been set to #{mult}"
    
    any_in_selection = false # flag to throw and error if nothing is selected
    # iterate through each space of the model
    model.getSpaces.each do |space|
      next if not runner.inSelection(space) # if not selected than skip this space
      any_in_selection = true # change flag 
      space_zone = space.thermalZone # find the space's thermal zone
      space_zone = space_zone.get # get the space's thermal zone
      space_zone.setMultiplier(mult) # set the multiplier of the thermal zone
    end
    
    # displace an error if no spaces are selected
    if not any_in_selection
      runner.registerAsNotApplicable("No thermal zones in current selection. Please select thermal zones.")
    end

    return true
  end

end

# this call registers your script with the OpenStudio SketchUp plug-in
SetMultiplier.new.registerWithApplication