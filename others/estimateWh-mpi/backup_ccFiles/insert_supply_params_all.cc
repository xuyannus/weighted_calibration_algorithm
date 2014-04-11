#include <iostream>
#include <fstream>
#include <vector>
#include <cassert>
#include <string>
#include <sstream>

/*

Ramachandran Balakrishna

12th August 2004

Insert new supply parameters into supplyparam.dat.dat
for subsequent DynaMIT runs

Arguments: # segments

Inputs: supplyparam.dat, cap_vector.dat, spddsy_vector.dat

Output: supplyparam_new.dat

// YW 9/11/2008: fix small issues and enhance robustness.

*/

int main() {
  using namespace std;

  cout << "Inserting capacities and speed-density parameters into supplyparam.dat..." << endl;

  const char *inFile = "supplyparam.dat";

  const char *v1 = "cap_vector.dat";
  const char *v2 = "spddsy_vector.dat";

  const char *v3 = "segment_groups.dat";

  const char *outFile = "supplyparam_new.dat";


  /*
   Open files
   */

  ifstream iFile(inFile, ios::in);
  if (!iFile)
  {
      cerr << "ERROR openning file: " << inFile << endl;
      return 1;
  }
  ifstream v1File(v1, ios::in);
  if (!v1File)
  {
      cerr << "ERROR openning file: " << v1File << endl;
      return 1;
  }

  ifstream v2File(v2, ios::in);
  if (!v2File)
  {
      cerr << "ERROR openning file: " << v2File << endl;
      return 1;
  }

  ifstream v3File(v3, ios::in);
  if (!v3File)
  {
      cerr << "ERROR openning file: " << v3File << endl;
      return 1;
  }
  
  ofstream oFile(outFile, ios::out);

  double nSegments;
  int nGroups;

  if (!(v1File >> nSegments)) return 2;
  if (!(v3File >> nGroups)) return 2;
  int nS = (int) nSegments;
  
  cout << "Number of segments = " << nS << " in " << nGroups << " groups..." << endl;

  // Populate array of speed-density parameters

  // Order of parameters in spddsy_vector.dat: v_0, k_j, alpha, beta, v_min, k_min 
  const int PARAMS = 6;

  //double a[nGroups][PARAMS]; // PARAMS per segment group
  vector< vector<double> > a( nGroups, vector<double>(PARAMS) ); // PARAMS per segment group
  assert( a.size() == nGroups );
  
  double z;

  for (int i = 0; i< nGroups; i++)
  {
      cout << "Group " << i+1 << " parameter " ;
      
      for (int j = 0; j< PARAMS; j++) {
          if (!(v2File >> z)) cerr << "FAILED to read Group " << i+1 << " param " << j+1 << '\n';

          a[i][j] = z;
          cout << '\t' << z;
      }
      cout << '\n';
  }
  cout << "Finish loading spd-dsy data from " << v2 << endl;

  char x, y;
  int y1;
  double y2, y3, y4, y5, y6, y7, y8;

  int g;    // Group variable

  string curr_line;
  typedef  string::size_type size_type;
  int count = 0, count_line = 0; // count segments read, count line encountered
      
  while ( getline( iFile, curr_line ) )
  {
      ++count_line;
      // trim anything after '#'
      size_type idx = curr_line.find('#', 0);
      if ( idx != string::npos )
      {
          cout << "Line " << count_line << " in " << inFile << " has comments: " << curr_line << '\n';
          curr_line.resize( idx );
      }

      istringstream iss( curr_line );
      
      // x and y capture the '{' and '}', respectively, while y1-y8 captures the following:
      // SegmentID freeFlowSpeed jamDensity alpha beta SegmentCapacity Vmin Kmin
      if ( !(iss >> x >> y1 >> y2 >> y3 >> y4 >> y5 >> y6 >> y7 >> y8 >> y ))
          cerr << "Failed to find full info from line " << count_line << ": " << curr_line << endl;
      else
      {
          // curr_line has full information for the new segment.
          ++count;
          
          if (!(v1File >> z)) cerr << "FAILED to get capacity from " << v1 << endl; // Get new capacity for segment i
          if (!(v3File >> g)) cerr << "FAILED to get group ID from " << v3 << endl; // Get group ID for segment i

          cout << "New capacity for segment" << count << " (UserID =" << y1
               << " group = " << g << ")" << " = " << z << '\n';
          assert( g <= nGroups && g > 0);  // g is presumably numbered from 1 to nGroups


          // YW 9/11/2008: Rama's original code reverted the output order of
          // a[g-1][4] and a[g-1][5], resulting a switch between Vmin and
          // Kmin, if the spddsy_vector.dat file is in normal order. Now
          // that the file is ordered by "freeFlowSpeed jamDensity alpha
          // beta Vmin Kmin", we should switch it back to normal.
          oFile << x << '\t' << y1 << '\t' << a[g-1][0] << '\t' << a[g-1][1] << '\t' << a[g-1][2]
                << '\t' << a[g-1][3] << '\t' << z << '\t' << a[g-1][4] << '\t' << a[g-1][5]  
                << '\t' << y << "\t\n";
          
      }
  }
  
      
  oFile << "\n<END>\n";

  iFile.close();
  v1File.close();
  oFile.close();

  if ( count != nS )
      return 1;
  else
      return 0;

} // end of main()
