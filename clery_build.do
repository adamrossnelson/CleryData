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

local yindex = 2008
// Build panel dataset from excel data files. Begin with 05 06 07 series.
foreach ys in 050607 060708 070809 080910 091011 101112 111213 121314 131415 {
// foreach ys in 080910 091011 101112 111213 121314 131415 {
    foreach froot in oncampusdiscipline`ys' noncampusdiscipline`ys' publicpropertydiscipline`ys' residencehalldiscipline`ys' {
        capture confirm file "`yindex'/`froot'.xls"
        if _rc == 0 {
            di "Importing `yindex'/`froot'.xls"
            import excel using "`yindex'/`froot'.xls", clear firstrow case(lower)
            if `yindex' < 2011 {
                gen unitid = round(unitid_p/100)
            }
            else {
                gen unitid = round(unitid_p/1000)
            }
            order unitid, first
            drop unitid_p instnm branch address city state zip sector_desc ///
            men_total women_total total filter* sector_cd
            collapse (sum) weapon* drug* liquor*, by(unitid)
            di "Reshaping `yindex'/`froot'.xls"
            reshape long weapon drug liquor, i(unitid) j(isYr)
            replace isYr = isYr + 2000
            tab isYr
            local newroot = substr("`froot'",1,3)
            foreach vroot in weapon drug liquor {
                local newsuf = substr("`vroot'",1,4)
                rename `vroot' `newroot'`newsuf'
            }
            di "Saving `yindex'/`froot'.dta"
            saveold "`yindex'/`froot'.dta", replace version(13)
        }
    }
    use `yindex'/oncampusdiscipline`ys'.dta, clear
    merge 1:1 unitid isYr using `yindex'/noncampusdiscipline`ys'.dta, nogenerate
    merge 1:1 unitid isYr using `yindex'/publicpropertydiscipline`ys'.dta, nogenerate
    di "Checking for `yindex'/residencehalldiscipline`ys'.xls"
    capture confirm file "`yindex'/residencehalldiscipline`ys'.xls"
    if _rc == 0 {
        merge 1:1 unitid isYr using `yindex'/residencehalldiscipline`ys'.dta, nogenerate
    }
    if `yindex' < 2010 {
        gen double resweap = .
        gen double resdrug = .
        gen double resliqu = .
    }
    foreach cname in weapon drug liquor {
        local newsuf = substr("`cname'",1,4)
        label variable onc`newsuf' "Oncampus `cname' related disc refs"
        label variable non`newsuf' "Noncampus `cname' related disc refs"
        label variable pub`newsuf' "Public prpty `cname' related disc refs"
        label variable res`newsuf' "Reshall `cname' related disc refs"
    }
    saveold "`yindex'CleryDiscipline.dta", version(13) replace
    local yindex = `yindex' + 1
}

use 2008CleryDiscipline.dta, clear
foreach y in 2009 2011 2013 2015 2016 {
    merge 1:1 unitid isYr using `y'CleryDiscipline.dta, update nogenerate
}

cd ..
saveold "$dtagbl", replace version(13)

qui { 
    noi di "#####################################################################"
    noi di ""
    noi di "      Saved log $loggbl"
    noi di ""
    noi di "######################################################################"
}
log close
