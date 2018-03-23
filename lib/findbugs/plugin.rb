module Danger
  # Checks on your gradle project's Java source files.
  # This is done using [finbugs](http://findbugs.sourceforge.net/)
  # Results are passed out as tables in markdown.
  #
  # @example Running Findbugs with its basic configuration
  #
  #          findbugs.report
  #
  # @example Running Findbugs with a specific gradle task or report_file
  #
  #          findbugs.gradle_task = "app:findbugs" #defalut: findbugs
  #          findbugs.report_file = "app/build/reports/findbugs/findbugs.xml"
  #          findbugs.report
  #
  # @see kazy1991/danger-findbugs
  # @tags android, findbugs

  class DangerFindbugs < Plugin
    require_relative './bug_issue'

    # Custom gradle module to run.
    # This is useful when your project has different flavors.
    # Defaults to "app".
    # @return [String]
    attr_writer :gradle_module
    # Custom gradle task to run.
    # This is useful when your project has different flavors.
    # Defaults to "findbugs".
    # @return [String]
    attr_writer :gradle_task
    # Location of report file
    # If your findbugs task outputs to a different location, you can specify it here.
    # Defaults to "build/reports/findbugs_report.xml".
    # @return [String]
    attr_writer :report_file
    # Custom gradle project directory.
    # Defaults is repository's root directory.
    # @return [String]
    attr_accessor :gradle_project
    def gradle_project
      return @gradle_project || ''
    end

    GRADLEW_NOT_FOUND = "Could not find `gradlew` inside current directory"
    REPORT_FILE_NOT_FOUND = "Findbugs report not found"

    # Calls findbugs task of your gradle project.
    # It fails if `gradlew` cannot be found inside current directory.
    # It fails if `report_file` cannot be found inside current directory.
    # @return [void]
    #

    def report(inline_mode = true)
      return fail(GRADLEW_NOT_FOUND) unless gradlew_exists?
      exec_gradle_task
      return fail(REPORT_FILE_NOT_FOUND) unless report_file_exist?

      if inline_mode
        send_inline_comment
      else
        # TODO not implemented
      end
    end

    # A getter for `gradle_module`, returning "app" if value is nil.
    # @return [String]
    def gradle_module
      @gradle_module ||= 'app'
    end

    # A getter for `gradle_task`, returning "findbugs" if value is nil.
    # @return [String]
    def gradle_task
      @gradle_task  ||= 'findbugs'
    end

    # A getter for `report_file`, returning "build/reports/findbugs_report.xml" if value is nil.
    # @return [String]
    def report_file
      @report_file ||= 'build/reports/findbugs_report.xml'
    end

    private

    # A getter for current updated files
    # @return [Array[String]]
    def target_files
      @target_files ||= (git.modified_files - git.deleted_files) + git.added_files
    end

    # Run gradle task
    # @return [void]
    def exec_gradle_task
      if gradle_project != ''
        "export DANGER_TMP=$PWD"
        "cd #{gradle_project}"
      end
      system "./gradlew #{gradle_task}"
      if gradle_project != ''
        "cd DANGER_TMP"
      end
    end

    # Check gradlew file exists in current directory
    # @return [Bool]
    def gradlew_exists?
      `ls #{gradle_project}gradlew`.strip.empty? == false
    end

    # Check report_file exists in current directory
    # @return [Bool]
    def report_file_exist?
      File.exists?("#{gradle_project}#{report_file}")
    end

    # A getter for `gradle_task`, returning "findbugs" if value is nil.
    # @return [Oga::XML::Document]
    def findbugs_report
      require 'oga'
      @findbugs_report ||= Oga.parse_xml(File.open("#{gradle_project}#{report_file}"))
    end

    # A getter for `gradle_task`, returning "findbugs" if value is nil.
    # @return [Array[BugIssue]]
    def bug_issues
      @bug_issues ||= findbugs_report.xpath("//BugInstance").map do |buginfo|
        BugIssue.new(gradle_module, buginfo)
      end
    end

    # Send inline comment with danger's warn or fail method
    #
    # @return [void]
    def send_inline_comment
      bug_issues.each do |issue|
        filename = "#{gradle_project}#{issue.absolute_path}"
        next unless target_files.include? filename
        send(issue.type, issue.description, file: filename, line: issue.line)
      end
    end
  end
end
