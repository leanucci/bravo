require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Bill" do
  it "should setup a header hash" do
    @header = Bravo::Bill.header(0)
    @header.size.should == 3
    ["CantReg", "CbteTipo", "PtoVta"].each do |key|
      @header.has_key?(key).should == true
    end
  end

  describe "instance" do
    before(:each) {@bill = Bravo::Bill.new}

    it "should initialize according to Bravo defaults" do
      @bill.client.class.name.should == "Savon::Client"
      ["Token", "Sign", "Cuit"].each do |key|
        @bill.body["Auth"][key].should_not == nil
      end
      @bill.documento.should == Bravo.default_documento
      @bill.moneda.should == Bravo.default_moneda
    end

    it "should calculate it's cbte_tipo for Responsable Inscripto" do
      @bill.iva_cond = :responsable_inscripto
      @bill.cbte_type.should == "01"
    end

    it "should calculate it's cbte_tipo for Consumidor Final" do
      @bill.iva_cond = :consumidor_final
      @bill.cbte_type.should == "11"
    end

    it "raise error on nil iva cond" do
      @bill.iva_cond = 12
      expect{@bill.cbte_type}.to raise_error(StandardError)
    end

    it "should calculate the IVA array values" do
      @bill.iva_cond = :responsable_inscripto
      @bill.moneda = :peso
      @bill.net = 100.89
      @bill.aliciva_id = 2

      @bill.iva_sum.should be_within(0.05).of(21.18)
      @bill.total.should be_within(0.05).of(122.07)
    end

    it "should use give due date an service dates, or todays date" do
      @bill.net = 100
      @bill.aliciva_id = 2
      @bill.doc_num = "30710151543"
      @bill.iva_cond = :responsable_inscripto
      @bill.concepto = "Servicios"

      @bill.setup_bill

      detail = @bill.body["FeCAEReq"]["FeDetReq"]["FECAEDetRequest"]

      detail["FchServDesde"].should == Time.new.strftime('%Y%m%d')
      detail["FchServHasta"].should == Time.new.strftime('%Y%m%d')
      detail["FchVtoPago"].should   == Time.new.strftime('%Y%m%d')

      @bill.due_date       = Date.new(2011, 12, 10).strftime('%Y%m%d')
      @bill.fch_serv_desde = Date.new(2011, 11, 01).strftime('%Y%m%d')
      @bill.fch_serv_hasta = Date.new(2011, 11, 30).strftime('%Y%m%d')

      @bill.setup_bill

      detail = @bill.body["FeCAEReq"]["FeDetReq"]["FECAEDetRequest"]

      detail["FchServDesde"].should == "20111101"
      detail["FchServHasta"].should == "20111130"
      detail["FchVtoPago"].should   == "20111210"
    end

    {
      responsable_inscripto: %i[responsable_inscripto consumidor_final exento responsable_monotributo],
      responsable_monotributo: %i[responsable_inscripto consumidor_final exento responsable_monotributo]
    }.each do |own_iva, target_ivas|
      Bravo.own_iva_cond = own_iva
      target_ivas.each do |target_iva_cond|
        it "#{own_iva} should authorize a valid bill for #{target_iva_cond.to_s}" do
          @bill.net = 1000000
          @bill.aliciva_id = 2
          @bill.doc_num = "30710151543"
          @bill.iva_cond = target_iva_cond
          @bill.concepto = "Servicios"

          @bill.authorized?.should  == false
          @bill.authorize
          # pp @bill.response.error
          pp @bill.response unless @bill.authorized?
          @bill.authorized?.should  == true

          response = @bill.response

          # response.length.should     == 28
          response.cae.length.should == 14
        end
      end
    end
  end
end
