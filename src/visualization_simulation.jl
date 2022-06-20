# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# VISUALIZATION OF SIMULATION DATA
# -----------------------------------------------------------------------------------------------------------------------------------------------------------

using PlotlyJS #To plot heatmaps and make a plot of subplots and save it
using JLD2 # To load jld file
using IterTools # Used to simplify for loops
using DataFrames # To work with dataframes
using StatsBase #To use build in stats functions
include("parameters.jl")


""" Specify which simulation data to vizualise. Specify filepath."""
simulation="baseline"
scenarioname="baseline"
visualization_folder="baseline"
num_sim=1000

simulations = load("simulations/$simulation/$num_sim.jld2")["simulations"]
number_of_simulations = length(collect(simulations))


function plot_all_simulated_decisions(number_of_simulations,visualization_folder, scenarioname)
    """ Combines the decisions of every individual
    from the simulations into a heatmap plot that counts how many does which activity at each timestep """
    all_decisions = zeros(Int, 0, 59)
    for i in 1:number_of_simulations
        decisions = simulations[i]["decisions"]
        all_decisions = vcat(all_decisions, decisions')
    end
    sort!(all_decisions, dims=1, rev=true)
    color_list=["#332288", "#882255", "#117733", "#DDCC77", "#8cbb7d"]
    categories = ["Dead", "Hide", "Feed", "Search for mate"]
    levels = [0, 1, 2, 3, 4]
    label_levels = levels .+ 0.5
    norm_levels = (levels .- minimum(levels))/maximum(levels)
    color_marks = [[norm_levels[1], color_list[1]]]
    for i in 2:length(levels)
        push!(color_marks, [norm_levels[i], color_list[i-1]])
        push!(color_marks, [norm_levels[i], color_list[i]])
    end
    trace = heatmap(z=all_decisions, x=1:59, y=1:number_of_simulations, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9), zmin=minimum(levels),
    zmax=maximum(levels), showscale=true)
    layout=Layout(title="Simulation of activity in $scenarioname scenario", xaxis_title_text="Time", yaxis_title_text="Count of individuals" )
    p=plot(trace, layout)
    return savefig(p, "Visualizations/$visualization_folder/heatmap.png")
end

plot_all_simulated_decisions(number_of_simulations, visualization_folder, scenarioname)



function plot_only_energy(number_of_simulations, visualization_folder)
    """ Stacked barplot. Plots the energy state when taking a decision at timestep.
    Remember to specify filelocation and name."""
    total = zeros(Int, water_max, energy_max, num_decisions, time_end - 1)

    for i in 1:number_of_simulations
        total += simulations[i]["state_decision_time"]
    end

    only_energy = dropdims(sum(total, dims=1), dims=1)
    # colour= ["#ddcc77", "#dbc277", "#dab977", "#d8af77", "#d6a577", "#d59b77", "#d39177", "#d18677", "#d07c77", "#ce7077", "#cb6577", "#c45e73", "#bc566f", "#b54f6c", "#ae4868", "#a64064", "#9f3960", "#97315d", "#902a59", "#882255"]
    colour= ["#ddcc77", "#e0c17c", "#e2b580", "#e5a985", "#e89b8b", "#eb8d90", "#ea8192", "#e37a8d", "#db7289", "#d36b84", "#cc647f", "#c45d7b", "#bd5576", "#b54e71", "#ae476d", "#a63f68", "#9f3863", "#97315f", "#90295a", "#882255"]
    # Color scheme from here: https://gka.github.io/palettes/#/20|s|ddcc77,cc6677,882255|ffffe0,ff005e,93003a|1|0
    for decision in 1:3
        p = plot()
        for e = 1:energy_max
            add_trace!(p, bar(x=1:59, y=only_energy[e, decision,1:59], name="$e", marker=attr(color=colour[e], line_width=0.2)))
        end
        if decision == 1
            action = "Hide"
        elseif decision == 2
            action = "Feed"
        elseif decision == 3
            action = "Search mate"
        end
        relayout!(p, barmode="stack", title="Count of individuals and their energy state when deciding to $action", xaxis_title_text="Time", yaxis_title_text="Count of individuals", plot_bgcolor="F1F3F9")
        savefig(p, "Visualizations/$visualization_folder/energy_$action.png")
    end
