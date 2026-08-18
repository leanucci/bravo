require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Reference" do
  before(:each) { @reference = Bravo::Reference.new }

  it "should initialize with a Savon client" do
    @reference.client.class.name.should == "Savon::Client"
  end

  describe "#exchange_rate" do
    it "should return 1 for peso currency" do
      @reference.exchange_rate(:peso).should == 1
    end

    it "should fetch exchange rate for non-peso currency" do
      @reference.exchange_rate(:dolar).to_i.should be > 0
    end

    it "should fetch exchange rate for euro" do
      @reference.exchange_rate(:euro).to_i.should be > 0
    end
  end

  describe "#ultimo_comprobante" do
    it "should return an integer for a valid cbte_tipo" do
      result = @reference.ultimo_comprobante("01")
      result.should be_a(Integer)
      result.should be >= 0
    end

    it "should accept a custom punto de venta" do
      result = @reference.ultimo_comprobante("01", "0002")
      result.should be_a(Integer)
    end

    it "should use Bravo.sale_point as default" do
      result = @reference.ultimo_comprobante("06")
      result.should be_a(Integer)
      result.should be >= 0
    end
  end

  describe "#condicion_iva_receptor" do
    it "should return an array of conditions" do
      result = @reference.condicion_iva_receptor
      result.should be_a(Array)
      result.should_not be_empty
    end

    it "should return conditions with expected keys" do
      result = @reference.condicion_iva_receptor
      condition = result.first

      condition.should have_key(:id)
      condition.should have_key(:descripcion)
      condition.should have_key(:clase_comprobante)
    end

    it "should return integer id" do
      result = @reference.condicion_iva_receptor
      result.first[:id].should be_a(Integer)
    end

    it "should filter by clase_comprobante A" do
      result = @reference.condicion_iva_receptor("A")
      result.should be_a(Array)

      result.each do |condition|
        condition[:clase_comprobante].should == "A"
      end
    end

    it "should filter by clase_comprobante B" do
      result = @reference.condicion_iva_receptor("B")
      result.should be_a(Array)

      result.each do |condition|
        condition[:clase_comprobante].should == "B"
      end
    end

    it "should filter by clase_comprobante C" do
      result = @reference.condicion_iva_receptor("C")
      result.should be_a(Array)

      result.each do |condition|
        condition[:clase_comprobante].should == "C"
      end
    end

    it "should include responsable inscripto condition" do
      result = @reference.condicion_iva_receptor
      descriptions = result.map { |c| c[:descripcion] }

      descriptions.any? { |d| d =~ /responsable inscripto/i }.should == true
    end

    it "should include consumidor final condition" do
      result = @reference.condicion_iva_receptor
      descriptions = result.map { |c| c[:descripcion] }

      descriptions.any? { |d| d =~ /consumidor final/i }.should == true
    end
  end

  describe "#tipos_cbte" do
    it "should return an array of invoice types" do
      result = @reference.tipos_cbte
      result.should be_a(Array)
      result.should_not be_empty
      result.first.should have_key(:id)
      result.first.should have_key(:descripcion)
    end
  end

  describe "#alic_iva" do
    it "should return an array of IVA rates" do
      result = @reference.alic_iva
      result.should be_a(Array)
      result.should_not be_empty
      result.first.should have_key(:id)
      result.first.should have_key(:descripcion)
    end
  end
end
