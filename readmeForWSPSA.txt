%by hhm,22aug

Components
The WSPSA folder consists of 7 sub-folders, 10 dot m files and 1 dot dat file.
Subfolders:
	backup_ccFiles: A copy of .cc files; These code prepares for the DynaMIT the input parameter values(ods,speed-density etc);
	backup_original: A copy of all parameters related to DynaMIT and the WSPSA algorithm;
	DynaMIT: The program files of DynaMIT;
	initial: The starting value for ods(OD_vector.dat), speed-density relation parameters(spddsy_vector.dat), capacity value(cap_vector.dat) and routechoice parameters(rt_choice.dat), as well as real-world counting value for all sensors(sensor_counts.dat);
	iteration_record: Store as a whole vector the input parameter value when each iteration ends;
	parameter_record: Store seperately the input parameter value each time DynaMIT is run(3 times in a iteration);
	results: Store the RMSN value in each iteration(fn_RMSN_counts.dat and/or fn_RMSN_speeds.dat);
Files:
	CHANGEPARAMETERS.m: A matlab function; Set the input parameter values before running DynaMIT;
	clean: Delete all files in folder "iteration_record", "parameter_record", "results", and output files in folder "DynaMIT";
	configure.m: Store the value of algorithm parameters(Notice: not the input parameters to run DynaMIT);
	FUNC.m: A matlab function; Call DynaMIT and return the squared error between simulated sensor_counts and read-world sensor_counts;
	generate_Wc.m: A matlab function; Return the estimated weight matrix wc;
	window_Estimate.m: A matlab function; Called by generate_Wc.m;
	main.m: The main script file, main entrance to the whole calibration algorithm;
	merge_SparseMatrix.m: A matlab function; Combine the two sparse matrix into one sparse matrix.
	save_Parameters.m: A matlab fucntion; Write files in folder "parameter_record";
	seperate_SparseMatrix.m: A matlab function; Divide the sparse matrix into four sparse ones, the one for ods, for speed-density, for capacity and for route choice respectively.; 
	wh.dat: Dot dat file; Store the wh matrix;



