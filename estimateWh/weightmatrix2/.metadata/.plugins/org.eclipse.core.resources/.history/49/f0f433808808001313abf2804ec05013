/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package weightmatrix2;

import java.util.ArrayList;

/*
 * This class records the path of a OD pair
 */
public class OD {
	private String od;
	private String[] paths;
	private ArrayList<String> sensors = new ArrayList<String>();

	OD() {
		this("",null);
	}

	OD(String od, String[] paths) {
		this.od = od;
		this.paths = paths;
	}

	public String getOD() {
		return od;
	}

	public String[] getPaths() {
		return paths;
	}

	public void setPaths(String[] paths) {
		this.paths = paths;
	}

	public void addPaths(String[] paths) {
		int len1 = this.paths.length;
		int len2 = paths.length;
		int len = len1 + len2;
		String[] newPaths = new String[len];
		for (int i=0; i<len1; ++i) {
			newPaths[i] = this.paths[i];
		}
		for (int i=len1; i<len; ++i) {
			newPaths[i] = paths[i - len1];
		}
                this.paths = newPaths;
	}

	public String getPathStr() {
		String pathStr = "";
		for (int i=0; i<paths.length; ++i) {
			pathStr = pathStr + paths[i] + " ";
		}

		return pathStr;
	}

	public boolean isSameOD(String toCmp) {
		return toCmp.equals(od);
	}

	public boolean hasLink(String link) {
		boolean has = false;

		for (int i=0; i<paths.length; ++i) {
			if (paths[i].equals(link))
				has = true;
		}
		return has;
	}

	public boolean isShorter(OD toCmp) {
		String[] cmpPaths = toCmp.getPaths();
		int cmpLen = cmpPaths.length;
		return (this.paths.length < cmpLen);
	}

	public void getSensors(ArrayList<Sensor> s) {
		for (int i=0; i<s.size(); ++i) {
			String link = s.get(i).getLink();
			if (this.hasLink(link)) {
				sensors.add(link);
			}
		}
	}
	public boolean onlySensor(String link) {
		if (this.sensors != null) {
			if (this.sensors.size() == 1) {
				if (sensors.get(0).equals(link))
					return true;
				else
					return false;
			}
			else
				return false;
		}
		else
			return false;
	}
}
