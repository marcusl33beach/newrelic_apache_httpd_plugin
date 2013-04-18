#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "newrelic_plugin"
require "net/http"

#
#
# The entire agent should be enclosed in a "ApacheHTTPDAgent" module
#
module ApacheHTTPDAgent
  #
  # Agent, Metric and PollCycle classes
  #
  # Each agent module must have an Agent, Metric and PollCycle class that
  # inherits from their
  # Component counterparts as you can see below.
  #
  class Agent < NewRelic::Plugin::Agent::Base

    agent_config_options :hostname, :username, :password, :hostport, :agent_name, :extended_stats, :debug, :testrun
    agent_guid "com.newrelic.examples.apache.httpd"
    agent_version "0.0.2"
    #
    # Each agent class must also include agent_human_labels. agent_human_labels
    # requires:
    # A friendly name of your component to appear in graphs.
    # A block that returns a friendly name for this instance of your component.

    # The block runs in the context of the agent instance.
    #
    if !"#{:hostport}".empty? then agent_human_labels("ApacheHTTPD") { "#{hostname}:#{hostport}" }
    else agent_human_labels("ApacheHTTPD") { "#{hostname}" } end

    def setup_metrics
      if !self.hostport then self.hostport = 80 end
        
      @apache_stat_url = URI.parse("http://#{self.hostname}:#{self.hostport}/server-status?auto")
      @apache_stat_extended_url = URI.parse("http://#{self.hostname}:#{self.hostport}/server-status")
      @apache_stat_file = "samples/apachestats-example.txt"
      @apache_stat_extended_file = "samples/apachestats-example.html"

      @metric_types = Hash.new("ms")
      @metric_types["Total Accesses"] = "accesses"
      @metric_types["Total kBytes"] = "kb"
      @metric_types["CPULoad"] = "%"
      @metric_types["Uptime"] = "sec"
      @metric_types["ReqPerSec"] = "requests"
      @metric_types["BytesPerSec"] = "bytes/sec"
      @metric_types["BytesPerReq"] = "bytes/req"
      @metric_types["BusyWorkers"] = "workers"
      @metric_types["IdleWorkers"] = "workers"
      @metric_types["ConnsTotal"] = "connections"
      @metric_types["ConnsAsyncWriting"] = "connections"
      @metric_types["ConnsAsyncKeepAlive"] = "connections"
      @metric_types["ConnsAsyncClosing"] = "connections"
      @metric_types["Scoreboard/WaitingForConnection"] = "workers"
      @metric_types["Scoreboard/StartingUp"] = "workers"
      @metric_types["Scoreboard/ReadingRequest"] = "workers"
      @metric_types["Scoreboard/SendingReply"] = "workers"
      @metric_types["Scoreboard/KeepAliveRead"] = "workers"
      @metric_types["Scoreboard/DNSLookup"] = "workers"
      @metric_types["Scoreboard/ClosingConnection"] = "workers"
      @metric_types["Scoreboard/Logging"] = "workers"
      @metric_types["Scoreboard/GracefullyFinishing"] = "workers"
      @metric_types["Scoreboard/IdleCleanupOfWorker"] = "workers"
      @metric_types["Scoreboard/OpenSlotWithNoCurrentProcess"] = "workers"

      @scoreboard_values = Hash.new("NotDefined")
      @scoreboard_values["_"] = "WaitingForConnection"
      @scoreboard_values["S"] = "StartingUp"
      @scoreboard_values["R"] = "ReadingRequest"
      @scoreboard_values["W"] = "SendingReply"
      @scoreboard_values["K"] = "KeepAliveRead"
      @scoreboard_values["D"] = "DNSLookup"
      @scoreboard_values["C"] = "ClosingConnection"
      @scoreboard_values["L"] = "Logging"
      @scoreboard_values["G"] = "GracefullyFinishing"
      @scoreboard_values["I"] = "IdleCleanupOfWorker"
      @scoreboard_values["."] = "OpenSlotWithNoCurrentProcess"

      @extended_metrics = Array.new
      @extended_metrics << { table: "SSLCache", number: 0, name: "CacheType", type: "string" }
      @extended_metrics << { table: "SSLCache", number: 1, name: "SharedMemory", type: "bytes" }
      @extended_metrics << { table: "SSLCache", number: 2, name: "CurrentEntries", type: "entries" }
      @extended_metrics << { table: "SSLCache", number: 3, name: "Subcaches", type: "subcaches" }
      @extended_metrics << { table: "SSLCache", number: 4, name: "IndexesPerSubCache", type: "indexes" }
      @extended_metrics << { table: "SSLCache", number: 5, name: "TimeLeftOnOldestEntriesObjects", type: "sec" }
      @extended_metrics << { table: "SSLCache", number: 6, name: "IndexUsage", type: "uses" }
      @extended_metrics << { table: "SSLCache", number: 7, name: "CacheUsage", type: "uses" }
      @extended_metrics << { table: "SSLCache", number: 8, name: "TotalEntriesStored", type: "entries" }
      @extended_metrics << { table: "SSLCache", number: 9, name: "TotalEntriesReplaced", type: "entries" }
      @extended_metrics << { table: "SSLCache", number: 10, name: "TotalEntriesExpired", type: "entries" }
      @extended_metrics << { table: "SSLCache", number: 11, name: "TotalEntriesScrolledOut", type: "entries" }
      @extended_metrics << { table: "SSLCache", number: 12, name: "TotalRetrievesHit", type: "hits" }
      @extended_metrics << { table: "SSLCache", number: 13, name: "TotalRetrievesMiss", type: "misses" }
      @extended_metrics << { table: "SSLCache", number: 14, name: "TotalRemovesHit", type: "hits" }
      @extended_metrics << { table: "SSLCache", number: 15, name: "TotalRemovesMis", type: "misses" }
      @sslarray = ["CacheType"]

      @extended_metrics << { table: "Requests", number: 0, name: "ChildServerNumber", type: "string" }
      @extended_metrics << { table: "Requests", number: 1, name: "PID", type: "string" }
      @extended_metrics << { table: "Requests", number: 2, name: "AccessesThisConnection", type: "accesses" }
      @extended_metrics << { table: "Requests", number: 3, name: "AccessesThisChild", type: "accesses" }
      @extended_metrics << { table: "Requests", number: 4, name: "AccessesThisSlot", type: "accesses" }
      @extended_metrics << { table: "Requests", number: 5, name: "WorkerModeOfOperation", type: "workers" }
      @extended_metrics << { table: "Requests", number: 6, name: "CPUUsage", type: "sec" }
      @extended_metrics << { table: "Requests", number: 7, name: "SecSinceLastRequest", type: "sec" }
      @extended_metrics << { table: "Requests", number: 8, name: "LastRequestProcessTime", type: "ms" }
      @extended_metrics << { table: "Requests", number: 9, name: "KilobytesTransferredThisConnection", type: "kb" }
      @extended_metrics << { table: "Requests", number: 10, name: "MegabytesTransferredThisChild", type: "mb" }
      @extended_metrics << { table: "Requests", number: 11, name: "MegabytesTransferredThisSlot", type: "mb" }
      @extended_metrics << { table: "Requests", number: 12, name: "ClientIP", type: "string" }
      @extended_metrics << { table: "Requests", number: 13, name: "VHost", type: "string" }
      @extended_metrics << { table: "Requests", number: 14, name: "RequestContents", type: "string" }
      @reqarray = ["PID", "VHost"]

      @extended_metrics << { table: "WebServers", number: 0, name: "PID", type: "string" }
      @extended_metrics << { table: "WebServers", number: 1, name: "ConnectionsTotal", type: "connections" }
      @extended_metrics << { table: "WebServers", number: 2, name: "ConnectionsAccepting", type: "boolean" }
      @extended_metrics << { table: "WebServers", number: 3, name: "ThreadsBusy", type: "threads" }
      @extended_metrics << { table: "WebServers", number: 4, name: "ThreadsIdle", type: "threads" }
      @extended_metrics << { table: "WebServers", number: 5, name: "AsyncConnsWriting", type: "connections" }
      @extended_metrics << { table: "WebServers", number: 6, name: "AsyncConnsKeepAlive", type: "connections" }
      @extended_metrics << { table: "WebServers", number: 7, name: "AsyncConnsClosing", type: "connections" }
      @wsarray = ["PID"]

    end

    def poll_cycle
      apache_httpd_stats()  
      if "#{extended_stats}" == "true"
        if "#{debug}" == "true" then puts("Reporting Extended Stats") end
        apache_httpd_extended_stats()
      end
      # Only do testruns once, then quit
      if "#{testrun}" == "true" then exit end
    end

    private

    def apache_httpd_stats
      lines = get_stats @apache_stat_url, @apache_stat_file
      if lines.empty? then return end

      stats = Hash.new
      lines.each { |line|
        marray = line.split(": ")
        if marray[0] == "Scoreboard"
          @scoreboard_values.each { |sk, sv|
            mcount = marray[1].count sk
            sn = "#{marray[0]}/#{sv}"
            stats[sn] = mcount
          }
        else
          stats["#{marray[0]}"] = marray[1]
        end
      }

      if !stats.empty? then process_stats stats end
    end

    def apache_httpd_extended_stats
      @workers = Hash.new
      line1 = line2 = line3 = nil
      stats = Hash.new

      lines = get_stats @apache_stat_extended_url, @apache_stat_extended_file
      if lines.empty? then return end

      lines.each { |line|

        ### Web Servers (by PID) Table
        # 1: PID
        # 2: Connections Total
        # 3: Connections Accepting (yes/no)
        # 4: Threads Busy
        # 5: Threads Idle
        # 6: AsyncConns Writing
        # 7: AsyncConns Keep-Alive
        # 8: AsyncConns Closing
        pidsmatch = line.match(/\<tr\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\w+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<\/tr\>/)
        if !pidsmatch.nil? then process_extended_stats(pidsmatch.captures, "WebServers", @wsarray)
        next end

        ### VHosts Seconds Since Last Used Table
        # 1. VHost & Port
        # 2: Seconds Since Last Used
        secmatch = line.match(/\<tr\>\<td\>\<pre\>([^<]+)\<\/pre\>\<\/td\>\<td\>\<pre\>\s*(\d+)\<\/pre\>\<\/td\>\<\/tr\>/)
        if !secmatch.nil? then report_metric_check_debug "HTTPD/VHosts/#{secmatch[1]}/SecondsSinceLastUsed", "sec", secmatch[2]
        next end

        ### SSL Cache Table
        # This table is multiple lines in the page but is in 1 line in the HTML, hence the horrifically long regex
        # 1: Cache Type (this is a string)
        # 2: Shared Memory (bytes)
        # 3: Current Entries
        # 4: Subcaches
        # 5: Indexes Per Subcache
        # 6: Time left on oldest entries' objects (average - seconds)
        # 7: Index Usage
        # 8: Cache Usage
        # 9: total entries stored since starting
        # 10: total entries replaced since starting
        # 11: total entries expired since starting
        # 12: total (pre-expiry) entries scrolled out of the cache
        # 13: total retrieves since starting (hit)
        # 14: total retrieves since starting (miss)
        # 15: total removes since starting (hit)
        # 16: total removes since starting (miss)
        sslmatch = line.match(/[^<]+\<b\>([^<]+)\<\/b\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<br\>[^<]+\<b\>(\d+)%\<\/b\>[^<]+\<b\>(\d+)%\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<br\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<b\>(\d+)<\/b\>[^<]+\<br\>\<\/td\>\<\/tr\>/)
        if !sslmatch.nil? then process_extended_stats(sslmatch.captures, "SSLCache", @sslarray)
        next end

        ### Requests Table
        # This appears as 3 lines in the HTML code itself, although it is 1 line in the table
        # As 3 consectuive lines must match to be used, all other matching will occur above this.
        # For 2nd grouping in line 1 (PID), only look for numbers, ignore "-", thus will only report live servers (with a PID)
        #line1[1]: Child Server number - generation
        #line1[2]: OS process ID
        #line1[3]: Number of accesses - this connection
        #line1[4]: Number of accesses - this child
        #line1[5]: Number of accesses - this slot
        #line1[6]: Worker mode of operation
        #line2[1]: CPU usage, number of seconds
        #line2[2]: Seconds since beginning of most recent request
        #line2[3]: Milliseconds required to process most recent request
        #line2[4]: Kilobytes transferred this connection
        #line2[5]: Megabytes transferred this child
        #line2[6]: Total megabytes transferred this slot
        #line3[1]: Client IP (if available)
        #line3[2]: Virtual Host & Port (if available)
        #line3[3]: Request Contents (if available)
        if line1.nil? then line1 = line.match(/\<tr\>\<td\>\<b\>([0-9\-]+)<\/b><\/td><td>(\d+)<\/td><td>(\d+)\/(\d+)\/(\d+)<\/td><td>([_SRWKDCLGI.]+)/)
        elsif line2.nil? then line2 = line.match(/\<\/td\>\<td\>([0-9.]+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>([0-9.]+)\<\/td\>\<td\>([0-9.]+)\<\/td\>\<td\>([0-9.]+)/)
        elsif line3.nil? then line3 = line.match(/<\/td><td>(\d+\.\d+\.\d+\.\d+)<\/td><td[^>]*>([a-zA-Z0-9.:]*)<\/td><td[^>]*>(.*)<\/td><\/tr>/) end

        if !line1.nil? && !line2.nil? && !line3.nil?
          # Concatenate all 3 match lines into one big array to process/report.
          reqmatch = line1.captures.concat(line2.captures.concat(line3.captures))
          process_extended_stats(reqmatch, "Requests", @reqarray)
          # Clear contents of 3 line matches after they've been processed
          line1 = line2 = line3 = nil
        end
      }
      if !@workers.empty? then @workers.each { |wk, wv| report_metric_check_debug wk, "workers", wv } end
    end
    
    def process_stats(statshash) 
      statshash.each_key { |mtree|
        mout = "HTTPD"
        if "#{mtree}".start_with?("Scoreboard")
          mout = "#{mout}/#{mtree}"
        elsif @metric_types[mtree] == "workers"
          mout = "#{mout}/Workers/#{mtree}"
        elsif @metric_types[mtree] == "connections"
          mout = "#{mout}/Connections/#{mtree}"
        elsif @metric_types[mtree] == "%"
          statshash[mtree] = 100 * statshash[mtree].to_f
          mout = "#{mout}/#{mtree}"
        else
          mout = "#{mout}/#{mtree}"
        end
        report_metric_check_debug "#{mout}", "#{@metric_types[mtree]}", statshash[mtree]
      }
    end
    
    def process_extended_stats(statsarray, statstablename, titlearray)
      statsout = Hash.new
      statbase = "HTTPD/#{statstablename}"
      titlearray.each{ |t|
        mindex = @extended_metrics.detect { |m| m[:table] == "#{statstablename}" && m[:name] == "#{t}"}
        if !mindex.nil?
          if "#{statsarray[mindex[:number]]}" == "" then statbase = statbase + "/No" + "#{t}"
          else statbase = statbase + "/" + "#{statsarray[mindex[:number]]}" end
        end
      }
      statsarray.each_index { |i|
        thisstat = @extended_metrics.detect { |s| s[:table] == "#{statstablename}" && s[:number] == i}
        if "#{thisstat[:type]}" == "workers"
          workerstring = "#{statbase}/#{thisstat[:name]}/#{@scoreboard_values["#{statsarray[i]}"]}"
          if @workers[workerstring].nil? then @workers[workerstring] = 1
          else @workers[workerstring] = @workers[workerstring] + 1 end
        elsif "#{thisstat[:type]}" != "string" then report_metric_check_debug "#{statbase}/#{thisstat[:name]}", "#{thisstat[:type]}", statsarray[i] end
      }
    end

    def report_metric_check_debug(metricname, metrictype, metricvalue)
      if "#{metrictype}" == "boolean"
        if "#{metricvalue}" == "yes" then metricvalue = "1"
        else metricvalue = "0"
        end
      end
      if "#{self.debug}" == "true"
        puts("#{metricname}[#{metrictype}] : #{metricvalue}")
      else
        report_metric metricname, metrictype, metricvalue
      end
    end

    def get_stats(staturl, statfile)
      lines = Array.new
      begin
        if "#{self.testrun}" == "true"
          flines = File.open(statfile, "r")
          flines.each {|l| lines << l}
        flines.close
        else
          if "#{self.debug}" == "true" then puts("URL: #{staturl}") end
          resp = ::Net::HTTP.get_response(staturl)
          data = resp.body
          lines = data.split("\n")
        end
      rescue => e
        $stderr.puts "#{e}: #{e.backtrace.join("\n  ")}"
      end
      return lines
    end
  end

  NewRelic::Plugin::Setup.install_agent :apachehttpd, self

  # Launch the agent; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run

end
