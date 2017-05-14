module Danger
  class DangerFindbugs < Plugin
    require 'oga'
    require_relative './bug_issue'

    attr_writer :gradle_module
    attr_writer :gradle_task
    attr_writer :report_file

    GRADLEW_NOT_FOUND = "Could not find `gradlew` inside current directory"
    REPORT_FILE_NOT_FOUND = "Findbugs report not found"

    def report
      return fail(GRADLEW_NOT_FOUND) unless gradlew_exists?
      exec_gradle_task
      return fail(REPORT_FILE_NOT_FOUND) unless report_file_exist?
      send_inline_comment
    end

    def gradle_module
      @gradle_module ||= 'app'
    end

    def gradle_task
      @gradle_task  ||= 'findbugs'
    end

    def report_file
      @report_file ||= 'build/reports/findbugs_report.xml'
    end

    def target_files
      @target_files ||= (git.modified_files - git.deleted_files) + git.added_files
    end

    def exec_gradle_task
      system "./gradlew #{gradle_task}"
    end

    def gradlew_exists?
      `ls gradlew`.strip.empty? == false
    end

    def report_file_exist?
      File.exists?(report_file)
    end

    def findbugs_report
      @findbugs_report ||= Oga.parse_xml(File.open(report_file))
    end

    def bug_issues
      @bug_issues ||= findbugs_report.xpath("//BugInstance").map do |buginfo|
        BugIssue.new(gradle_module, buginfo)
      end
    end

    def send_inline_comment
      bug_issues.each do |issue|
        next unless target_files.include? issue.absolute_path
        send(issue.type, issue.description, file: issue.absolute_path, line: issue.line)
      end
    end
  end
end
