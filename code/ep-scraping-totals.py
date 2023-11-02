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

os.chdir('')
driver = webdriver.Firefox()

# GET PROJECTIUONS ==============================================================

url_proj = 'https://ig.ft.com/european-parliament-election-polls/'
driver.get(url_proj)
html = driver.page_source
soup = BeautifulSoup(html)

projections = []
group_list = soup.find('div', class_ = 'g-projected-seats-bars__bar-tall')
groups = group_list.find_all('div', class_='g-party-section')
for group in groups:
    group_name = group.find('div', class_='g-party-section__name').get_text()
    n_seats = group.find('span', class_='g-party-section__seats').get_text()
    group_dict = {'n_seats':n_seats, 'group_name':group_name}
    projections.append(group_dict)

keys = projections[0].keys()
with open('./data/ft-ep-totals-projections.csv', 'w') as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(projections)

# GET RESULTS =================================================================

url_res = 'https://ig.ft.com/european-elections-2019-results/'
driver.get(url_res)
html = driver.page_source
soup = BeautifulSoup(html)

results = []
group_list = soup.find('g', class_ = 'chart-all-parties__key')
groups = group_list.find_all('g')
for group in groups:
    texts = group.find_all('tspan')
    group_name = texts[0].get_text()
    n_seats = texts[1].get_text()
    group_dict = {'n_seats':n_seats, 'group_name':group_name}
    results.append(group_dict)

keys = results[0].keys()
with open('./data/ft-ep-totals-results.csv', 'w') as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(results)




