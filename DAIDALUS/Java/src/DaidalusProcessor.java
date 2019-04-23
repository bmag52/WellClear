import gov.nasa.larcfm.ACCoRD.Daidalus;
import gov.nasa.larcfm.ACCoRD.DaidalusFileWalker;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public abstract class DaidalusProcessor {


	private double from_;
	private double to_;
	private double relative_;
	private String options_;
	private String ownship_;

	public DaidalusProcessor() {
		this("");
	}

	public DaidalusProcessor(String own) {
		from_ = -1;
		to_ = -1;
		relative_ = 0;
		options_ = "";
		ownship_ = own;
	}

	public double getFrom() {
		return from_;
	}

	public double getTo() {
		return to_;
	}

	public void setOwnship(String own) {
		ownship_ = own;
	}

	public String getOwnship() {
		return ownship_;
	}

	/** Given a list of names that may include files or directories,
	 * return a list of files that contains:
	 * (1) all of the files in the original list and 
	 * (2) all files ending with ext in
	 * directories from the original list. */
	public static List<String> getFileNames(String[] names, final String ext, int i) {
		ArrayList<String> txtFiles = new ArrayList<String>();
		for (; i < names.length; i++) {
			File file = new File(names[i]);
			if (file.canRead()) {
				if (file.isDirectory()) {
					try(BufferedReader br = new BufferedReader(new FileReader(names[i]+"/encounters.txt"))) {
				    for(String line; (line = br.readLine()) != null; ) {
				    		line.trim();
				    		if (line.isEmpty() || line.startsWith("#")) {
				    			continue;
				    		}
				    		String filename = names[i]+"/"+line+"."+ext;
				       	File encounter = new File(filename);
				       	if (encounter.isFile()) {
				       		txtFiles.add(filename);
				       	} else {
				       		System.err.println("** Encounter file "+filename+" not found");
				       	}
				    }
				    // line is not visible here.
					} catch (IOException e) {
						File[] fs=file.listFiles(new FilenameFilter() {
							public boolean accept(File f, String name) {
								return name.endsWith("."+ext);
							}                       
						}); 
						for (File txtfile:fs) {
							txtFiles.add(txtfile.getPath());
						}
					}
				} else {
					txtFiles.add(file.getPath());
				}
			} else {
				System.err.println("File "+names[i]+" not found");
			}
		}
		return txtFiles;
	}

	public static String getHelpString() {
		String s = "";
		s += "  --ownship <id>\n\tSet ownship to aircraft with identifier <id>\n";
		s += "  --from t\n\tCheck from time t\n";
		s += "  --to t\n\tCheck up to time t\n";
		s += "  --at [t | t+k | t-k]\n\tCheck times t, [t,t+k], or [t-k,t]. ";
		s += "First time is denoted by +0. Last time is denoted by -0\n";
		return s;    
	}

	public boolean processOptions(String[] args, int i) {
		if (args[i].startsWith("--own") || args[i].startsWith("-own")) { 
			++i;
			ownship_ = args[i];
			options_ += args[i]+" ";
		} else if (args[i].equals("--from") || args[i].equals("-from")) {
			++i;
			from_ = Double.parseDouble(args[i]);
			options_ += args[i]+" ";
		} else if (args[i].equals("--to") || args[i].equals("-to")) {
			++i;
			to_ = Double.parseDouble(args[i]);
			options_ += args[i]+" ";
		} else if (args[i].equals("--at") || args[i].equals("-at")) {
			++i;
			options_ += args[i]+" ";        
			int k = args[i].indexOf("+");
			if (k == 0) {
				relative_ = Double.parseDouble(args[i])+0.001;
			} else if (k > 0) {
				from_ = Double.parseDouble(args[i].substring(0,k));
				relative_ = Double.parseDouble(args[i].substring(k));
			} else {
				k = args[i].indexOf("-");
				if (k == 0) {
					relative_ = Double.parseDouble(args[i])-0.001;
				} else if (k > 0) {
					to_ = Double.parseDouble(args[i].substring(0,k));
					relative_ = Double.parseDouble(args[i].substring(k));
				} else {
					k = args[i].indexOf("*");
					if (k > 0) {
						from_ = Double.parseDouble(args[i].substring(0,k));
						relative_ = Double.parseDouble(args[i].substring(k+1));
						from_ -= relative_;
						relative_ *= 2;
					} else {
						from_ = Double.parseDouble(args[i]);
						to_ = from_;
					}
				}
			}
		} else {
			return false;
		}
		return true;
	}

	public String getOptionsString() {
		return options_;
	}

	public void processFile(String filename, Daidalus daa) {
		double from = from_;
		double to = to_;
		DaidalusFileWalker dw = new DaidalusFileWalker(filename); 
		if (from < 0) {
			from = dw.firstTime();        
		}
		if (to < 0) { 
			to = dw.lastTime();
		}
		if (relative_ > 0) {
			to = from + relative_;
		}
		if (relative_ < 0) {
			from = to + relative_;
		}
		if (dw.goToTime(from) && from <= to) {
			while (!dw.atEnd() && dw.getTime() <= to) {
				double t = dw.getTime();
				dw.readState(daa);
				if (!ownship_.equals("")) {
					daa.resetOwnship(ownship_);
					if (daa.hasError()) {
						System.err.println("** Warning: State for ownship aircraft ("+ownship_+") not found at time. Skipping time "+
								t+" [s]");
						continue;
					}
				}
				processTime(daa,filename);
			} 
		}   
	}

	abstract public void processTime(Daidalus daa, String filename);

}
