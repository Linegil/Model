# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# FUNCTIONS USED IN THE BACKWARDS ITERATION AND FORWARDS SIMULATION
# -----------------------------------------------------------------------------------------------------------------------------------------------------------


using StatsBase # use it for the weights function

# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions for state transitions and bounding of internal and external states
# -----------------------------------------------------------------------------------------------------------------------------------------------------------

function function_logistic(x, k, x_0, L)
    return L/(1+exp(-k*(x-x_0)))
end

function function_exp(scaling_factor,temp)
    return exp(scaling_factor*temp)
end

function bound_state(state, state_limits)
    """ Makes sure that if state fells below lower limits the state is set to lower limit and if state becomes higher than max it is set to max
    Notice that temperature and humidity is in here as well, even though it is not necessary at the moment, it is just easier to threat all states the same, and it does no harm at the moment
    matrix: makes a matrix with rows for each state, rows consisting of current state and state limits. Sort each row.
    returns: the middle value, this will be the bounded state. """
    matrix = sort(hcat(state, state_limits), dims=2)
    return matrix[:, 2]
end


function calculate_water_next(state, action)
    """ Calculates the water state after decision. For TRY_REPRODUCE there are two possible state transitions.
    If a mate is not found there is only a cost of searching.
    If a mate is found. There is a cost of searching for mate and cost of reproducing.
    Assuming:
    The waterloss is dependent on hum and temp. Increasing with higher temp, increasing with lower hum.
    The gain is dependent on humidity/water availability.Linearily increasing.
    """
    water, _, temp, humidity = state
    if action == HIDE
        return water - waterloss[humidity, temp]
    elseif action == FEED
        return water - waterloss[humidity, temp] * 2 + watergain[humidity]
    elseif action == SEARCH_MATE
        return water - waterloss[humidity, temp] * 2 - searchcost_water
    elseif action == MATE
        return water - number_of_offspring_possible(state) * water_cost_reproduce
    end
end


function calculate_energy_next(state, decision)
    """ Calculates the energy state after decision. For TRY_REPRODUCE there are two possible state transitions.
    If a mate is not found there is only a cost of searching.
    If a mate is found. There is a cost of searching for mate and cost of reproducing
    """
    water, energy, temperature, _ = state

    if decision == HIDE
        return energy - round(Int, function_exp(a_hide, temperature))
    elseif decision == FEED
        return energy + round(Int, - function_exp(a_feed_rep, temperature) + function_logistic(temperature, k_feed, x_0_feed, L_feed))
    elseif decision == SEARCH_MATE
        return energy - (round(Int, function_exp(a_feed_rep, temperature))) - searchcost_energy
    elseif decision == MATE
        return energy - number_of_offspring_possible(state) * energy_cost_reproduce
    end
end


function state_transition(state, decision)
    """ State transitions for energy and water """
    _, _, temp, humidity = state
    water_next = calculate_water_next(state, decision)
    energy_next = calculate_energy_next(state, decision)
    next_state_unbounded = [water_next, energy_next, temp, humidity]
    next_state = bound_state(next_state_unbounded, state_limits)

    return next_state
end


function get_temp()
    """ Pick a temp/hum, based on aproximatly normal distributed probabilities. Used in forward simulation """
    next = sample(weather_pool, weights(temp_weights))
    return next
end

function get_hum()
    """ Pick a temp/hum, based on aproximatly normal distributed probabilities. Used in forward simulation """
    next = sample(weather_pool, weights(hum_weights))
    return next
end


# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# Functions important for the reward
# -----------------------------------------------------------------------------------------------------------------------------------------------------------

function number_of_offspring_possible(state)
    """ Function that gives the number of offspring you can get from reproducing at a timestep dependent on water and energy level."""
    water, energy, _, _ = state # focus on water and energy as these are the internal resourses invested in reproduction
    if water < water_lower_limit_reproduction || energy < energy_lower_limit_reproduction
        return 0
    else
        offspring_from_water = Int(floor((water - water_lower_limit_reproduction) / water_cost_reproduce)) # devides water state on water cost of reproduction (rounded down to closest integer)
        offspring_from_energy = Int(floor((energy - energy_lower_limit_reproduction) / energy_cost_reproduce)) # same for energy
        offspring_possible = min(offspring_from_water, offspring_from_energy) # finds how many offspring is possible form limiting state
        if offspring_possible <= 0 # if equal to or less than 0, set offspring to 0
            return 0
        else
            return offspring_possible # returns the number of offsprings that can be made
        end
    end
end

function direct_reward(state, time)
    """ Number of offsrping that is made when reproducing. Only direct reward if finding a mate and thereby succeeding to reproduce.
        This is now just hte same as number_of_offspring_possible, but using this function it is possible to multiply with offspring value.
    """
    return number_of_offspring_possible(state)
end


function overwrite_death_value(reward_if_decision)
    """ This function makes sure there is no reward gained after dying.
    If water level becomes 1, then for all combinations of states and time from then until the end the insect gets no reward.
    Same for energy level.  """
    reward_if_decision[1, :, :, :, :] .= 0
    reward_if_decision[:, 1, :, :, :] .= 0
    return reward_if_decision
end
