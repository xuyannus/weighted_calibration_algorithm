#include <iostream>
#include <fstream>

/*

Ramachandran Balakrishna

12th August 2004

Insert demand vectors into demand.dat
for subsequent DynaMIT runs

Arguments: # OD pairs, # intervals, scaling factor (15 min intervals => factor = 4)

Inputs: demand.dat, OD_vector.dat

Output: demand_new.dat

*/

int main() {
  using namespace std;

  const char *inFile = "demand.dat";

  const char *v1 = "OD_vector.dat";

  const char *outFile = "demand_new.dat";

  char x, y;
  int y1, y2;
  double y3, z;

  double nOD, nInts, factor;

  int i, j; // Loop counters

  /*
   Open files
   */

  ifstream iFile(inFile, ios::in);
  ifstream v1File(v1, ios::in);

  ofstream oFile(outFile, ios::out);

  v1File >> nOD >> nInts >> factor;

  cout << nOD << " " << nInts << " " << factor << endl;

  for (i = 1; i <= (int) nInts; i++) {

    iFile >> y1 >> y2 >> y3 >> x;
    y3 = factor;
    oFile << y1 << "\t" << y2 << "\t" << y3 << '\n' << x << '\n';

    for (j = 1; j <= (int) nOD; j++) {

      iFile >> x >> y1 >> y2 >> z >> y;
         
      v1File >> z;
      //      oFile << "\t{\t" << y1 << "\t" << y2 << "\t" << (int)z << "\t}" << endl;
      oFile << "\t{\t" << y1 << "\t" << y2 << "\t" << z << "\t}" << '\n';

    } // end of for j

    iFile >> x;
    oFile << x << "\n\n";

  } // end of for i

  oFile << "<END>\n";

  iFile.close();
  v1File.close();
  oFile.close();

} // end of main()
