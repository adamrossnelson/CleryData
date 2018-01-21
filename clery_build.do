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

global root_was = ""
global f_zip = ""
local error_count = 0

forvalues fname = 2008 / 2016 {
    local success = 0
    while `success' == 0  & `error_count' < 11 {
        
        local last_fname = `fname' - 1
        if strpos("$f_zip","\Crime`last_fname'") > 0 {
            global root_was = substr("$f_zip", 1, strpos("$f_zip","\Crime"))
            global f_zip = "$root_was" + "Crime`fname'EXCEL.zip"
        }

        capture confirm file "$f_zip"
        if _rc == 0 & strpos("$f_zip","Crime`fname'EXCEL.zip") > 0{
            di `sp'
            di "  Proceed with $f_zip"
        }
        else {
            capture window fopen f_zip "Specify the location of Crime`fname'EXCEL.zip" "*.zip"
        }

        di "  Teseting for Crime`fname'EXCEL.zip"
        if strpos("$f_zip","Crime`fname'EXCEL.zip") > 0 {
            di "  Proceeding with $f_zip"
            capture mkdir "`fname'"
            cd "`fname'"
            qui unzipfile "$f_zip", replace
            cd ..
            di `sp'
            local success = 1
        }
        else if strpos("$f_zip","Crime`fname'EXCEL.zip") == 0 {
            di "  Incorrect user input and/or error locating file."
            di "  There have been `error_count' out of 10 maximum errors."
            di `sp'
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
