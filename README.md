# 1. Introduction
Repo that collects Clery data (`clery_grabber.py`) and the assembles Clery Data (`clery_discipline.do`).

All files are intended to be reverse compatible to Version 13. Use of version control. Also uses `saveold`. Intended as reverse compatible, but not tested. **Notes about assumptions or limitations maintained in the do files.**

The Clear Act requires that each October 1st institutions report Clery tallies. Each Spring the US Department of Education releases the data collected from those tallies. The Spring 2017 release, for example, contained data from 2014 2015 & 2016. This repo provides scripts that will build a panel data set representing years 2005 through the most recently available year.

The data comes from: https://ope.ed.gov/campussafety/#/datafile/list. This repo uses methods and procedures similar to those found in [StataIPEDSAll](https://github.com/adamrossnelson/StataIPEDSAll) and [colscore](https://github.com/adamrossnelson/colscore).

For background on the context and universe of higher education data, see [StataIPEDSAll - Contextual Note](https://github.com/adamrossnelson/StataIPEDSAll/blob/master/README.md#3-contextual-note)


# 2. Table of Contents

<!-- TOC -->

- [1. Introduction](#1-introduction)
- [2. Table of Contents](#2-table-of-contents)
- [3. Usage](#3-usage)
    - [3.1. clery_grabber.py](#31-clerygrabberpy)
    - [3.2. Run from online](#32-run-from-online)
    - [3.3. Future implementations](#33-future-implementations)
- [4. Testing And Develpment Log](#4-testing-and-develpment-log)

<!-- /TOC -->

# 3. Usage

The US Department of Education distributes Clery data in "wide" format and provides one row/observation per campus (some institutions have more than one campus for Clery purposes). The Stata files in this repo reshape Clery data to a more research ready "long" shape and collapses data to one observation per year per institution.

## 3.1. clery_grabber.py

Do File Name & Description | Suggested Nameing Convention
---------------------------|-----------------------------
`clery_grabber.py` <br> Grabs Clery data files from `https://ope.ed.gov/campussafety/#/datafile/list`. Python script depends on Selenium and Geckodriver installations. | Not applicable
`clery_discipline.do` <br> Uses the files downloaded from `https://ope.ed.gov/campussafety/#/datafile/list` to build a panel dataset of disciplinary referrals. | When prompted for log name <br> `CleryDisc05to17.log`
`clery_arrest.do` <br> Uses the files downloaded from `https://ope.ed.gov/campussafety/#/datafile/list` to build a panel dataset of campus arrests. | When prompted for log name <br> `CleryArrest05to17.log`


This repo uses python to get Clery data because, unlike over at  [StataIPEDSAll](https://github.com/adamrossnelson/StataIPEDSAll) and [colscore](https://github.com/adamrossnelson/colscore) the data is not available from a stable URL. Open to suggestions on methods that might enable an opportunity to implement `clery_grabber.py` in Stata.

## 3.2. Run from online

```Stata
do https://raw.githubusercontent.com/adamrossnelson/clerydata/master/clery_discipline.do
```
```Stata
do https://raw.githubusercontent.com/adamrossnelson/clerydata/master/clery_arrest.do
```

Stata will first ask for a preferred log file location (see above for suggested naming conventions). Following log file specification Stata will ask for the location of the `.zip` files downloaded using `clery_grabber.py`.

## 3.3. Future implementations

Besides disciplinary referral data, Clery data also includes data regarding crimes committed that occurred (were reported) on and around campus. Future code will be added to assemble panels of crime, and other Clery data.

# 4. Testing And Develpment Log

Date      | Developer             | Description
----------|-----------------------|----------------------
01Jul2017 | Adam Ross Nelson      | Initial build
28Jan2018 | Adam Ross Nelson      | GitHub rebuild
01Feb2018 | Adam Ross Nelson      | Added arrest panel
02Apr2018 | Adam Ross Nelson      | Added support for newest `Crime2017Excel.zip`
23Aug2018 | Adam Ross Nelson      | Revised syntax for Mac/PC cross compatibility.

