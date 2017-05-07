module Danger
  class DangerFindbugs < Plugin
    attr_accessor :gradle_task
    attr_accessor :report_file

    def report_file
      return @report_file || 'app/build/reports/findbugs/findbugs.xml'
    end

    def report
      unless gradlew_exists?
        fail("Could not find `gradlew` inside current directory")
        return
      end

      system "./gradlew #{gradle_task || 'findbugs'}"

      unless File.exists?(report_file)
        fail("Findbugs report not found at `#{report_file}`. "\
        "Have you forgot to add `xmlReport true` to your `build.gradle` file?")
      end

      issues = read_issues_from_report
      send_inline_comment(issues)
    end

    private

    def read_issues_from_report
      file = File.open(report_file)

      require 'oga'
      report = Oga.parse_xml(file)

      report.xpath('//BugInstance')
    end

    def send_inline_comment (issues)
      target_files = (git.modified_files - git.deleted_files) + git.added_files
      dir = "#{Dir.pwd}/"
      issues.each do |issue|
        # todo
        # next unless target_files.include? filename
        # location = r.xpath('location').first
        # filename = location.get('file').gsub(dir, "")
        # line = (location.get('line') || "0").to_i
        # send("fail", r.get('message'), file: filename, line: line)
      end
    end

    def gradlew_exists?
      `ls gradlew`.strip.empty? == false
    end

  end
end
