require 'mstdn_ivory'
require 'nokogiri'
require 'open-uri'
require 'ruby-progressbar'
require 'io/console/size'

module MstdnAnalyzer
  class Analyzer
    attr_accessor :instance, :account, :cleint, :statuses

    COLORS = { black: "\e[30m", red: "\e[31m", green: "\e[32m", yellow: "\e[33m", blue: "\e[34m", mugenta: "\e[35m", cyan: "\e[36m", white: "\e[37m", reset: "\e[m"}
    BACKGROUND_COLORS = { black: "\e[40m", red: "\e[41m", green: "\e[42m", yellow: "\e[43m", blue: "\e[44m", mugenta: "\e[45m", cyan: "\e[46m", white: "\e[47m", reset: "\e[m"}

    def initialize(instance, username, **options)
      # オプションの解析
      limit = options[:limit] || 5000
      is_inore_reblog = options[:ignore_reblog]

      @instance = get_correct_instance(instance)
      @client = MstdnIvory::Client.new(@instance)
      @account = get_id_from_username(username)
      @statuses = get_statuses(limit, is_inore_reblog)
    end

    def result
      puts "Daily activity distribution(per hour)"
      puts_line
      display_activity_per_hour
      puts_line
      puts
      puts "Weekley activity distribution(per day)"
      puts_line
      display_activity_per_day
      puts_line
    end

    private

    def display_activity_per_hour
      activity = activity_per_hour
      max = (activity.max { |a, b| a.count <=> b.count}).count
      activity.each_with_index do |item, index|
        puts_graph_line(item.count.to_f / max.to_f, item.count, "#{sprintf("%02d:00", index)}")
      end
    end

    def activity_per_hour
      initial = Array.new(24) { Array.new }
      @statuses.inject(initial) do |activity, status|
        # 日本時間にべた書きで変更
        time = Time.parse(status.created_at).localtime("+09:00")
        activity[time.hour].append(status)
        activity
      end
    end

    def display_activity_per_day
      activity = activity_per_day
      wday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
      max = (activity.max { |a, b| a.count <=> b.count}).count
      activity.each_with_index do |item, index|
        puts_graph_line(item.count.to_f / max.to_f, item.count, wday[index])
      end
    end

    def activity_per_day
      initial = Array.new(7) { Array.new }
      @statuses.inject(initial) do |activity, status|
        # 日本時間にべた書きで変更
        time = Time.parse(status.created_at).localtime("+09:00")
        activity[time.wday].append(status)
        activity
      end
    end

    # ratio = count / 24時間のうち最大のcount (つまり24時間で最大の場合ratioは1)
    def puts_graph_line(ratio, count, description)
      _, width = IO.console_size
      graph_width = (width * 0.6).to_i
      cluster_width = (graph_width * 0.25).to_i

      cluster_color = [:white, :green, :yellow, :red]
      last_index = 0

      4.times do |i|
        print BACKGROUND_COLORS[cluster_color[i]]
        if ratio < (0.25 * (i + 1))
          print 
          print " " * ((ratio - (0.25 * i.to_f)) * cluster_width).to_i
          last_index = i
          break
        else
          print " " * cluster_width
          last_index = i
        end
      end

      print BACKGROUND_COLORS[:reset]
      print "\e[#{graph_width + 2}G"
      print COLORS[cluster_color[last_index]]
      print sprintf("%4d", count)
      print COLORS[:reset]
      print '   '
      puts description
    end

    def get_statuses(limit, is_inore_reblog)
      max_id = nil
      statuses = []

      statuses_count = @client.get("/api/v1/accounts/#{@account}").statuses_count
      max_statuses =  statuses_count> limit ? limit : statuses_count

      puts "[Correct Statuses] Correct #{max_statuses} statuses.Wait a minute."
      progress = ProgressBar.create(:title => "   Correcting...", :starting_at => 0, :total => max_statuses / 40)

      ((max_statuses - 1) / 40 + 1).times do
        temp = @client.get("/api/v1/accounts/#{@account}/statuses?max_id=#{max_id}&limit=40")
        break if temp.length.zero?
        statuses.concat temp
        max_id = temp[-1].id

        progress.increment
        if ((max_statuses - 1) / 40 + 1) < 400
          sleep(0.3) 
        else
          sleep(1.5)
        end
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

    def puts_line
      _, width = IO.console_size
      puts '#' * (width * 0.9)
    end
  end
end
