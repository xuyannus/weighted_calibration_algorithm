#include <iostream>
#include <fstream>
#include <string>

//using namespace std;

/*

Ramachandran Balakrishna

13th August 2004

Insert route choice parameter into BehavioralParameters.dat
for subsequent DynaMIT runs

Arguments: # OD pairs, # intervals, scaling factor (15 min intervals => factor = 4)

Inputs: BehavioralParameters.dat, rt_choice.dat

Output: BehavioralParameters_new.dat

// YW 9/11/2008: fix small problems and make it more robust

// Ma Wei, 16/08/2013: This code only use one parameters, but we want to use 3, a little change
*/

int main() {
    using namespace std;
    
    const char *inFile = "BehavioralParameters.dat";

    const char *v1 = "rt_choice.dat";

    const char *outFile = "BehavioralParameters_new.dat";

    /*
      Open files
    */

    ifstream iFile(inFile, ios::in);
    if ( ! iFile  )
    {
        cerr << "ERROR opening input file " << inFile << endl;
        return 1;
    }
  
      
    ifstream v1File(v1, ios::in);
    if ( ! v1File  )
    {
        cerr << "ERROR opening input file " << v1File << endl;
        return 1;
    }
  
    ofstream oFile(outFile, ios::out);



    string temp_input;
  
    for (int i=1; i<=3; i++) {
        getline(iFile,temp_input,'\n');
        oFile << temp_input << endl; 
    }
  
    char x;
    double y;
    double z[3];
    for (int i=0; i<=2; i++)
    {
      if (!(v1File >> z[i]))
            cerr << "FAILED to read from input file " << v1File << endl;      
    }

    for (int i=0; i<=2; i++) {
  

        if ( !(iFile >> temp_input >> x >> y))

            cerr << "FAILED to read from input file " << iFile << endl;
        if (i<=1){
        oFile << temp_input << '\t' << x << '\t' << z[i]<<endl ;}
        if (i==2){
        oFile << temp_input << '\t' << x << '\t' << z[i] ;
}
     
    }

    while ( getline(iFile,temp_input,'\n') ) {
        oFile << temp_input << '\n';
    }

    iFile.close();
    v1File.close();
    oFile.close();

    return 0;
} // end of main()
