

require("src/nodes.jl")

root = joinpath(ENV["HOME"],"git/MOpt.jl")

opts =[
	"N"               => length(workers()),							# number of MCMC chains
	# "mode"            => "mpi",						# mode: serial or mpi
	"maxiter"         => 500,						# max number of iterations
	"savefile"        => joinpath(root,"MA.h5"),	# filename to save results
	# "source_on_nodes" => joinpath(root,"src/nodes.jl"),	
	"print_level"     => 1,							# increasing verbosity level of output
	"maxtemp"         => 100,						# tempering of hottest chain
	"min_shock_sd"    => 0.1,						# initial sd of shock on coldest chain
	"max_shock_sd"    => 1,							# initial sd of shock on hottest chain
	"past_iterations" => 30,						# num of periods used to compute Cov(p)
	"min_accept_tol"  => 100,						# ABC-MCMC cutoff for rejecting small improvements
	"max_accept_tol"  => 100,						# ABC-MCMC cutoff for rejecting small improvements
	"min_disttol"     => 0.1,						# distance tol for jumps from coldest chain
	"max_disttol"     => 0.1,						# distance tol for jumps from hottest chain
	"min_jump_prob"   => 0.05,						# prob of jumps from coldest chain
	"max_jump_prob"   => 0.2]						# prob of jumps from hottest chain

# setup the BGP algorithm
MA = MAlgoBGP(mprob,opts)

# check that all have a valid MProb object
wkr = workers()
println("workers are : ")
println(wkr)

@everywhere rows = nrow(mprob.moments)
for w in wkr
	remotecall_fetch(w,() -> rows)
end

println("calling runMopt now")

# run it
runMOpt!(MA)

# plot outputs
MOpt.figure(1)
plot(MA,"acc")
MOpt.figure(2)
plot(MA,"params_time")
MOpt.figure(3)
plot(MA,"params_dist")

# save results
save(MA,MA["savefile"])
	


