require 'cgi'
require 'httparty'
require 'json'
require 'nokogiri'
require 'colorize'
require 'net/http'
require 'uri'

class String
    def magenta;        "\e[35m#{self}\e[0m" end
end

def require_gem(name)
    Gem::Specification.find_by_name(name)
rescue Gem::LoadError
    puts "Gem '#{name}' Is Not Installed. Installing..."
    system("gem install #{name}")
    Gem::Specification.find_by_name(name)
end

required_gems = %w[cgi httparty json nokogiri colorize net-http-persistent]

required_gems.each { |gem| require_gem(gem) }
puts "
████████╗██╗██╗  ██╗████████╗ ██████╗ ██╗  ██╗   ██████╗  █████╗ ███╗   ██╗
╚══██╔══╝██║██║ ██╔╝╚══██╔══╝██╔═══██╗██║ ██╔╝   ██╔══██╗██╔══██╗████╗  ██║
   ██║   ██║█████╔╝    ██║   ██║   ██║█████╔╝    ██████╔╝███████║██╔██╗ ██║
   ██║   ██║██╔═██╗    ██║   ██║   ██║██╔═██╗    ██╔══██╗██╔══██║██║╚██╗██║
   ██║   ██║██║  ██╗   ██║   ╚██████╔╝██║  ██╗██╗██████╔╝██║  ██║██║ ╚████║
   ╚═╝   ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
                               GitHub: LeetIDA                                    
".magenta

