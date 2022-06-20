# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# PARAMETERS - parameters that are used in the backwards iteration and forward simulation
#-------------------------------------------------------------------------------------------------------------------------------------------------------------

# Mark: some of the parameters are mainly helpful tools for coding reasons, other are more direct model parameters

# Named the decisions by numbers (to easier use them in the code)
# These are the different acitity modes that the insect can behaviorally choose
const HIDE = 1
const FEED = 2
const SEARCH_MATE = 3

const MATE = 4 # Dependent on search_mate happening (so this is not a decision, but more like a category of search_mate)

# These varables gives us the maximum level of each state and time
const time_end = 60 # number of timesteps (weeks of season)
const water_max = 200 # maximum internal water level
const energy_max = 20 # maximum internal energy level
const temp_max = 5 # maximum temperature
const humidity_max = 5 # maximum humidity

const num_decisions = 3 # number of decisions (Hide, feed and search mate)
const num_states = 4 # number of states (water, energy, temperature, humidity)

# limits the states so that they will have upper and lower limits
# Now all go from 1 to the max that is defined for each above
const water_limits = [1, water_max]
const energy_limits = [1, energy_max]
const temp_limits = [1, temp_max]
const humidity_limits = [1, humidity_max]

# Making 4*2 matrix with lower and upper bounds for each state
internal_state_limits = vcat(water_limits', energy_limits') # ' transposes vector, vcat() sets the two elements together vertically (beneath each other)
external_state_limits = vcat(temp_limits', humidity_limits')
state_limits = vcat(internal_state_limits, external_state_limits) # matrix with lower and upper limits for one state at each row

# Probability of finding a mate
const p_mate = 0.9

# Mortality
const p_die = 0.01 # chance of dying each time step
const p_survive = 1 - p_die

# TRANSITIONS OF WATER
# waterloss[temp, humidity]
const waterloss = [5 11 17 23 29; 4 9 14 19 24; 3 7 11 15 19; 2 5 8 11 14; 1 3 5 7 9] # This is doubbled for feeding and searching compared to hiding. Searching also has additional cost, see below
# watergain[humidity]
const watergain = [9 18 27 36 45]

# TRANSITION OF ENERGY: Input into functions
# Input to exponential function. Scaling factors
const a_hide=0.2
const a_feed_rep=0.4
# Input to logistic function
const k_feed=2.2
const x_0_feed=1.8
const L_feed=6

# Additional cost of searching added to increase the cost of searching compared to feeding
const searchcost_water = 20
const searchcost_energy = 2

# The water and energy cost of one reproductive unit
const water_cost_reproduce = 10 # The water cost of reproducing one offspring/reproductive unit
const energy_cost_reproduce = 2 # The energy cost of reproducing one offspring/reproductive unit

# The level of reserves needed for reproduction
const water_lower_limit_reproduction= 2
const energy_lower_limit_reproduction = 2



# WEATHER: choose the weather scenario (numbers are percent)
const weather_pool = [1, 2, 3, 4, 5]
""" Baseline """
const hum_weights = [5, 25, 40, 25, 5]
const temp_weights = [5, 25, 40, 25, 5]
""" Hot_and_dry"""
# const hum_weights = [25, 40, 25, 5, 5]
# const temp_weights = [5, 5, 25, 40, 25]
""" Hot_and_wet"""
# const hum_weights = [5, 5, 25, 40, 25]
# const temp_weights = [5, 5, 25, 40, 25]
""" Cold_and_dry"""
# const hum_weights = [25, 40, 25, 5, 5]
# const temp_weights = [25, 40, 25, 5, 5]
""" Cold_and_wet"""
# const hum_weights = [5, 5, 25, 40, 25]
# const temp_weights = [25, 40, 25, 5, 5]


# Used to make the combined weather probabilities from the weights for temperature and humidity
const temp_probs = temp_weights / sum(temp_weights)
const hum_probs = hum_weights / sum(hum_weights)
const weather_weights_combined = hum_weights * temp_weights' # Weights of different temp and hum in combination
const weather_probs_combined = weather_weights_combined / sum(weather_weights_combined) # proportions