end

plot_only_energy(number_of_simulations, visualization_folder)


function plot_only_water(number_of_simulations, visualization_folder)
    """ Stacked barplot. Plots the water state when taking a decision at timestep.
    Remember to specify filelocation and name."""
    total = zeros(Int, water_max, energy_max, num_decisions, time_end - 1)

    for i in 1:number_of_simulations
        total += simulations[i]["state_decision_time"]
    end

    only_water = dropdims(sum(total, dims=2), dims=2)
    colors=["#ddcc77", "#dbcc77", "#d9cb78", "#d7cb78", "#d4ca79", "#d2ca79", "#d0c97a", "#cec97a", "#ccc87b", "#cac87b", "#c7c77c", "#c5c77c", "#c3c67d", "#c1c67d", "#bec57e", "#bcc57e", "#bac47f", "#b8c47f", "#b5c380", "#b3c380", "#b1c281", "#afc281", "#acc182", "#aac182", "#a8c083", "#a5c083", "#a3bf84", "#a0bf84", "#9ebe85", "#9cbd86", "#99bd86", "#97bc87", "#94bc87", "#92bb88", "#8fbb88", "#8dba89", "#8aba89", "#88b98a", "#85b98a", "#83b88b", "#80b78c", "#7eb78c", "#7bb68d", "#78b68d", "#76b58e", "#73b48f", "#70b48f", "#6eb390", "#6bb390", "#68b291", "#65b192", "#62b192", "#60b093", "#5daf94", "#5aaf94", "#57ae95", "#54ae95", "#51ad96", "#4eac97", "#4aab98", "#47ab98", "#44aa99", "#44a999", "#44a899", "#44a799", "#44a699", "#43a598", "#43a498", "#43a398", "#43a298", "#43a298", "#43a198", "#43a098", "#439f98", "#429e97", "#429d97", "#429c97", "#429b97", "#429a97", "#429997", "#429897", "#429797", "#429697", "#419596", "#419496", "#419396", "#419296", "#419296", "#419196", "#419096", "#418f96", "#408e95", "#408d95", "#408c95", "#408b95", "#408a95", "#408995", "#408895", "#408795", "#408695", "#3f8594", "#3f8494", "#3f8394", "#3f8394", "#3f8294", "#3f8194", "#3f8094", "#3f7f94", "#3e7e93", "#3e7d93", "#3e7c93", "#3e7b93", "#3e7a93", "#3e7993", "#3e7893", "#3e7793", "#3e7693", "#3d7592", "#3d7492", "#3d7492", "#3d7392", "#3d7292", "#3d7192", "#3d7092", "#3d6f92", "#3c6e91", "#3c6d91", "#3c6c91", "#3c6b91", "#3c6a91", "#3c6991", "#3c6891", "#3c6791", "#3c6691", "#3b6590", "#3b6590", "#3b6490", "#3b6390", "#3b6290", "#3b6190", "#3b6090", "#3b5f90", "#3a5e8f", "#3a5d8f", "#3a5c8f", "#3a5b8f", "#3a5a8f", "#3a598f", "#3a588f", "#3a578f", "#3a568f", "#39558e", "#39548e", "#39538e", "#39528e", "#39518e", "#39508e", "#394f8e", "#394e8e", "#384e8d", "#384d8d", "#384c8d", "#384b8d", "#384a8d", "#38498d", "#38488d", "#38478d", "#37468c", "#37458c", "#37448c", "#37438c", "#37428c", "#37408c", "#373f8c", "#373e8c", "#363d8b", "#363c8b", "#363b8b", "#363a8b", "#36398b", "#36388b", "#36378b", "#36368b", "#35358a", "#35348a", "#35338a", "#35328a", "#35308a", "#352f8a", "#352e8a", "#342d89", "#342c89", "#342b89", "#342a89", "#342889", "#342789", "#332688", "#332588", "#332388", "#332288"]
    # Colors sheme from here: https://gka.github.io/palettes/#/200|s|ddcc77,44aa99,332288|ffffe0,ff005e,93003a|1|0
    for decision in 1:3
        p = plot()
        for w = 1:water_max
            add_trace!(p, bar(x=1:59, y=only_water[w, decision,1:59], name="$w", marker=attr(color=colors[w], line_width=0.0, showscale=false)))
        end
        if decision == 1
            action = "Hide"
        elseif decision == 2
            action = "Feed"
        elseif decision == 3
            action = "Search mate"
        end
        relayout!(p, barmode="stack", title="Count of individuals and their water state when deciding to $action ", xaxis_title_text="Time", yaxis_title_text="Count of individuals", plot_bgcolor="F1F3F9")
        savefig(p, "Visualizations/$visualization_folder/water_$action.png")
    end
