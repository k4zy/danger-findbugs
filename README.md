# danger-findbugs

Danger plugin for findbugs formatted xml file.

## Installation

    $ gem install danger-findbugs

## Usage
Checks on your gradle project's Java source files.
This is done using [finbugs](http://findbugs.sourceforge.net/)
Results are passed out as tables in markdown.

<blockquote>Running Findbugs with its basic configuration
  <pre>
findbugs.report</pre>
</blockquote>

<blockquote>Running Findbugs with a specific gradle task or report_file
  <pre>
findbugs.gradle_task = "app:findbugs" #defalut: findbugs
findbugs.report_file = "app/build/reports/findbugs/findbugs.xml"
findbugs.report</pre>
</blockquote>

#### Attributes

`gradle_module` - Custom gradle module to run.
This is useful when your project has different flavors.
Defaults to "app".

`gradle_modules` - Custom multiple gradle module to run.
Defaults to "[`gradle_module`]".

`gradle_task` - Custom gradle task to run.
This is useful when your project has different flavors.
Defaults to "findbugs".

`gradle_project` - Custom gradle project directory.
Defaults is repository's root directory.

`report_file` - Location of report file
If your findbugs task outputs to a different location, you can specify it here.
Defaults to "build/reports/findbugs_report.xml".

#### Methods

`report` - Calls findbugs task of your gradle project.
It fails if `gradlew` cannot be found inside current directory.
It fails if `report_file` cannot be found inside current directory.

`target_files` - A getter for current updated files

`exec_gradle_task` - Run gradle task

`gradlew_exists?` - Check gradlew file exists in current directory

`report_file_exist?` - Check report_file exists in current directory

`findbugs_report` - A getter for `gradle_task`, returning "findbugs" if value is nil.

`bug_issues` - A getter for `gradle_task`, returning "findbugs" if value is nil.

`send_inline_comment` - Send inline comment with danger's warn or fail method
