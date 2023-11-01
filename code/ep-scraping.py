# ==============================================================================
# file name: ep-scraping.R
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

# SCRAPING FUNCTION =============================================================

def scrape_ft(url, country_list_class, country_class, country_name_class, groups_list_class, group_class, group_name_class, seats_class):
	driver.get(url)
	html = driver.page_source
	soup = BeautifulSoup(html)
	country_list = soup.find('div', class_ = country_list_class)
	countries = country_list.find_all('div', class_ = country_class)
	# initialize list of dictionaries
	countries_out = []
	# loop through countries
	for country in countries:
		n_seats = None
		country_name = None
		country_subname = None
		epp_seats = sd_seats = alde_seats = greens_seats = efdd_seats = gue_seats = ni_seats = new_seats = ecr_seats = enf_seats = re_seats = id_seats = None
		country_name = country.find('h3', class_ = country_name_class).get_text()
		print(country_name)
		country_subname = country.find('h5', class_='g-country-projected-seats__subname')
		if country_subname is not None: 
			country_subname = country_subname.get_text()
		groups_list = country.find('div', class_= groups_list_class)
		groups = groups_list.find_all('div', class_=group_class)
		for group in groups:
			group_name = group.find('div', class_=group_name_class).get_text()
			print(group_name)
			n_seats = group.find('div', class_=seats_class).get_text()
			if group_name == 'EPP':
				epp_seats = n_seats
			elif group_name == 'S&D':
				sd_seats = n_seats
			elif group_name == 'ALDE':
				alde_seats = n_seats
			elif group_name == 'RE':
				re_seats = n_seats
			elif group_name == 'Greens EFA':
				greens_seats = n_seats
			elif group_name == 'EFDD':
				efdd_seats = n_seats
			elif group_name == 'GUE NGL':
				gue_seats = n_seats
			elif group_name == 'NI':
				ni_seats = n_seats
			elif group_name == 'New':
				new_seats = n_seats
			elif group_name == 'ECR':
				ecr_seats = n_seats
			elif group_name == 'ENF':
				enf_seats = n_seats
			elif group_name == 'ID':
				id_seats = n_seats
			else:
				print('Error: group name not in pre-defined groups')
		# store country information in a dictionary
		country_dict = {'name': country_name,
						'subname': country_subname,
						'epp': epp_seats,
						'sd': sd_seats,
						'alde': alde_seats,
						'greens': greens_seats,
						'efdd': efdd_seats,
						'gue': gue_seats,
						'ni': ni_seats,
						'new': new_seats,
						'ecr': ecr_seats,
						'enf': enf_seats,
						'id': id_seats,
						're': re_seats}
		countries_out.append(country_dict)
	return countries_out

# GET PROJECTIUONS HTML =========================================================

projections = scrape_ft(
	url = 'https://ig.ft.com/european-parliament-election-polls/', 
	country_list_class = 'g-country-projected-seats-list', 
	country_class = 'g-country-projected-seats', 
	country_name_class = 'g-country-projected-seats__name', 
	groups_list_class = 'g-country-projected-seats__bars',
	group_class = 'group',
	group_name_class = 'group__name', 
	seats_class = 'group__label')

# export as csv
keys = projections[0].keys()
with open('./data/ft-ep-projections.csv', 'w') as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(projections)

# GET RESULTS HTML ==============================================================

results = scrape_ft(
	url = 'https://ig.ft.com/european-elections-2019-results/', 
	country_list_class = 'country-results__list', 
	country_class = 'country-results-card', 
	country_name_class = 'country-results-card__name', 
	groups_list_class = 'country-results-group-bars',
	group_class = 'country-results-group-bars__group',
	group_name_class = 'country-results-group-bars__group-name', 
	seats_class = 'country-results-group-bars__group-label')

# export as csv
keys = results[0].keys()
with open('./data/ft-ep-results.csv', 'w') as output_file:
    dict_writer = csv.DictWriter(output_file, keys)
    dict_writer.writeheader()
    dict_writer.writerows(results)
