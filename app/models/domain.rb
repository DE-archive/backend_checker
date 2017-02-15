class Domain < ApplicationRecord
  require 'csv'
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'
  require 'restclient'
  require 'addressable/uri'

  validates :rank, :tld, :url, presence: true

  scope :unknown_backend, -> {where(backend: nil)}
  scope :unchecked, -> {where(checked: false)}

  def self.import_domains_from_csv
    Dir.glob('public/alexa_data/*.csv') do |csv_file|
      csv_text = File.read(csv_file, headers: true)
      csv = CSV.parse(csv_text.downcase, headers: true)
      csv.each do |c|
        Domain.where(url: c.to_hash['url']).first_or_create!(url: c.to_hash['url'], rank: c.to_hash['rank'], tld: c.to_hash['tld'])
      end
    end
  end

  def self.find_ROR_backends
    until (set = Domain.unchecked.limit(1000)).empty?
      set.each do |dom|
        begin
          welcome_page = Nokogiri::HTML(RestClient.get(Addressable::URI.parse(dom.url).normalize.to_str))
          if self.find_rails_assets(welcome_page)
            dom.update_attributes(backend: 'RoR', checked: true)
          else
            dom.update_attributes(checked: true)
          end
        rescue
          dom.update_attributes(checked: true, error_message: 'RuntimeError')
        end
      end
    end
  end

  private
  def self.find_rails_assets (page)
    page.css('head link[rel="stylesheet"]').each do |style|
      if /\/assets\/\p{Alnum}+-\p{Alnum}{64}\.css/.match(style['href'])
        return true
      end
      page.css('head script').each do |script|
        if /\/assets\/\p{Alnum}+-\p{Alnum}{64}\.js/.match(script['src'])
          return true
        end
      end
    end
    false
  end
end
