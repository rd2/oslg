require "oslg"

RSpec.describe OSlg do
  let(:oslg) { Class.new { extend OSlg } }

  it "can log" do
    oslg.clean!
    oslg.log(OSlg::INFO, "Initiated OSlg")

    expect(oslg.status).to eq(OSlg::INFO)
    expect(oslg.debug?).to be(false)
    expect(oslg.info?).to  be(true)
    expect(oslg.warn?).to  be(false)
    expect(oslg.error?).to be(false)
    expect(oslg.fatal?).to be(false)
    expect(oslg.logs.is_a?(Array)).to be(true)
    expect(oslg.logs.size).to eq(1)
    expect(oslg.logs.first.is_a?(Hash)).to be(true)
    expect(oslg.logs.first.key?(:level)).to be(true)
    expect(oslg.logs.first[:level]).to eq(oslg.status)
    expect(oslg.logs.first.key?(:message))
    expect(oslg.logs.first[:message]).to eq("Initiated OSlg")
  end
end