end

plot_only_water(number_of_simulations, visualization_folder)


function death_cause(visualization_folder, number_of_simulations)
    """Histogram summing up death cause and death time.
    Remember to update file path and name."""
    death_time=[]
    death_cause_both=[]
    death_cause_starv=[]
    death_cause_dessic=[]
    death_cause_pred=[]
    death_cause_winter=[]
    for i in 1:number_of_simulations
        append!(death_time, simulations[i]["time_of_death"])
        reason=simulations[i]["death_cause"]
        if reason=="Dessication and Starvation"
            death_cause_both=vcat(death_cause_both, 1)
            death_cause_starv=vcat(death_cause_starv, 0)
            death_cause_dessic=vcat(death_cause_dessic, 0)
            death_cause_pred=vcat(death_cause_pred, 0)
            death_cause_winter=vcat(death_cause_winter, 0)
        elseif reason=="Starvation"
            death_cause_both=vcat(death_cause_both, 0)
            death_cause_starv=vcat(death_cause_starv, 1)
            death_cause_dessic=vcat(death_cause_dessic, 0)
            death_cause_pred=vcat(death_cause_pred, 0)
            death_cause_winter=vcat(death_cause_winter, 0)
        elseif reason=="Dessication"
            death_cause_both=vcat(death_cause_both, 0)
            death_cause_starv=vcat(death_cause_starv, 0)
            death_cause_dessic=vcat(death_cause_dessic, 1)
            death_cause_pred=vcat(death_cause_pred, 0)
            death_cause_winter=vcat(death_cause_winter, 0)
        elseif reason=="Predation"
            death_cause_both=vcat(death_cause_both, 0)
            death_cause_starv=vcat(death_cause_starv, 0)
            death_cause_dessic=vcat(death_cause_dessic, 0)
            death_cause_pred=vcat(death_cause_pred, 1)
            death_cause_winter=vcat(death_cause_winter, 0)
        elseif reason=="Winter comes"
            death_cause_both=vcat(death_cause_both, 0)
            death_cause_starv=vcat(death_cause_starv, 0)
            death_cause_dessic=vcat(death_cause_dessic, 0)
            death_cause_pred=vcat(death_cause_pred, 0)
            death_cause_winter=vcat(death_cause_winter, 1)
        end
    end
    df=DataFrame(time=death_time, both=death_cause_both, starvation=death_cause_starv, dessication=death_cause_dessic, predation=death_cause_pred, winter=death_cause_winter)
    gdf = DataFrames.groupby(df, :time)
    comb=combine(gdf, [:both, :starvation, :dessication, :predation, :winter] .=> sum; renamecols=false)
    sorted=sort!(comb)
    sorted = sorted[setdiff(1:end, 60), :]
    p=plot([bar(sorted, x=:time, y=:predation, name="Predation", marker=attr(color="#0C0C0C" )),
            bar(sorted, x=:time, y=:both, name="Both", marker=attr(color="#656474")),
            bar(sorted, x=:time, y=:dessication, name="Desiccation", marker=attr(color="#9A9A9C")),
            bar(sorted, x=:time, y=:starvation, name="Starvation", marker=attr(color= "#C9C8C8")), ]
            , Layout(barmode="stack", title="Death cause and time of death", yaxis_title_text="Count of individuals", xaxis_title_text="Time", plot_bgcolor="#FAFAFA"))
    return savefig(p, "Visualizations/$visualization_folder/deathcause.png")
