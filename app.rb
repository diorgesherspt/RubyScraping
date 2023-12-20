require 'sinatra'
require 'mongo'
require 'json'
require 'securerandom'
require 'dotenv'
Dotenv.load('.env')

configure do
  database_url = ENV['DATABASE_URL']
  set :mongo_client, Mongo::Client.new(database_url)
end


module ScrapingWorker
  def self.run(process_id, url, mongo_client)
    scraped_data = perform_scraping(url)
    mongo_client[:processes].delete_many('data_processed.site' => url)
    mongo_client[:processes].update_one({ _id: process_id }, { '$set' => { status: 'Completed', data_processed: scraped_data } })
  end

  def self.perform_scraping(url)
    require 'watir'
  
    browser = Watir::Browser.new
  
    begin
      browser.goto("https://similarweb.com/website/#{url}")
      
      total_visits = browser.element(xpath: '//*[@id="overview"]/div/div/div/div[4]/div[2]/div[1]/p[2]')
      total_visits.wait_until(timeout: 30, &:present?)

      top_countries = browser.element(xpath: '//*[@id="geography"]/div/div/div[2]/div[2]/div')
      top_countries.wait_until(timeout: 30, &:present?)

      avg_visition_duration= browser.element(xpath: '//*[@id="overview"]/div/div/div/div[4]/div[2]/div[4]/p[2]')
      avg_visition_duration.wait_until(timeout: 30, &:present?)

      bounce_rate= browser.element(xpath: '//*[@id="overview"]/div/div/div/div[4]/div[2]/div[2]/p[2]')
      bounce_rate.wait_until(timeout: 30, &:present?)

      pages_per_visit= browser.element(xpath: '//*[@id="overview"]/div/div/div/div[4]/div[2]/div[3]/p[2]')
      pages_per_visit.wait_until(timeout: 30, &:present?)

      category_element = browser.element(xpath: '//*[@id="overview"]/div/div/div/div[5]/div/dl/div[6]/dd/a')

      if category_element.exists?
        category = category_element.text
      else
        category = 'Unknown'
      end
      
      { total_visits: total_visits.text,
        top_countries: top_countries.text,
        avg_visition_duration: avg_visition_duration.text,
        bounce_rate: bounce_rate.text,
        pages_per_visit: pages_per_visit.text,
        site: url,
        category: category

      }
    rescue StandardError => e
      puts "Erro durante o scraping: #{e.message}"
      { error: element.text }
    ensure
      browser.quit
    end
  end
end

post '/salve_info' do
  process_id = SecureRandom.uuid

  settings.mongo_client[:processes].insert_one(_id: process_id, status: 'Processing')

  Thread.new do
    ScrapingWorker.run(process_id, params[:url], settings.mongo_client)
  end

  status 201

  content_type :json
  { id: process_id }.to_json
end

get '/status/:id' do
  process = settings.mongo_client[:processes].find(_id: params[:id]).first
  if process
    { status: process[:status] }.to_json
  else
    status 404
    { error: 'Process not found' }.to_json
  end
end

post '/get_info/:url' do
  process = settings.mongo_client[:processes].find('data_processed.site' => params[:url]).first
  if process
    if process[:status] == 'Completed'
      { data_processed: process[:data_processed] }.to_json
    else
      status 422
      { status: process[:status] }.to_json
    end
  else
    status 404
    { error: 'Process not found' }.to_json
  end
end
