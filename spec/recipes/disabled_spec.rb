require 'spec_helper'

describe 'chef-splunk::disabled' do
  context 'default attributes' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.force_default['splunk']['disabled'] = true
      end.converge(described_recipe)
    end

    context 'splunk is disabled' do
      it 'stops the splunk service' do
        expect(chef_run).to stop_service('splunk')
      end

      it 'uninstalls the splunk and splunkforwarder packages' do
        expect(chef_run).to remove_package(%w(splunk splunkforwarder))
      end

      ['/etc/init.d/splunk', '/etc/systemd/system/splunk.service'].each do |f|
        it "deletes #{f}" do
          expect(chef_run).to delete_file(f)
        end
      end

      it 'does not log debug message' do
        expect(chef_run).to_not write_log('splunk is not disabled')
      end
    end

    context 'splunk is not disabled' do
      let(:message) do
        'The chef-splunk::disabled recipe was added to the node, ' \
        'but the attribute to disable splunk was set to false.'
      end

      it 'logged debug message and returns' do
        expect(chef_run).to_not write_log('splunk is not disabled')
          .with(level: :debug, message: message)
      end
    end
  end

  context 'splunk server attribute is true' do
    context 'splunk server is disabled' do
      let(:chef_run) do
        ChefSpec::ServerRunner.new do |node|
          node.force_default['splunk']['disabled'] = true
          node.force_default['splunk']['is_server'] = true
        end.converge(described_recipe)
      end

      ['/etc/init.d/splunk', '/etc/systemd/system/splunk.service'].each do |f|
        it "deletes #{f}" do
          expect(chef_run).to delete_file(f)
        end
      end
    end
  end
end
