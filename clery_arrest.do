set more off
clear all
cls

// REVISION HISTORY:
// Mar 2018:  Adam Ross Nelson - Pending, update to include 2017.zip
// Feb 2018:     Adam Ross Nelson - GitHub ReBuild
// Aug 2017:     Adam Ross Nelson - Initial Build

// Builds panel data set of Clery arrest referrals.

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

// Declar program flow variables.
local need_to_ask = 0
local fname = 2008
local max_error = 0
global f_zip = ""

// While loop to work through files 2008 through 2017
while `fname' <= 2017 {
	// Display output for log file.
	di `sp' "Working on `fname'"
	if `fname' == 2008 | `need_to_ask' == 1 {
		while strpos("$f_zip","Crime`fname'EXCEL.zip") == 0 & `max_error' < 6 {
			capture window fopen f_zip "Specify location of Crime`fname'EXCEL.zip" "*.zip"
			local need_to_ask = 0
			local ++ max_error
		}
		if `max_error' == 6 {
			di as error "ERROR: Maximum of six errors exceeded."
			di as error "       File picker was looking for location of Crime`fname'EXCEL.zip"
			error 119
		}
	}
	local root_was = substr("$f_zip", 1, strpos("$f_zip","\Crime")) 
	qui unzipfile "`root_was'Crime`fname'EXCEL.zip", replace
	di "Unzipped `root_was'Crime`fname'EXCEL.zip"
	
	// Advance to next year.
	local ++ fname
	// Check for next year's file in same location as previous year's.
	capture confirm file "`root_was'Crime`fname'EXCEL.zip"
	// If next year's file does not exist, triger file-picker.
	if _rc == 601 {
		local need_to_ask = 1
		local ++ max_error
	}
	// 
	if `max_error' == 6 {
		di as error "ERROR: Maximum of six errors exceeded."
		di as error "       Could not find location of Crime`fname'EXCEL.zip"
		error 119
	}
}

local yindex = 2008
// Build panel dataset from excel data files. Begin with 05 06 07 series.
foreach ys in 050607 060708 070809 080910 091011 101112 111213 121314 131415 141516 {
// foreach ys in 080910 091011 101112 111213 121314 131415 {
    foreach froot in oncampusarrest`ys' noncampusarrest`ys' publicpropertyarrest`ys' residencehallarrest`ys' {
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
                local newsuf = substr("`vroot'",1,3)
                rename `vroot' `newroot'`newsuf'
            }
            di "Saving `yindex'/`froot'.dta"
            rename * *ar
            rename unitidar unitid
            rename isYrar isYr
            saveold "`yindex'/`froot'.dta", replace version(13)
        }
    }
    use `yindex'/oncampusarrest`ys'.dta, clear
    merge 1:1 unitid isYr using `yindex'/noncampusarrest`ys'.dta, nogenerate
    merge 1:1 unitid isYr using `yindex'/publicpropertyarrest`ys'.dta, nogenerate
    merge 1:1 unitid isYr using `yindex'/residencehallarrest`ys'.dta, nogenerate

    foreach cname in weapon drug liquor {
        local newsuf = substr("`cname'",1,3)
        label variable onc`newsuf'ar "Oncampus `cname' related arrests"
        label variable non`newsuf'ar "Noncampus `cname' related arrests"
        label variable pub`newsuf'ar "Public prpty `cname' related arrests"
        label variable res`newsuf'ar "Reshall `cname' related arresrs"
    }
    saveold "`yindex'CleryArrests.dta", version(13) replace
    local yindex = `yindex' + 1
}

use 2008CleryArrests.dta, clear
foreach y in 2009 2011 2013 2015 2017 {
    merge 1:1 unitid isYr using `y'CleryArrests.dta, update nogenerate
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
