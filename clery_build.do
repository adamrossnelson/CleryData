set more off
clear all
cls

// REVISION HISTORY:
// Jan 2018:     Adam Ross Nelson - GitHub ReBuild
// Aug 2017:     Adam Ross Nelson - Initial Build

// Builds a panel data set from files collected with
// https://github.com/adamrossnelson/CleryData/clery_grabber.py
//
// Files required for this do file hosted at:
// https://ope.ed.gov/campussafety/#/datafile/list and are:
// ( Crime2008EXCEL.zip, Crime2009EXCEL.zip, Crime2010EXCEL.zip
//   Crime2011EXCEL.zip, Crime2012EXCEL.zip, Crime2013EXCEL.zip
//   Crime2014EXCEL.zip, Crime2015EXCEL.zip, Crime2016EXCEL.zip )
// 
// Assumes user has placed all files in same directory location. File picker
// will ask for location of Crime2008EXCEL.zip and then look for subsequent
// files in the same location. If not found, file picker will ask again for
// location of the missing file.

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

// Loop through files years 2008 through 2016.
forvalues fname = 2008 / 2016 {
    local success = 0
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
            di `sp' "  Proceed with $f_zip"
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
            di "  There have been `error_count' out of 10 maximum errors." `sp'
	        // Increment error count to avoid infinite loop.
            local error_count = `error_count' + 1
        }
    }
}

// Build panel dataset from excel data files. Begin with 05 06 07 series.
foreach froot in oncampusdiscipline050607 noncampusdiscipline050607 publicpropertydiscipline050607 {
	import excel using "2008/`froot'.xls", clear firstrow
	gen unitid = round(UNITID_P/10)
	order unitid, first
	drop UNITID_P INSTNM BRANCH Address City State Zip sector_desc ///
	men_total women_total total FILTER05 FILTER06 FILTER07 sector_cd
	collapse (sum) Weapon5 Drug5 Liquor5 Weapon6 Drug6 Liquor6 Weapon7 Drug7 Liquor7, by(unitid)
	reshape long Weapon Drug Liquor, i(unitid) j(isYr)
	replace isYr = isYr + 2000
	local newroot = substr("`froot'",1,3)
	foreach vroot in Weapon Drug Liquor {
		local newsuf = substr("`vroot'",1,4)
		rename `vroot' `newroot'`newsuf'
	}
	saveold "2008/`froot'.dta", replace version(13)
}
use 2008/oncampusdiscipline050607.dta, clear
merge 1:1 unitid isYr using 2008/noncampusdiscipline050607.dta, nogenerate
merge 1:1 unitid isYr using 2008/publicpropertydiscipline050607.dta, nogenerate
gen double resWeap = .
gen double resDrug = .
gen double resLiqu = .
foreach cname in Weapon Drug Liquor {
	local newsuf = substr("`cname'",1,4)
	label variable onc`newsuf' "Oncampus `cname' related disc refs"
	label variable non`newsuf' "Noncampus `cname' related disc refs"
	label variable pub`newsuf' "Public prpty `cname' related disc refs"
	label variable res`newsuf' "Reshall `cname' related disc refs"
}


qui { 
noi di "#####################################################################"
noi di ""
noi di "      Saved log $loggbl"
noi di ""
noi di "######################################################################"
}
log close
