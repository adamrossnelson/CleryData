# REVISION HISTORY:
# Jan 2018:     Adam Ross Nelson - GitHub ReBuild
# Aug 2017:     Adam Ross Nelson - Initial Build
#
# Quickly grabs Clery data files from
# https://ope.ed.gov/campussafety/#/datafile/list
#
# Requires selenium and geckodriver-v0.19.1-win64.zip from 
# https://github.com/mozilla/geckodriver/releases
#
# Use Stata to build research ready panel dataset see:
# https://github.com/adamrossnelson/CleryData
#
# Intended for use with IPEDS panel data files built from
# https://github.com/adamrossnelson/StataIPEDSAll

from time import sleep
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import WebDriverException
from selenium import webdriver

try:
    browser = webdriver.Firefox()
except WebDriverException:
    print('\n\n    There was an error. Verify Firefox is properly installed.', end='\n')
    print('    Verify geckodriver installation: \n    https://github.com/mozilla/geckodriver/releases', end='\n')
    print('    Report issues at: https://github.com/adamrossnelson/CleryData/issues', end='\n\n')

try:
    # At time of last successful test, Clery data website was: https://ope.ed.gov/campussafety/#/datafile/list
    # Visit Clery data website.
    browser.get('https://ope.ed.gov/campussafety/#/datafile/list')
except WebDriverException:
    # Report errors and next steps if website not available.
    print('\n\n    There was an error. Verify web address is stil current: \n    https://ope.ed.gov/campussafety/#/datafile/list', end='\n')
    print('    Verify working internet connection.', end='\n')
    print('    If web address out of date, report issues at: https://github.com/adamrossnelson/CleryData/issues', end='\n\n')
    
while True:
    elems = browser.find_elements_by_css_selector("ul.file-list li:first-child a")
    if elems != []:
        print('\n\n    Succes: Visit Firefox window to complete file downloads.', end='\n')
        print('    Thanks for using: https://github.com/adamrossnelson/CleryData.', end='\n\n')
        for elem in elems:
            elem.click()
            # See also: https://stackoverflow.com/questions/1176348/access-to-file-download-dialog-in-firefox
        break
    elif elems == []:
        print('\n\n    There was an error. Possible change in css selector syntax.', end='\n')
        print('    Report issues at: \n    https://github.com/adamrossnelson/CleryData/issues', end='\n\n')
        # Sleep for one second to reduce demand on server.
        sleep(1)
