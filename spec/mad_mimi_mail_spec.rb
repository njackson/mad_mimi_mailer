require 'spec_helper'

describe MadMimiMail do
  let(:mimi) { double(MadMimi) }
  before :each do
    MadMimi.stub(:new) { mimi }
  end

  describe "#new(options)" do
    it "stores the options as #settings" do
      options = {:foo => "bar"}
      mimi_mail = MadMimiMail.new(options)
      mimi_mail.settings.should == options
    end

    it "creates a MadMimi object with the email and API key" do
      settings = MadMimiMail::Configuration.api_settings
      MadMimi.should_receive(:new).with(settings[:email], settings[:api_key]) { mimi }
      mimi_mail = MadMimiMail.new(settings)
    end
  end

  describe "#deliver!(mail)" do
    let(:mail) { double(Mail, :[] => nil).as_null_object }

    it "calls mimi#send_mail with :recipients from the to header" do
      field = double(:field, :to_s => "to field")
      mail.stub(:[]).with(:to) { field }
      mimi.should_receive(:send_mail).with(hash_including(:recipients => field.to_s), anything)
      mimi_mail = MadMimiMail.new({})
      mimi_mail.deliver!(mail)
    end

    [:from, :subject, :name, :promotion_name, :list_name, :raw_yaml].each do |field_name|
      it "calls mimi#send_mail with :#{field_name} from the #{field_name} header" do
        field = double(:field, :to_s => "#{field_name} field")
        mail.stub(:[]).with(field_name) { field }
        mimi.should_receive(:send_mail).with(hash_including(field_name => field.to_s), anything)
        mimi_mail = MadMimiMail.new({})
        mimi_mail.deliver!(mail)
      end
      context "when the #{field_name} header is blank" do
        it "calls mimi#send_mail with :#{field_name} as nil" do
          field = double(:field, :to_s => "")
          mail.stub(:[]).with(field_name) { field }
          mimi.should_receive(:send_mail).with(hash_including(field_name => nil), anything)
          mimi_mail = MadMimiMail.new({})
          mimi_mail.deliver!(mail)
        end
      end
    end

    it "calls mimi#send_mail with :raw_html from mail.html_part" do
      html_part = double(:part, :body => "<p>HTML part</p>")
      mail.stub(:html_part) { html_part }
      mimi.should_receive(:send_mail).with(hash_including(:raw_html => html_part.body), anything)
      mimi_mail = MadMimiMail.new({})
      mimi_mail.deliver!(mail)
    end

    it "calls mimi#send_mail with :raw_plain_text from mail.text_part" do
      text_part = double(:part, :body => "Text part")
      mail.stub(:text_part) { text_part }
      mimi.should_receive(:send_mail).with(hash_including(:raw_plain_text => text_part.body), anything)
      mimi_mail = MadMimiMail.new({})
      mimi_mail.deliver!(mail)
    end
    
    it "calls mimi#send_mail with the the default settings" do
      settings = {:promotion_name => "Promotion name", :list_name => "List name", :subject => "A Subject", :from => "from@example.com"}
      mimi.should_receive(:send_mail).with(hash_including(settings), anything)
      mimi_mail = MadMimiMail.new(settings)
      mimi_mail.deliver!(mail)
    end

    context "when mimi's response is a transaction code" do
      let(:transaction_id) { 12345567890 }
      let(:mimi) { double(MadMimi, :send_mail => transaction_id.to_s) }
      before :each do
        mail.stub(:html_part) { double(:html_part).as_null_object }
        mail.stub(:text_part) { double(:text_part).as_null_object }
        mimi.stub(:send_mail) { transaction_id.to_s }
      end

      it "defines #transaction_id on the mail object returning the transaction code as an integer" do
        mimi_mail = MadMimiMail.new({})
        mimi_mail.deliver!(mail)
        mail.should respond_to(:transaction_id)
        mail.transaction_id.should == transaction_id
      end
    end

    context "when mimi's response is not a transaction code" do
      let(:error_message) { "Error Message" }
      before :each do
        mimi.stub(:send_mail) { error_message }
        mail.stub(:errors).and_return([])
      end
      it "adds mimi's response to the mail#errors array" do
        mimi_mail = MadMimiMail.new({})
        mimi_mail.deliver!(mail)
        mail.errors.should == [error_message]
      end
      it "defines #transaction_id on the mail object returning 0" do
        mimi_mail = MadMimiMail.new({})
        mimi_mail.deliver!(mail)
        mail.transaction_id.should == 0
      end
    end
  end
end

