=begin
OAuth2 providerのデモクライアントアプリ

$ rails c
> user = User.create!(:username => 'demo')
> client = OAuth::Client.create!(:name => 'demo', :redirect_uri => 'http://localhost:4567/oauth/authorize')
> puts client.identifier, client.secret
> exit
この二つをしたのCLIENT_TOKENとCLIENT_SECRETにコピー

$ bundle exec rails server 

# 別のターミナルで下記を実行し、http://localhost:4567/ を開き、ユーザ名 demoでログイン
$ bundle ruby demo_client.rb
=end
require 'rubygems'
require 'sinatra'
require 'oauth2'

enable :sessions

CLIENT_TOKEN = 'fSPY3wrtA89A6EASg3gmFw'
CLIENT_SECRET = 'fVYQqRDyhZS0sDpKtGExRpaN7T4DSJOTKlTAp5vAXw8Ba_Tp-qct_wUZ-eXli3civNZRHDTNy58InjnKZzOONg'
SERVER_URL = 'http://localhost:3000'

client = OAuth2::Client.new(
  CLIENT_TOKEN,
  CLIENT_SECRET,
  :authorize_url => '/oauth2/authorize',
  :token_url => '/oauth2/token',
  :site => SERVER_URL
)
AUTHORIZE_URL = client.auth_code.authorize_url(:redirect_uri => "http://localhost:4567/oauth/authorize")

get '/' do
  if session[:access_token]
    access_token = OAuth2::AccessToken.new(
      client,
      session[:access_token],
      refresh_token: session[:refresh_token]
    )
    response = access_token.request(:get, "#{SERVER_URL}/demo")
    <<__HTML__
<body>
Call API: 'GET #{SERVER_URL}/demo'<br/>
<pre>#{response.body}</pre>
<hr/>
<a href="/oauth/deauthorize">Sign out</a>
</body>
__HTML__
  else
    <<__HTML__
<body>
<a href="#{AUTHORIZE_URL}">Sign in</a>
</body>
__HTML__
  end
end

get '/oauth/authorize' do
  access_token = client.auth_code.get_token(
    params[:code],
    :redirect_uri => 'http://localhost:4567/oauth/authorize'
  )
  session[:access_token] = access_token.token
  session[:refresh_token] = access_token.refresh_token
  redirect to('/')
end

get '/oauth/deauthorize' do
  session[:access_token] = session[:refresh_token] = nil
  redirect to('/')
end
