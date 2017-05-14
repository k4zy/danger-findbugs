require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerFindbugs do
    it 'should be a plugin' do
      expect(Danger::DangerFindbugs.new(nil)).to be_a Danger::Plugin
    end

    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.findbugs
      end

      it "Check default report file path" do
        expect(@my_plugin.report_file).to eq('build/reports/findbugs_report.xml')
      end

      it "Set custom report file path" do
        custom_report_path = 'custom/findbugs_report.xml'
        @my_plugin.report_file = custom_report_path
        expect(@my_plugin.report_file).to eq(custom_report_path)
      end

      it "Check default gradle module" do
        expect(@my_plugin.gradle_module).to eq('app')
      end

      it "Set custom gradle module" do
        my_module = 'custom_module'
        @my_plugin.gradle_module = my_module
        expect(@my_plugin.gradle_module).to eq(my_module)
      end

      it "Check default gradle task" do
        expect(@my_plugin.gradle_task).to eq('findbugs')
      end

      it "Set custom gradle module" do
        custom_task = 'findbugsStagingDebug'
        @my_plugin.gradle_task = custom_task
        expect(@my_plugin.gradle_task).to eq(custom_task)
      end

      it "Create bug issues" do
        custom_report_path = 'spec/fixtures/findbugs_report.xml'
        @my_plugin.report_file = custom_report_path
        expect(@my_plugin.bug_issues).not_to be_nil
      end

      it "Send inline comments" do
        Danger::DangerFindbugs.any_instance.stub(:target_files).and_return([])
        custom_report_path = 'spec/fixtures/findbugs_report.xml'
        @my_plugin.report_file = custom_report_path
        expect(@my_plugin.send_inline_comment).not_to be_nil
      end

    end
  end
end
