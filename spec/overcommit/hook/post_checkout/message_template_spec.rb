require 'spec_helper'

describe Overcommit::Hook::PostCheckout::MessageTemplate do
  let(:config)  { Overcommit::ConfigurationLoader.default_configuration }
  let(:context) { double('context') }

  subject(:hook) { described_class.new(config, context) }

  before do
    # stubbing this so we don't litter this repo with useless template files /
    # configurations
    hook.stub(:set_commit_template)
    allow(Overcommit::Utils).to receive_message_chain(:log, :debug)
    allow(Overcommit::GitRepo).to receive(:current_branch).and_return(new_head)
  end

  let(:new_head) { 'userbeforeid-12345-branch-description' }

  describe '#run' do
    context 'when the checked out branch matches the pattern' do
      it { is_expected.to pass }

      context 'template contents' do
        subject(:template) { hook.new_template }

        before do
          hook.stub(:replacement_text).and_return('Id is: \1')
        end

        it { is_expected.to eq('Id is: 12345') }
      end
    end

    context 'when the checked out branch does not match the pattern' do
      let(:new_head) { "this shouldn't match the default pattern" }

      it { is_expected.to warn }
    end
  end

  describe '#replacement_text' do
    subject(:replacement_text) { hook.replacement_text }
    let(:replacement_template_file) { 'valid_filename.txt' }
    let(:replacement) { 'Id is: \1' }

    context 'when the replacement text points to a valid filename' do
      before do
        hook.stub(:replacement_text_config).and_return(replacement_template_file)
        File.stub(:exists?).and_return(true)
        File.stub(:read).with(replacement_template_file).and_return(replacement)
      end

      describe 'it reads it as the replacement template' do
        it { is_expected.to eq(replacement) }
      end
    end
  end
end
