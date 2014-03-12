require "rubygems"
require "sinatra"
require "i18n"
require "indextank"
require "open-uri"
require "nokogiri"
require "sinatra/content_for"

use Rack::Session::Cookie

set :views, File.dirname(__FILE__) + "/templates"

# Loading locales
Dir.glob("i18n/*.yml").each { |locale| I18n.load_path << locale}
I18n.locale = "pt-BR"

before do
  if params[:lang]
    set_locale(params[:lang])
  end
end

# HOME
get "/" do redirect "/#{current_locale}/xTiss" end

navigation = [
# Visão Geral do xTiss
  { "url" => "xTiss",                                                      "view_path" => "xTiss/index"},
# Entendendo o Sistema
  { "url" => "understanding_the_system",                          "view_path" => "understanding_the_system/index"},
# Menu Principal
  { "url" => "menu_main",                                                "view_path" => "menu_main/index"},
# Principal
  { "url" => "principal",                                                     "view_path" => "principal/index"},
# Arquivos
  { "url" => "files",                                                     "view_path" => "files/index"},
# Configurações
  { "url" => "config",                                                     "view_path" => "config/index"},
# Logs de Movimentação
  { "url" => "logs",                                                     "view_path" => "logs/index"},
# Downloads
  { "url" => "downloads",                                                     "view_path" => "downloads/index"},
# Contato
  { "url" => "contact",                                                     "view_path" => "contact/index"},
]

navigation.each do |item|
  get "/#{item["url"]}" do redirect "/#{current_locale}/#{item["url"]}", 303 end
  get "/:locale/#{item["url"]}" do |locale|
    if params[:lang]
      set_locale(params[:lang])
    else
      set_locale(locale)
    end
    erb "#{item["view_path"]}".to_sym
  end
end

# COMMANDS DESCRIPTIONS
commands = [
  # flow
  "if", "else", "while", "break", "function", "callfunction", "execute", "exit",
  # readcard
  "getcardvariable", "system.readcard", "system.inputtransaction",
  # ui
  "menu", "menuwithheader", "displaybitmap", "display", "cleandisplay", "system.gettouchscreen",
  # print
  "print", "printbig", "printbitmap", "printbarcode", "checkpaperout", "paperfeed",
  # input
  "inputfloat", "inputformat", "inputinteger", "inputoption", "inputmoney",
  # crypto
  "crypto.crc", "crypto.encryptdecrypt", "crypto.lrc", "crypto.xor",
  # file
  "downloadfile", "filesystem.filesize", "filesystem.listfiles", "filesystem.space", "file.open", "file.close", "file.read", "file.write", "readfile", "readfilebyindex", "editfile", "deletefile",
  # iso
  "iso8583.initfieldtable", "iso8583.initmessage", "iso8583.putfield", "iso8583.endmessage", "iso8583.transactmessage", "iso8583.analyzemessage", "iso8583.getfield",
  # serialport
  "openserialport", "writeserialport", "readserialport", "closeserialport",
  # datetime
  "getdatetime", "time.calculate", "adjustdatetime",
  # conectivity
  "predial", "preconnect", "shutdownmodem", "network.checkgprssignal", "network.hostdisconnect", "network.ping", "network.send", "network.receive",
  # pinpad
  "pinpad.open", "pinpad.loadipek", "pinpad.getkey", "pinpad.getpindukpt", "pinpad.display", "pinpad.close",
  # emv
  "emv.open", "emv.loadtables", "emv.cleanstructures", "emv.adddata", "emv.getinfo", "emv.inittransaction", "emv.processtransaction", "emv.finishtransaction", "emv.removecard", "emv.settimeout", "system.readcard", "system.inputtransaction",
  # variables
  "integervariable", "stringvariable", "integerconvert", "convert.toint", "inttostring", "stringtoint", "integeroperator", "string.tohex", "string.fromhex",
  # string
  "string.charat", "string.elementat", "string.elements", "string.find", "string.getvaluebykey", "string.trim", "string.insertat", "string.length", "string.pad", "string.removeat", "string.replace", "string.replaceat", "string.substring", "substring", "joinstring", "input.getvalue",
  # smartcard
  "smartcard.insertedcard", "smartcard.closereader", "smartcard.startreader", "smartcard.transmitapdu",
  # utils
  "mathematicaloperation", "system.beep", "system.checkbattery", "system.info", "system.restart", "unzipfile", "waitkey", "waitkeytimeout", "readkey", "wait"
]

not_found do
  erb :not_found
end

# Helpers
def set_locale(locale)
  if I18n.available_locales.include?(locale.to_sym)
    session[:locale] = locale
    return I18n.locale = locale
  end

  redirect request.fullpath.gsub("/#{locale}/", "/#{current_locale}/")
end

def current_locale
  session[:locale].nil? ? "pt-BR" : session[:locale]
end

def link_to(name, url)
  "<a href='/#{current_locale}/#{url}'>#{name}</a>"
end

def is_group_active?(group)
  "in" if group == request.path_info.split("/")[2]
end

def is_group_item_active?(group, item=nil)
  if group == request.path_info.split("/")[2]
    return "active" if request.path_info.split("/").length == 3 && item.nil?
    return "active" if item == request.path_info.split("/").last
  end
end

def option_select(value, text)
  selected = session[:locale] == value ? ' selected' : ''
  "<option value=#{value}#{selected}>#{text}</option>"
end