end

death_cause(visualization_folder, number_of_simulations)




function fitness_plot(visualization_folder, number_of_simulations)
    """Histogram displaying fitness (number of offsprings)"""
    ind=[]
    count_off=[]
    for i in 1:number_of_simulations
        append!(ind, 1)
        offspring=simulations[i]["how_many_offspring"]
        if isempty(offspring)
        append!(count_off, 0)
        else
        number_elements=length(offspring)
        sum=0
            for i in 1:number_elements
                sum+=offspring[i]
            end
        append!(count_off, sum)
        end
    end
    df=DataFrame(offspring=count_off, individuals=ind)
    gdf = DataFrames.groupby(df, :offspring)
    comb=combine(gdf, [:individuals] .=> sum; renamecols=false)
    sorted=sort!(comb)
    p=plot([bar(sorted, x=:offspring, y=:individuals, marker=attr(color="333333")),]
            , Layout(title="Distribution of fitness values", yaxis_title_text="Count of individuals", xaxis_title_text="Amount of offsprings", plot_bgcolor="F1F3F9"))

    return savefig(p, "Visualizations/$visualization_folder/fitness.png")
end

fitness_plot(visualization_folder, number_of_simulations)


function times_rep(visualization_folder, number_of_simulations)
    """Histogram of how many reproductions"""
    ind=[]
    times_reproduced=[]
    for i in 1:number_of_simulations
        append!(ind, 1)
        append!(times_reproduced, simulations[i]["reproductive_events"])
    end
    df=DataFrame(reproduced=times_reproduced, individuals=ind)
    gdf = DataFrames.groupby(df, :reproduced)
    comb=combine(gdf, [:individuals] .=> sum; renamecols=false)
    sorted=sort!(comb)
    p=plot([bar(sorted, x=:reproduced, y=:individuals, marker=attr(color="333333")),]
            , Layout(title="Distribution of individuals based on number of reproductive events", yaxis_title_text="Count of individuals", xaxis_title_text="Times reproduced", plot_bgcolor="F1F3F9" ))
    return savefig(p, "Visualizations/$visualization_folder/reproductions.png")
end

times_rep(visualization_folder, number_of_simulations)


function calculate_fitness_and_reproductions(visualization_folder, scenarioname)
    fitness=[]
    reproductions=[]
    time_of_rep=[]
    for i in 1:number_of_simulations
        append!(fitness, simulations[i]["tot_offspring_season"])
        append!(reproductions, simulations[i]["reproductive_events"])
        append!(time_of_rep, simulations[i]["time_of_reproduction"])
    end
    p=plot(
        table(
            header=attr(
                values=["Simulation", "Mean fitness", "Fitness var", " Fitness std", " Mean #Rep", "#Rep var", "#Rep std", "Mean time rep", "Mode time rep"], line_color="black", fill_color="snow3", align="center",
                    font=attr(
                        color="black", size=8
                    )
                ),
            cells=attr(
                values=[["$scenarioname"], [round(mean(fitness); digits=2)], [round(var(fitness); digits=2)], [round(std(fitness); digits=2)], [round(mean(reproductions); digits=2)], [round(var(reproductions); digits=2)],
                [round(std(reproductions); digits=2)], [round(mean(time_of_rep); digits=2)], [mode(time_of_rep)]],
                line_color="black", fill_color=["white", "khaki", "khaki", "white", "white", "white", "white", "white", "white"],
                font=attr(color="black", size=10)
            )
        )
    )
    return savefig(p, "Visualizations/$visualization_folder/stats.png")

end

calculate_fitness_and_reproductions(visualization_folder, scenarioname)
