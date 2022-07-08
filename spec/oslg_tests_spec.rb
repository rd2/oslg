require "oslg"

RSpec.describe OSlg do
  let(:clss) { Class.new  { extend OSlg } }
  let(:cls2) { Class.new  { extend OSlg } }
  let(:modu) { Module.new { extend OSlg } }

  it "can log within class instances" do
    clss.clean!
    clss.log(clss::INFO, "Logging within clss")

    expect(clss.status).to eq(clss::INFO)
    expect(clss.debug?).to be(false)
    expect(clss.info?).to be(true)
    expect(clss.warn?).to be(false)
    expect(clss.error?).to be(false)
    expect(clss.fatal?).to be(false)
    expect(clss.logs.is_a?(Array)).to be(true)
    expect(clss.logs.size).to eq(1)
    expect(clss.logs.first.is_a?(Hash)).to be(true)
    expect(clss.logs.first.key?(:level)).to be(true)
    expect(clss.logs.first[:level]).to eq(clss.status)
    expect(clss.logs.first.key?(:message))
    expect(clss.logs.first[:message]).to eq("Logging within clss")

    cls2.clean!
    cls2.log(cls2::WARN, "Logging within cls2")

    expect(cls2.status).to eq(cls2::WARN)
    expect(cls2.debug?).to be(false)
    expect(cls2.info?).to be(false)
    expect(cls2.warn?).to be(true)
    expect(cls2.error?).to be(false)
    expect(cls2.fatal?).to be(false)
    expect(cls2.logs.is_a?(Array)).to be(true)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.is_a?(Hash)).to be(true)
    expect(cls2.logs.first.key?(:level)).to be(true)
    expect(cls2.logs.first[:level]).to eq(cls2.status)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Logging within cls2")
  end

  it "can log within a Module" do
    modu.clean!
    modu.log(modu::INFO, "Logging within modu")

    expect(modu.status).to eq(modu::INFO)
    expect(modu.debug?).to be(false)
    expect(modu.info?).to be(true)
    expect(modu.warn?).to be(false)
    expect(modu.error?).to be(false)
    expect(modu.fatal?).to be(false)
    expect(modu.logs.is_a?(Array)).to be(true)
    expect(modu.logs.size).to eq(1)
    expect(modu.logs.first.is_a?(Hash)).to be(true)
    expect(modu.logs.first.key?(:level)).to be(true)
    expect(modu.logs.first[:level]).to eq(modu.status)
    expect(modu.logs.first.key?(:message))
    expect(modu.logs.first[:message]).to eq("Logging within modu")
  end
end