class IDA
    def initialize
        print '[?] Username: '.colorize(:light_blue)
        @username = gets.chomp
        @username.delete!('@') if @username[0] == '@' || @username.include?('@')
        @server_log = nil
        @data_json = nil
        admin
    end

    def admin
        send_request
        _to_json
        output
    end

    def send_request
        headers = {
            'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 IDA'
        }
        @response = HTTParty.get("https://www.tiktok.com/@#{@username}", headers: headers)
        if @response.code == 403
            handle_forbidden_error
        else
            @server_log = @response.body
        end
    end

    def handle_forbidden_error
        puts "403 Forbidden Error: Your request to TikTok was blocked.".colorize(:red)
        puts "Possible actions to resolve this issue:".colorize(:yellow)
        puts "- Ensure your IP is not blacklisted by TikTok.".colorize(:light_blue)
        puts "- Try using a different IP address or proxy.".colorize(:light_blue)
        puts "- Wait and try again later if TikTok's rate limiting is causing the block.".colorize(:light_blue)
        exit
    end
    
    def _to_json
        begin
            script_tag = Nokogiri::HTML(@response.body).at('script#__UNIVERSAL_DATA_FOR_REHYDRATION__')
            script_text = script_tag.text.strip
            @json_data = JSON.parse(script_text)['__DEFAULT_SCOPE__']['webapp.user-detail']['userInfo']
        rescue StandardError
            puts '[X] Error: Username Not Found.'
            exit
        end
    end
    
    def get_user_id
        begin
            data = @json_data
            data["user"]["id"]
        rescue StandardError
            'Unknown'
        end
    end
    
    def secUid
        begin
            data = @json_data
            data["user"]["secUid"]
        rescue StandardError
            'Unknown'
        end
    end
    
    def generate_report_url
        base_url = 'https://www.tiktok.com/aweme/v2/aweme/feedback/?'

        browser_name = ['Mozilla', 'Chrome', 'Safari', 'Firefox'].sample
        browser_platform = ['Win32', 'Mac', 'Linux'].sample
        browser_version = "5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) #{browser_name}/#{rand(80..120)}.0 Safari/537.36"
        current_region = ['US', 'UK', 'CA', 'AU', 'IN', 'BR', 'FR', 'DE', 'IT', 'ES'].sample
        device_id = rand(10**18..10**19).to_s
        is_fullscreen = [true, false].sample.to_s
        os = ['windows', 'mac', 'linux'].sample
        priority_region = ['US', 'UK', 'CA', 'AU', 'IN', 'BR', 'FR', 'DE', 'IT', 'ES'].sample
        region = ['US', 'UK', 'CA', 'AU', 'IN', 'BR', 'FR', 'DE', 'IT', 'ES'].sample
        screen_height = rand(600..1080).to_s
        screen_width = rand(800..1920).to_s
        tz_name = ['America/New_York', 'Europe/London', 'Asia/Tokyo', 'Australia/Sydney', 'Asia/Kolkata', 'America/Los_Angeles', 'Europe/Paris', 'Asia/Dubai', 'America/Sao_Paulo', 'Asia/Shanghai'].sample
        webcast_language = ['en', 'es', 'fr', 'de', 'ja', 'pt', 'it', 'ru', 'ar', 'hi'].sample

        aid_values = ['9101', '91011', '9009', '90093', '90097', '90095', '90064', '90061', '90063', '9006', '9008', '90081', '90082', '9007', '1001', '1002', '1003', '1004', '9002', '90011', '90010', '9001', '9010', '9011', '90112', '90113', '9003', '90031', '90032', '90033', '90034', '90035', '90036', '9004', '9005', '9012', '910121', '910122', '91012', '91013', '910131', '910132', '910133', '910134', '910135', '91014', '9013', '9102']

        params = {
            aid: aid_values.sample,
            app_language: 'en',
            app_name: 'tiktok_web',
            browser_language: 'en-US',
            browser_name: browser_name,
            browser_online: 'true',
            browser_platform: browser_platform,
            browser_version: browser_version,
            channel: 'tiktok_web',
            cookie_enabled: 'true',
            current_region: current_region,
            device_id: device_id,
            device_platform: 'web_pc',
            focus_state: 'true',
            from_page: 'user',
            history_len: '1',
            is_fullscreen: is_fullscreen,
            is_page_visible: 'true',
            lang: 'en',
            nickname: CGI.escape(@username),
            object_id: get_user_id,
            os: os,
            priority_region: priority_region,
            reason: '9010',
            referer: 'https://www.tiktok.com/',
            region: region,
            report_type: 'user',
            reporter_id: get_user_id,
            root_referer: 'https://www.tiktok.com/',
            screen_height: screen_height,
            screen_width: screen_width,
            secUid: secUid,
            target: get_user_id,
            tz_name: tz_name,
            webcast_language: webcast_language
        }

        report_url = base_url + params.map { |k, v| "#{k}=#{v}" }.join('&')
        report_url
    end

    def output
        report_url = generate_report_url
        tiktok_url = report_url

        loop do
            proxies = load_proxies_from_file('proxy.txt')
            if proxies.empty?
                puts "[X] Proxy File Is Empty.".colorize(:red)
                exit
            end

            proxies.each do |proxy|
                begin
                    current_time = Time.now.strftime('%H:%M:%S')
                    uri = URI(tiktok_url)
                    req = Net::HTTP::Post.new(uri)
                    http_proxy = "http://#{proxy}"
                    req['proxy'] = http_proxy
                    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 2, read_timeout: 2) do |http|
                        http.request(req)
                    end

                    if res.body && !res.body.empty?
                        response_body = JSON.parse(res.body)
                        if response_body['status_code'] == 0
                            puts "[#{current_time}]".colorize(:red) + " #{'Proxy: ' + proxy} Report Sent To #{@username}".colorize(:green)
                        else
                            puts "[#{current_time}]".colorize(:red) + " #{'Proxy: ' + proxy} Report Failed. Response: #{res.body}".colorize(:yellow)
                        end
                    else
                        puts "[#{current_time}]".colorize(:red) + " #{'Proxy: ' + proxy} Empty or Invalid Response".colorize(:red)
                    end

                rescue JSON::ParserError => e
                    puts "[X] Something Went Wrong: #{e.message}".colorize(:red)
                    puts 'Press Enter to close the program'.colorize(:red)
                    gets.chomp
                    exit()
                rescue => e
                    puts "[X] Something Went Wrong: #{e.message}".colorize(:red)
                    puts 'Press Enter to close the program'.colorize(:red)
                    gets.chomp
                    exit()
                end
                sleep 3 # 3 Second Delay Between Each Request Cuz TikTok Rate Limt 
            end
        end
    end

    def load_proxies_from_file(file_path)
        unless File.exist?(file_path)
            puts "Proxy File Does Not Exist. Creating One...".colorize(:red)
            File.write(file_path, "")
            exit
        end

        proxies = File.readlines(file_path).map(&:chomp)
        if proxies.empty?
            puts "Proxy File Is Empty.".colorize(:red)
            exit
        end

        proxies
    end
end

IDA.new