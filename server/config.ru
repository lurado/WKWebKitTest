require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra/cookies'
require 'logger'

def print_cookies
  puts "-- Request Cookies --"
  puts request.cookies.map { |k, v| "#{k} = #{v} "}.join("\n")
  puts "---------------------"
end

before do
  print_cookies
end

get '/' do
  
  <<-EOF
    <!DOCTYPE html>
    <html>
      <body>
        <h1>WKWebViewTest</h1>
        <a href="/">Reload</a><br/>
        <a href="/set_session_cookie">Set session cookie</a><br/>
        <a href="/set_persistent_cookie">Set persistent cookie</a><br/>
        <a href="itms://itunes.apple.com/de/app/id553834731?mt=8">itms://</a><br/>
        <a href="mailto:info@example.com">mailto:</a><br/>
        <a href="tel:011-123-4567">tel:</a><br/>
      </body>
    </html>
  EOF
end

get '/set_session_cookie' do
  response.set_cookie('session_cookie', value: 'soon gone')
  <<-EOF
    <html>
      <body>
        <h1>WKWebViewTest</h1>
        <a href="/">Home</a>
      </body>
    </html>
  EOF
end

get '/set_persistent_cookie' do
  response.set_cookie 'persistent_cookie', value: 'here to stay', max_age: 120
  <<-EOF
    <html>
      <body>
        <h1>WKWebViewTest</h1>
        <a href="/">Home</a>
      </body>
    </html>
  EOF
end

