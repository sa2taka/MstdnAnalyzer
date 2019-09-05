require 'mstdn_ivory'
require 'nokogiri'
require 'open-uri'
require 'ruby-progressbar'

module MstdnAnalyzer
  class Analyzer
    attr_accessor :instance, :account, :cleint, :statuses

    def initialize(instance, username, **options)
      # オプションの解析
      limit = options[:limit] || 5000
      is_inore_reblog = options[:ignore_reblog]

      @instance = get_correct_instance(instance)
      @client = MstdnIvory::Client.new(@instance)
      @account = get_id_from_username(username)
      @statuses = get_statuses(limit, is_inore_reblog)
    end

    private

    def get_statuses(limit, is_inore_reblog)
      max_id = nil
      statuses = []

      statuses_count = @client.get("/api/v1/accounts/#{@account}").statuses_count
      max_statuses =  statuses_count> limit ? limit : statuses_count

      puts "[Correct Statuses] Correct #{max_statuses} statuses.Wait a minute."
      progress = ProgressBar.create(:title => "   Correcting...", :starting_at => 0, :total => max_statuses / 40)

      (max_statuses / 40 + 1).times do
        temp = @client.get("/api/v1/accounts/#{@account}/statuses?max_id=#{max_id}&limit=40")
        break if temp.length.zero?
        statuses.concat temp
        max_id = temp[-1].id

        progress.increment
        sleep(0.3)
      end
      puts "\e[1G    Complete!"

      if is_inore_reblog
        statuses.select { |s| !(s.reblog)}
      else
        statuses
      end
    end

    def get_correct_instance(instance)
      print "[ ]Confirm Instance"
      client = MstdnIvory::Client.new(instance)
      begin
        info = client.get('/api/v1/instance')
      rescue
        puts "Error: Instance missing. Check the URL is correct."
        exit
      end

      puts "\e[1G[✓]Confirm Instance"
      instance
    end

    def get_id_from_username(username)
      print "[ ]Confirm Username"
      charset = nil

      begin
        account_page = open("#{@instance}/@#{username}") do |f|
        charset = f.charset
        f.read
      end
      rescue
        puts "Error: Account missing.Check the account name is correct."
        exit
      end

      doc = Nokogiri::HTML.parse(account_page, nil, charset)

      doc.css("link[rel=salmon]").each do |link|
        puts "\e[1G[✓]Confirm Username"
        return link.values[0].match(/\d+$/)
      end

      # ここまで来たらaccount_idを取得できていないのでミス
      puts "Error: Account missing.Check the account name is correct."
    end
  end
end
