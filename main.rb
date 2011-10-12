require 'rubygems'
require 'restfulie'
require 'sinatra'

class RequisicaoPagamento
  attr_accessor :numeroCartao,:dataExpiracao,:valor
  
  def initialize(numeroCartao="00", dataExpiracao="00/00", valor=0.0)
    @numeroCartao= numeroCartao
    @dataExpiracao= dataExpiracao
    @valor= valor
  end
  
  def to_xml 
    xml = %{<?xml version="1.0" ?>
            <requisicao>
              <numeroCartao>#{self.numeroCartao}</numeroCartao>
              <dataExpiracao>#{self.dataExpiracao}</dataExpiracao>
              <valor>#{self.valor}</valor>
            </requisicao>}
    xml
  end
    
end

class RespostaPagamento
  attr_accessor :codigoRetorno, :mensagem
  
  def initialize(codigoRetorno,mensagem)
    @codigoRetorno = codigoRetorno
    @mensagem = mensagem
  end
  
  def to_xml
    xml = %{<?xml version="1.0" ?>
        <resposta>
          <codigoRetorno>#{self.codigoRetorno}</codigoRetorno>
          <mensagem>#{self.mensagem}</mensagem>
        </resposta>}
    xml
  end


end

get "/" do
  erb :home
end

post "/sendxml" do
  content_type 'text/xml'
  request = RequisicaoPagamento.new(params[:numero_cartao], params[:data_expiracao], params[:valor])
  xml = Hash["xml",request.to_xml]
  response = Restfulie.at("http://localhost:8080/pocfoobar/pagamento/autorizacao").as("application/x-www-form-urlencoded").post(xml)
  if response.code == 200 then
    codigo = response.resource["resposta"]["codigoRetorno"]
    mensagem = response.resource["resposta"]["mensagem"]
    @resposta = RespostaPagamento.new(codigo, mensagem)
    @resposta.mensagem
    @resposta.to_xml
  else
    puts "so lamento"
  end
end