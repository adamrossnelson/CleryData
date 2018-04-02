# 1. Introduction
Repo that collects Clery data (`clery_grabber.py`) and the assembles Clery Data (`clery_discipline.do`).

All files are intended to be reverse compatible to Version 13. Use of version control. Also uses `saveold`. Intended as reverse compatible, but not tested. **Notes about assumptions or limitations maintained in the do files.**

Each October 1st institutions are required to report Clery tallies. Generally each Spring the US Department of Education releases the data collected from those tallies. Spring 2017 release, for example, contained data from 2014 2015 & 2016. This repo provides scripts that will build a panel data set representing years 2005 through the most recently available year. If I'm behind on updating to include latest data, either submit an issue for me to resolve and/or fork update and submit a pull request.

The data comes from: https://ope.ed.gov/campussafety/#/datafile/list. This repo uses methods and procedures similar to those found in [StataIPEDSAll](https://github.com/adamrossnelson/StataIPEDSAll) and [colscore](https://github.com/adamrossnelson/colscore).

For background on the context and universe of higher education data see [StataIPEDSAll - Contextual Note](https://github.com/adamrossnelson/StataIPEDSAll/blob/master/README.md#3-contextual-note)


# 2. Table of Contents

<!-- TOC -->

- [1. Introduction](#1-introduction)
- [2. Table of Contents](#2-table-of-contents)
- [3. Usage](#3-usage)
    - [3.1. clery_grabber.py](#31-clerygrabberpy)
    - [3.2. clery_discipline.do](#32-clerydisciplinedo)
    - [3.3. clery_arrest.do](#33-cleryarrestdo)
        - [3.3.1. Run from online](#331-run-from-online)
        - [3.3.2. Suggested naming convention](#332-suggested-naming-convention)
    - [3.4. Future implementations](#34-future-implementations)
- [4. Testing And Develpment Log](#4-testing-and-develpment-log)

<!-- /TOC -->

# 3. Usage

 Clery data is distributed in wide format and provides one observation per year institution per campus. The Stata files in this repo reshape Clery data to a more research ready long shape and collapses data to one observation per year per institution.

## 3.1. clery_grabber.py

This Python script depends on Selenium and Geckodriver installations. This repo uses python to get Clery data because, unlike over at  [StataIPEDSAll](https://github.com/adamrossnelson/StataIPEDSAll) and [colscore](https://github.com/adamrossnelson/colscore) the data is not available from a stable URL. Open to suggestions on methods that might enable an opportunity implement `clery_grabber.py` in Stata.

## 3.2. clery_discipline.do

Uses the files collected with `clery_grabber.py`. Combines and reshapes disciplinary referral Clery data.

## 3.3. clery_arrest.do

Uses the files collected with `clery_grabber.py`. Combines and reshapes arrest Clery data.

### 3.3.1. Run from online

```Stata
do https://raw.githubusercontent.com/adamrossnelson/clerydata/master/clery_discipline.do
```
```Stata
do https://raw.githubusercontent.com/adamrossnelson/clerydata/master/clery_arrest.do
```

Stata will first ask for a preferred log file location (see section on suggested naming convention beloe). Following that it'll ask for the location of the `.zip` files downloaded using `clery_grabber.py`.

### 3.3.2. Suggested naming convention

When prompted for a log file name suggested name is `CleryDisc05to16.log` and/or `CleryArrest05to06.log` which will also produce `CleryDisc05to16.dta` and/or `CleryArrest05to06.dta` respectively at the log file location. (Update year reference as needed).

## 3.4. Future implementations

In addition to disciplinary referral data, Clery data also includes data regarding crimes committed and/or arrests that occured on and around campus. Future code will be aded to assemble panels of crime, arrest, and other Clery data.

# 4. Testing And Develpment Log

Date      | Developer             | Description
----------|-----------------------|----------------------
01Jul2017 | Adam Ross Nelson      | Initial build
28Jan2018 | Adam Ross Nelson      | GitHub rebuild
01Feb2018 | Adam Ross Nelson      | Added arrest panel
02Apr2018 | Adam Ross Nelson      | Added support for newest `Crime2017Excel.zip`

