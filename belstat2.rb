require 'curb'
require 'nokogiri'
require 'csv'
require 'htmlentities'

# /Export/IndicatorCard?key=94537

# HTTP
def get_html (url)
  http = Curl.get(url)
  Nokogiri::HTML(http.body_str)
end

def get_html_with_header (url, key)
  http = Curl.get(url) do |http|
    http.headers['RubricatorKey'] = key
  end
  Nokogiri::HTML(http.body_str)
end

def post_html (url, id)
  http = Curl::Easy.http_post(url,
  Curl::PostField.content(id, 'on'),
  Curl::PostField.content('filter_1', 'on'))

  Nokogiri::HTML(http.body_str)
end

def get_items_by_xpath (html, xpath)
  array = html.xpath(xpath)
  if (array.length > 1)
    return array.map { |string| string.content }
  end
  return array
end


# CSV
def write_csv(file, array)
  CSV.open(file, "a+", {:col_sep => "±"}) do |csv|
    csv << array
  end
end


def write_csv_string (file, category)
  product['variations'].to_a.each do |variation|
    item = []
  
    title = "#{product['title']} - #{variation[0]}"
  
    price = variation[1][0].sub(",", ".").to_f
  
    img = product["img"]
  
    item.push(title, price, img)
  
    write_csv(file, item)
  end  
end

def main ()
  # Category page
  url = 'http://dataportal.belstat.gov.by/Indicators'
  html = get_html(url)

  # Categories
  ## Categories names
  indicators_name_xpath = '//label[@class="indicator-title"]/text()'
  raw_indicators_name = get_items_by_xpath(html, indicators_name_xpath)
  categories_names = raw_indicators_name.map { |string| string.strip }

  ## Categories IDs
  indicators_id_xpath = '//label[@class="indicator-title"]/@for'
  raw_categories_id = get_items_by_xpath(html, indicators_id_xpath)
  categories_id = raw_categories_id.map { |string| string.strip }


  ## Categories object
  categories = Hash[]
  
  categories_length = categories_id.length - 1

  for i in 0..categories_length do
    categories[categories_id[i]] = categories_names[i]
  end
  # Category object READY

  category_url = 'http://dataportal.belstat.gov.by/Indicators/Search'
  passport_id_xpath = '//button[@data-rub-key]/@data-rub-key'

  categories.each do | id, name |
    sleep(2)
    html = post_html(category_url, id)

    passports_ids = get_items_by_xpath(html, passport_id_xpath)
    
    file_id_xpath = '//button[@source-key]/@source-key'
    files_ids = get_items_by_xpath(html, file_id_xpath)
    files_urls = files_ids.map { |id| "http://dataportal.belstat.gov.by/Export/IndicatorCard?key=#{id}" }

    passports_ids_length = passports_ids.length - 1

    for j in 0..passports_ids_length do
      sleep(2)
      passport_url = 'http://dataportal.belstat.gov.by/Indicators/Detail'
      html = get_html_with_header(passport_url, passports_ids[j])

      # Characteristics
      header_xpath = '//h3/text()'
      id_xpath = '/html/body/div/div[1]/div[1]/div/text()'
      type_xpath = '/html/body/div/dl[1]/dd[1]/text()'
      mesure_xpath = '/html/body/div/dl[1]/dd[2]/text()'
      date_xpath = '/html/body/div/dl[1]/dd[3]/text()'
      end_date_xpath = '/html/body/div/dl[1]/dd[4]/text()'
      period_xpath = '/html/body/div/dl[1]/dd[5]/text()'
      okved_xpath = '/html/body/div/dl[1]/dd[6]/text()'
      update_date_xpath = '/html/body/div/dl[1]/dd[7]/text()'

      # Description
      descr_xpath = '/html/body/div/dl[2]/dd[1]/text()'
      stat_term_xpath = '/html/body/div/dl[2]/dd[2]/text()'
      territory_xpath = '/html/body/div/dl[2]/dd[3]/text()'
      time_xpath = '/html/body/div/dl[2]/dd[4]/text()'
      keywords_xpath = '/html/body/div/dl[2]/dd[5]/text()'
      comments_xpath = '/html/body/div/dl[2]/dd[6]/text()'
      respondents_xpath = '/html/body/div/dl[2]/dd[7]/text()'
      source_xpath = '/html/body/div/dl[2]/dd[8]/text()'

      # Contact Info
      org_xpath = '/html/body/div/dl[3]/dd[1]/text()'
      department_xpath = '/html/body/div/dl[3]/dd[2]/text()'
      person_xpath = '/html/body/div/dl[3]/dd[3]/text()'
      phone_xpath = '/html/body/div/dl[3]/dd[4]/text()'


      # Characteristics
      header = HTMLEntities.new.decode(get_items_by_xpath(html, header_xpath)).gsub("\n","")
      id_code = HTMLEntities.new.decode(get_items_by_xpath(html, id_xpath)).gsub("\n","")
      type = HTMLEntities.new.decode(get_items_by_xpath(html, type_xpath)).gsub("\n","")
      mesure = HTMLEntities.new.decode(get_items_by_xpath(html, mesure_xpath)).gsub("\n","")
      date = HTMLEntities.new.decode(get_items_by_xpath(html, date_xpath)).gsub("\n","")
      end_date = HTMLEntities.new.decode(get_items_by_xpath(html, end_date_xpath)).gsub("\n","")
      period = HTMLEntities.new.decode(get_items_by_xpath(html, period_xpath)).gsub("\n","")
      okved = HTMLEntities.new.decode(get_items_by_xpath(html, okved_xpath)).gsub("\n","")
      update_date = HTMLEntities.new.decode(get_items_by_xpath(html, update_date_xpath)).gsub("\n","")

      # Description
      descr = HTMLEntities.new.decode(get_items_by_xpath(html, descr_xpath)).gsub("\n","")
      stat_term = HTMLEntities.new.decode(get_items_by_xpath(html, stat_term_xpath)).gsub("\n","")
      territory = HTMLEntities.new.decode(get_items_by_xpath(html, territory_xpath)).gsub("\n","")
      time = HTMLEntities.new.decode(get_items_by_xpath(html, time_xpath)).gsub("\n","")
      keywords = HTMLEntities.new.decode(get_items_by_xpath(html, keywords_xpath)).gsub("\n","")
      comments = HTMLEntities.new.decode(get_items_by_xpath(html, comments_xpath)).gsub("\n","")
      respondents = HTMLEntities.new.decode(get_items_by_xpath(html, respondents_xpath)).gsub("\n","")
      source = HTMLEntities.new.decode(get_items_by_xpath(html, source_xpath)).gsub("\n","")

      # Contact Info
      org = HTMLEntities.new.decode(get_items_by_xpath(html, org_xpath)).gsub("\n","")
      department = HTMLEntities.new.decode(get_items_by_xpath(html, department_xpath)).gsub("\n","")
      person = HTMLEntities.new.decode(get_items_by_xpath(html, person_xpath)).gsub("\n","")
      phone = HTMLEntities.new.decode(get_items_by_xpath(html, phone_xpath)).gsub("\n","")

      # File.write('passport.html', html)

      passport = [ name, header, files_urls[j], id_code, type, mesure, date, end_date, period, okved, update_date, descr, stat_term, territory, time, keywords, comments, respondents, source, org, department, person, phone ]

      write_csv("data-tut.csv", passport)
      puts "BaX!"
    end


    # write_csv("#{name}.csv", files_urls)

    # puts files_ids
  end
  
end

main()