require "oslg"

RSpec.describe OSlg do
  let(:cls1) { Class.new  { extend OSlg } }
  let(:cls2) { Class.new  { extend OSlg } }
  let(:mod1) { Module.new { extend OSlg } }
  let(:mod2) { Module.new { extend OSlg } }

  it "can log within class instances" do
    expect(cls1.tag(cls1::DEBUG)).to eq("DEBUG")
    expect(cls1.msg(cls1::DEBUG)).to eq("Debugging ...")

    expect(cls1.clean!).to eq(cls1::INFO)
    expect(cls1.log(cls1::INFO, "Logging within cls1")).to eq(cls1::INFO)

    expect(cls1.status).to eq(cls1::INFO)
    expect(cls1.debug?).to be(false)
    expect(cls1.info?).to be(true)
    expect(cls1.warn?).to be(false)
    expect(cls1.error?).to be(false)
    expect(cls1.fatal?).to be(false)
    expect(cls1.logs.is_a?(Array)).to be(true)
    expect(cls1.logs.size).to eq(1)
    expect(cls1.logs.first.is_a?(Hash)).to be(true)
    expect(cls1.logs.first.key?(:level)).to be(true)
    expect(cls1.logs.first[:level]).to eq(cls1.status)
    expect(cls1.logs.first.key?(:message))
    expect(cls1.logs.first[:message]).to eq("Logging within cls1")

    expect(cls2.reset(cls2::DEBUG)).to eq(cls2::DEBUG)
    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.log(cls2::WARN, "Logging within cls2")).to eq(cls2::WARN)

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

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.invalid("x").nil?).to be(true)
    expect(cls2.logs.empty?).to be(true)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.invalid("x", Array).nil?).to be(true)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Invalid 'x' (Array)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.invalid("x", 4, -1).nil?).to be(true)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Invalid 'x' (4)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.invalid("x", String, 2).nil?).to be(true)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Invalid 'x' arg #2 (String)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.invalid("x", String, 2, nil).nil?).to be(true)
    expect(cls2.logs.empty?).to be(true)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.mismatch("x", "y", Hash, "foo").nil?).to be(true)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("'x' String? expecting Hash (foo)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.mismatch(nil, nil).nil?).to be(true)
    expect(cls2.logs.empty?).to be(true)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.mismatch("x", "String", String, "foo").nil?).to be(true)
    expect(cls2.logs.empty?).to be(true)

    array = (1..60).to_a
    l1 = 3 * 9 # "1, " + "2, " + "3, " ...+ "9, "
    l2 = 4 * (59 - 9) # "10, " + "11, " + 12, ...+ "59, "
    l3 = 2 # "60"
    l4 = 2 # "[]"
    expect(array.to_s.size).to eq(l1 + l2 + l3 + l4)
    expect(cls2.mismatch("x", "String", Array, array).nil?).to be(true)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    str1 = "'x' String? expecting Array " # 28 chars
    str2 = "([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,  ...)"
    expect(str1.size + str2.size).to eq(28 + 60 + "(".length + " ...)".length)
    expect(cls2.logs.first[:message].length).to eq(str1.size + str2.size)
    expect(cls2.logs.first[:message]).to eq(str1 + str2)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.hashkey("x", {bar: 0}, "k", "foo")).to be(nil)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    str = "Missing 'k' key in 'x' Hash (foo)"
    expect(cls2.logs.first[:message]).to eq(str)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.hashkey("x", {foo: 0}, :foo, "bar")).to be(nil)
    expect(cls2.logs.empty?).to be(true)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.hashkey("x", [0, 1], :foo, "bar")).to be(nil)
    expect(cls2.logs.empty?).to be(true)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.empty("x", "foo")).to be(nil)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Empty 'x' (foo)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.empty({foo: 0}, :foo)).to be(nil)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Empty '{:foo=>0}' (foo)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.empty(nil, 0)).to be(nil)
    expect(cls2.logs.empty?).to be(true)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.zero("x", "foo")).to be(nil)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Zero 'x' (foo)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.zero({foo: 0}, :foo)).to be(nil)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Zero '{:foo=>0}' (foo)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.zero(nil, 0)).to be(nil)
    expect(cls2.logs.empty?).to be(true)

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.negative("x", "foo")).to be(nil)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Negative 'x' (foo)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.negative({foo: 0}, :foo)).to be(nil)
    expect(cls2.logs.size).to eq(1)
    expect(cls2.logs.first.key?(:message))
    expect(cls2.logs.first[:message]).to eq("Negative '{:foo=>0}' (foo)")

    expect(cls2.clean!).to eq(cls2::DEBUG)
    expect(cls2.negative(nil, 0)).to be(nil)
    expect(cls2.logs.empty?).to be(true)
  end

  it "can log within a Module" do
    mod2.clean!
    mod2.log(mod2::INFO, "Logging within mod2")

    expect(mod2.status).to eq(mod2::INFO)
    expect(mod2.debug?).to be(false)
    expect(mod2.info?).to be(true)
    expect(mod2.warn?).to be(false)
    expect(mod2.error?).to be(false)
    expect(mod2.fatal?).to be(false)
    expect(mod2.logs.is_a?(Array)).to be(true)
    expect(mod2.logs.size).to eq(1)
    expect(mod2.logs.first.is_a?(Hash)).to be(true)
    expect(mod2.logs.first.key?(:level)).to be(true)
    expect(mod2.logs.first[:level]).to eq(mod2.status)
    expect(mod2.logs.first.key?(:message))
    expect(mod2.logs.first[:message]).to eq("Logging within mod2")

    expect(mod2.reset(mod2::DEBUG)).to eq(mod2::DEBUG)
    expect(mod2.clean!).to eq(mod2::DEBUG)
    expect(mod2.log(mod2::WARN, "Logging within mod2")).to eq(mod2::WARN)

    expect(mod2.status).to eq(mod2::WARN)
    expect(mod2.debug?).to be(false)
    expect(mod2.info?).to be(false)
    expect(mod2.warn?).to be(true)
    expect(mod2.error?).to be(false)
    expect(mod2.fatal?).to be(false)
    expect(mod2.logs.is_a?(Array)).to be(true)
    expect(mod2.logs.size).to eq(1)
    expect(mod2.logs.first.is_a?(Hash)).to be(true)
    expect(mod2.logs.first.key?(:level)).to be(true)
    expect(mod2.logs.first[:level]).to eq(mod2.status)
    expect(mod2.logs.first.key?(:message))
    expect(mod2.logs.first[:message]).to eq("Logging within mod2")
  end
end
