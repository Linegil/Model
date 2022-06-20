# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN - THIS IS USED FOR RUNNING THE MODEL
# -----------------------------------------------------------------------------------------------------------------------------------------------------------

using JLD2
# The main also takes in the packages specified in the scripts included and the scripts included in these scripts again.

include("backwards_iteration.jl")
include("forward_simulation.jl")

function main(decision_folder, simulation_folder, num_sim, run_backwards)
    """ Runs the backwards iteration and forwards simulation and saves the decision rule and the simulation data.
    Remember to add scenario so that the file path becomes correct, as well as addin g number of individuals for simulation and if the backwards should run."""
    if run_backwards
        decision_rule = activity_rule()
        save("simulations/$decision_folder/decision_rule.jld2", "decision_rule", decision_rule)
    end
    println("Loading decision rule")
    decision_rule = load("simulations/$decision_folder/decision_rule.jld2")["decision_rule"]
    println("Starting forward simulation")
    simulations = monte_carlo_simulation(decision_rule, num_sim)
    save("simulations/$simulation_folder/$num_sim.jld2", "simulations", simulations)
end

main("baseline", "baseline", 1000, true) #Specify where to save decision rule and simulations, number of individuals in simulation and true if running both backwards and forwards
# Alterations of decision files and the weather scenario parameters is used to get the different decision rules and use the decision rule in native and new environments
