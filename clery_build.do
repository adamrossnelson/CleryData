set more off
clear all
cls

// Builds a panel data set from files collected with
// https://github.com/adamrossnelson/CleryData/clery_grabber.py
//
// Files required for this do file hosted at:
// https://ope.ed.gov/campussafety/#/datafile/list and are:
// ( Crime2008EXCEL.zip, Crime2009EXCEL.zip, Crime2010EXCEL.zip
//   Crime2011EXCEL.zip, Crime2012EXCEL.zip, Crime2013EXCEL.zip
//   Crime2014EXCEL.zip, Crime2015EXCEL.zip, Crime2016EXCEL.zip )
// 

// REVISION HISTORY:
// Jan 2018:     Adam Ross Nelson - GitHub ReBuild
// Aug 2017:     Adam Ross Nelson - Initial Build

/*#############################################################################
      Maintained/more information at:
	  https://github.com/adamrossnelson/CleryData
  
##############################################################################*/

// Utilizes  version of sshnd (interactive file picker)
do https://raw.githubusercontent.com/adamrossnelson/sshnd/master/sshnd.do

capture log close                             // Close stray log files.
log using "$loggbl", append                   // Append sshnd established log file.
local sp char(13) char(10) char(13) char(10)  // Define spacer.
version 13                                    // Enforce version compatibility.
di c(pwd)                                     // Confrim working directory.

// Declare variables used in loop/logic below.
global root_was = ""
global f_zip = ""
local error_count = 0
local success = 0

// Loop through files years 2008 through 2016.
forvalues fname = 2008 / 2016 {
    // Begin while loop and establish maximum errors.
    while `success' == 0  & `error_count' < 11 {
        
        local last_fname = `fname' - 1
	// Test if global $f_zip contains file name & location from previous iteration.
        if strpos("$f_zip","\Crime`last_fname'") > 0 {
	    // If global $f_zip containes file name & location from previous iteration.
	    // calculate next file name & location. Assume next file in same location.
            global root_was = substr("$f_zip", 1, strpos("$f_zip","\Crime"))
            global f_zip = "$root_was" + "Crime`fname'EXCEL.zip"
        }

        // Test if global $f_zip specifies existing file.
        capture confirm file "$f_zip"
        if _rc == 0 & strpos("$f_zip","Crime`fname'EXCEL.zip") > 0 {
	    // If file exists, proceed with file specified in $f_zip
            di `sp'
            di "  Proceed with $f_zip"
        }
        else {
	    // If file does not exist, get input from user with file picker.
            capture window fopen f_zip "Specify the location of Crime`fname'EXCEL.zip" "*.zip"
        }

        di "  Teseting for Crime`fname'EXCEL.zip"
	// Test if global $f_zip matches Clery data naming conventions.
        if strpos("$f_zip","Crime`fname'EXCEL.zip") > 0 {
	    // Provide output for user and log interpretation.
            di "  Proceeding with $f_zip"
	    // Make and change to directory for file extraction.
            capture mkdir "`fname'"
            cd "`fname'"
	    // Extract clery data files.
            qui unzipfile "$f_zip", replace
	    // Return to base working directory.
            cd ..
            di `sp'
            local success = 1
        }
	// If global $f_zip does not match Clery data naming conventions.
        else if strpos("$f_zip","Crime`fname'EXCEL.zip") == 0 {
	    // Provide output for user and log interpretation.
            di "  Incorrect user input and/or error locating file."
            di "  There have been `error_count' out of 10 maximum errors."
            di `sp'
	    // Increment error count to avoid infinite loop.
            local error_count = `error_count' + 1
        }
    }
}

qui { 
noi di "#####################################################################"
noi di ""
noi di "      Saved log $loggbl"
noi di ""
noi di "######################################################################"
}
log close
