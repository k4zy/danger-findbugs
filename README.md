# danger-findbugs

This is the "FindBugs" plugin for "Danger".

## Installation

    $ gem install danger-findbugs

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `findbugs` namespace.

```ruby
findbugs.gradle_module = "app" # defalut: app
findbugs.gradle_task = "app:findbugs" #defalut: findbugs
findbugs.report_file = "app/build/reports/findbugs/findbugs.xml" #defalut: build/reports/findbugs_report.xml
findbugs.report
```
