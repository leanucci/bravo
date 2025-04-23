require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Client" do
  it "should setup a header hash" do
    @header = Bravo::Client.header(0)
    expect(@header.size).to eq 3
    ["CantReg", "CbteTipo", "PtoVta"].each do |key|
      expect(@header).to have_key(key)
    end
  end

  describe "instance" do
    let(:client) { client = Bravo::Client.new }

    it "should initialize according to Bravo defaults" do
      expect(client.soap_client.class.name).to eq "Savon::Client"
      ["Token", "Sign", "Cuit"].each do |key|
        expect(client.body["Auth"][key]).to_not be_nil
      end
      expect(client.documento).to eq Bravo.default_documento
      expect(client.moneda).to eq Bravo.default_moneda
    end

    it "should calculate it's cbte_tipo for Responsable Inscripto" do
      client.iva_cond = :responsable_inscripto
      expect(client.cbte_type).to eq "01"
    end

    it "should calculate it's cbte_tipo for Consumidor Final" do
      client.iva_cond = :consumidor_final
      expect(client.cbte_type).to eq "06"
    end

    it "raise error on nil iva cond" do
      client.iva_cond = 12
      expect{client.cbte_type}.to raise_error(Bravo::NullOrInvalidAttribute)
    end

    it "should fetch non Peso currency's exchange rate" do
      client.moneda = :dolar
      expect(client.exchange_rate).to be_positive
    end

    it "should return 1 for Peso currency" do
      client.moneda = :peso
      expect(client.exchange_rate).to eq 1
    end

    it "should calculate the IVA array values" do
      client.iva_cond = :responsable_inscripto
      client.moneda = :peso
      client.net = 100.89
      client.aliciva_id = 2

      expect(client.iva_sum).to be_within(0.05).of(21.18)
      expect(client.total).to be_within(0.05).of(122.07)
    end

    it "should use give due date an service dates, or todays date" do
      client.net = 100
      client.aliciva_id = 2
      client.doc_num = "30710151543"
      client.iva_cond = :responsable_inscripto
      client.concepto = "Servicios"

      client.setup_bill

      detail = client.body["FeCAEReq"]["FeDetReq"]["FECAEDetRequest"]

      expect(detail["FchServDesde"]).to eq Time.new.strftime('%Y%m%d')
      expect(detail["FchServHasta"]).to eq Time.new.strftime('%Y%m%d')
      expect(detail["FchVtoPago"]).to eq Time.new.strftime('%Y%m%d')

      client.due_date       = Date.new(2011, 12, 10).strftime('%Y%m%d')
      client.fch_serv_desde = Date.new(2011, 11, 01).strftime('%Y%m%d')
      client.fch_serv_hasta = Date.new(2011, 11, 30).strftime('%Y%m%d')

      client.setup_bill

      detail = client.body["FeCAEReq"]["FeDetReq"]["FECAEDetRequest"]

      expect(detail["FchServDesde"]).to eq "20111101"
      expect(detail["FchServHasta"]).to eq "20111130"
      expect(detail["FchVtoPago"]).to eq "20111210"
    end

    Bravo::BILL_TYPE[Bravo.own_iva_cond].keys.each do |target_iva_cond|
      it "should authorize a valid bill for #{target_iva_cond.to_s}" do
        client.net = 1000000
        client.aliciva_id = 2
        client.doc_num = "30710151543"
        client.iva_cond = target_iva_cond
        client.concepto = "Servicios"

        expect(client.authorized?).to be_falsey
        expect(client.authorize).to be_truthy
        expect(client.authorized?).to be_truthy

        response = client.response

        expect(response.length).to eq 28
        expect(response.cae.length).to eq 14
      end
    end
  end
end
