# ==============================================================================
# file name: ep-scraping-totals.R
# authors: Bernhard Clemm
# date: 31 Oct 2023
# ==============================================================================

# SETUP ========================================================================

from selenium import webdriver
from bs4 import BeautifulSoup
import csv
import os

os.chdir('/Users/bernhard/Dropbox/Bewerbungen/202310 FT/ft-application')
driver = webdriver.Firefox()