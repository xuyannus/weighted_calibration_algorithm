%by hhm,22aug 2013
%revised by Lu Lu 18 Sep 2013

Wh is the estimated weight matrix (Jacobi matrix) using simultaneous perturbation. It reflects the relationship between the change in parameters and the change in measurements. Other ways to generate weight matrix includes analytical calculation and simulated assignment matrix. More details about weight matrix and W-SPSA please refer to W-SPSA documents.

Components
The estimateWh folder consists of 10 sub-folders, 8 dot m files and 2 dot dat files.
Subfolders:
	backup_ccFiles: A copy of .cc files; These code prepares for the DynaMIT the input parameter values(ods,speed-density etc);
	backup_original: A copy of all parameters related to DynaMIT and the WSPSA algorithm;
	DynaMIT: The program files of DynaMIT;
	DynaMIT_for_assign: The program files of DynaMIT_R;
	initial: The starting value for ods(OD_vector.dat), speed-density relation parameters(spddsy_vector.dat), capacity value(cap_vector.dat) and routechoice parameters(rt_choice.dat), as well as real-world counting value for all sensors(sensor_counts.dat);
	iteration_record: 1)Store the two perturbed input parameter value vectors(thetaminus.dat & thetaplus.dat) and their difference(thetadiff.dat); 2)Store the two squared error vector of thetaminus and thetaplus(yminus.dat & yplus.dat) and their difference(ydiff.dat); 
	parameter_record: Store seperately the input parameter value each time DynaMIT is run(3 times in a iteration);
	replace: Store the code which combines the estimated wh matrix with the perfect matrix;
	results: Store the RMSN value in each iteration(fn_RMSN_counts.dat);
	weightmatrix2: Store the java code which calculates the weight matrix according to the assign-matrix in DynaMIT;

Files:
	CHANGEPARAMETERS.m: A matlab function; Set the input parameter before running DynaMIT;
	clean: Delete all files in folder "iteration_record", "parameter_record", "results", and output files in folder "DynaMIT";
	configure.m: Store the algorithm parameters(Notice: not the input parameters to run DynaMIT);
	FUNC.m:	A matlab function; Call DynaMIT and return the squared error between simulated sensor_counts and read-world sensor_counts;
	generate_Perturbation.m: Generate the perturbations around the initial value of ods, capacity, speed-density and rt, and then write them to files in folder "iteration_record";
	generate_Wh.m: Reading the perturbation results in folder "iteration_record" to generate the wh matrix(wh.dat);
	interval_Effect.m: A matlab function; Take advantage of interval info to modify the wh generated;
	save2SparseMatrix.m: A matlab function; Save the wh matrix in sparse form;
	save_Parameters.m: A matlab function; Write files in folder "parameter_record";
	wh.dat: Dot dat file; Store the wh matrix;







