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
    if !:hostport.empty? then agent_human_labels("ApacheHTTPD") { "#{hostname}:#{hostport}" }
    else agent_human_labels("ApacheHTTPD") { hostname } end

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

      @extended_metric_types = Hash.new("ms")
      @extended_metric_types["AccessesThisChild"] = "accesses"
      @extended_metric_types["AccessesThisConnection"] = "accesses"
      @extended_metric_types["AccessesThisSlot"] = "accesses"
      @extended_metric_types["AsyncConnsClosing"] = "connections"
      @extended_metric_types["AsyncConnsKeepAlive"] = "connections"
      @extended_metric_types["AsyncConnsWriting"] = "connections"
      @extended_metric_types["CacheType"] = "string"
      @extended_metric_types["CacheUsage"] = "uses"
      @extended_metric_types["ChildServerNumber"] = "string"
      @extended_metric_types["ClientIP"] = "string"
      @extended_metric_types["ConnectionsAccepting"] = "boolean"
      @extended_metric_types["ConnectionsTotal"] = "connections"
      @extended_metric_types["CPUUsage"] = "sec"
      @extended_metric_types["CurrentEntries"] = "entries"
      @extended_metric_types["IndexesPerSubCache"] = "indexes"
      @extended_metric_types["IndexUsage"] = "uses"
      @extended_metric_types["KilobytesTransferredThisConnection"] = "kb"
      @extended_metric_types["LastRequestProcessTime"] = "ms"
      @extended_metric_types["MegabytesTransferredThisChild"] = "mb"
      @extended_metric_types["MegabytesTransferredThisSlot"] = "mb"
      @extended_metric_types["PID"] = "string"
      @extended_metric_types["RequestContents"] = "string"
      @extended_metric_types["SecSinceLastRequest"] = "sec"
      @extended_metric_types["SharedMemory"] = "bytes"
      @extended_metric_types["Subcaches"] = "subcaches"
      @extended_metric_types["ThreadsBusy"] = "threads"
      @extended_metric_types["ThreadsIdle"] = "threads"
      @extended_metric_types["TimeLeftOnOldestEntriesObjects"] = "sec"
      @extended_metric_types["TotalEntriesExpired"] = "entries"
      @extended_metric_types["TotalEntriesReplaced"] = "entries"
      @extended_metric_types["TotalEntriesScrolledOut"] = "entries"
      @extended_metric_types["TotalEntriesStored"] = "entries"
      @extended_metric_types["TotalRemovesHit"] = "hits"
      @extended_metric_types["TotalRemovesMis"] = "misses"
      @extended_metric_types["TotalRetrievesHit"] = "hits"
      @extended_metric_types["TotalRetrievesMiss"] = "misses"
      @extended_metric_types["VHost"] = "string"
      @extended_metric_types["WorkerModeOfOperation"] = "workers"

      @ssl_metrics=["CacheType", "SharedMemory", "CurrentEntries", "Subcaches", "IndexesPerSubCache", "TimeLeftOnOldestEntriesObjects", "IndexUsage", "CacheUsage", "TotalEntriesStored", "TotalEntriesReplaced", "TotalEntriesExpired", "TotalEntriesScrolledOut", "TotalRetrievesHit", "TotalRetrievesMiss", "TotalRemovesHit", "TotalRemovesMiss"]
      @req_metrics=["ChildServerNumber", "PID", "AccessesThisConnection", "AccessesThisChild", "AccessesThisSlot", "WorkerModeOfOperation", "CPUUsage", "SecSinceLastRequest", "LastRequestProcessTime", "KilobytesTransferredThisConnection", "MegabytesTransferredThisChild", "MegabytesTransferredThisSlot", "ClientIP", "VHost", "RequestContents"]
      @ws_metrics=["PID", "ConnectionsTotal", "ConnectionsAccepting", "ThreadsBusy", "ThreadsIdle", "AsyncConnsWriting", "AsyncConnsKeepAlive", "AsyncConnsClosing"]
    end

    def poll_cycle
      apache_httpd_stats()
      if "#{self.extended_stats}" == "true"
        if "#{self.debug}" == "true" then puts("Reporting Extended Stats") end
        apache_httpd_extended_stats()
      end
      # Only do testruns once, then quit
      if "#{self.testrun}" == "true" then exit end
    end

    private

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
          stats[marray[0]] = marray[1]
        end
      }

      if !stats.empty? then process_stats stats end
    end

    def apache_httpd_extended_stats
      line1 = line2 = line3 = nil
      wsstats = Array.new
      sslstats = Array.new
      reqstats = Array.new

      lines = get_stats @apache_stat_extended_url, @apache_stat_extended_file
      if lines.empty? then return end

      lines.each { |line|

      ### VHosts Seconds Since Last Used Table
      # 1. VHost & Port
      # 2: Seconds Since Last Used
        secmatch = line.match(/\<tr\>\<td\>\<pre\>([^<]+)\<\/pre\>\<\/td\>\<td\>\<pre\>\s*(\d+)\<\/pre\>\<\/td\>\<\/tr\>/)
        if !secmatch.nil? then report_metric_check_debug "HTTPD/VHosts/#{secmatch[1]}/SecondsSinceLastUsed", "sec", secmatch[2]
        next end

        ### Web Servers (by PID) Table
        # 0: PID
        # 1: Connections Total
        # 2: Connections Accepting (yes/no)
        # 3: Threads Busy
        # 4: Threads Idle
        # 5: AsyncConns Writing
        # 6: AsyncConns Keep-Alive
        # 7: AsyncConns Closing
        pidsmatch = line.match(/\<tr\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\w+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<\/tr\>/)
        if !pidsmatch.nil? then wsstats << pidsmatch.captures
        # process_extended_stats(pidsmatch.captures, "WebServers", @wsarray)
        next end

        ### SSL Cache Table
        # This table is multiple lines in the page but is in 1 line in the HTML,
        # hence the horrifically long regex
        # 0: Cache Type (this is a string)
        # 1: Shared Memory (bytes)
        # 2: Current Entries
        # 3: Subcaches
        # 4: Indexes Per Subcache
        # 5: Time left on oldest entries' objects (average - seconds)
        # 6: Index Usage
        # 7: Cache Usage
        # 8: total entries stored since starting
        # 9: total entries replaced since starting
        # 10: total entries expired since starting
        # 11: total (pre-expiry) entries scrolled out of the cache
        # 12: total retrieves since starting (hit)
        # 13: total retrieves since starting (miss)
        # 14: total removes since starting (hit)
        # 15: total removes since starting (miss)
        sslmatch = line.match(/[^<]+\<b\>([^<]+)\<\/b\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<br\>[^<]+\<b\>(\d+)%\<\/b\>[^<]+\<b\>(\d+)%\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>\<br\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<br\>[^<]+\<b\>(\d+)\<\/b\>[^<]+\<b\>(\d+)<\/b\>[^<]+\<br\>\<\/td\>\<\/tr\>/)
        if !sslmatch.nil? then sslstats << sslmatch.captures
        #process_extended_stats(sslmatch.captures, "SSLCache", @sslarray)
        next end

        ### Requests Table
        # This appears as 3 lines in the HTML code itself, although it is 1 line
        # in the table
        # As 3 consectuive lines must match to be used, all other matching will
        # occur above this.
        # For 2nd grouping in line 1 (PID), only look for numbers, ignore "-",
        # thus will only report live servers (with a PID)
        # 0: line1[1]: Child Server number - generation
        # 1: line1[2]: OS process ID
        # 2: line1[3]: Number of accesses - this connection
        # 3: line1[4]: Number of accesses - this child
        # 4: line1[5]: Number of accesses - this slot
        # 5: line1[6]: Worker mode of operation
        # 6: line2[1]: CPU usage, number of seconds
        # 7: line2[2]: Seconds since beginning of most recent request
        # 8: line2[3]: Milliseconds required to process most recent request
        # 9: line2[4]: Kilobytes transferred this connection
        # 10: line2[5]: Megabytes transferred this child
        # 11: line2[6]: Total megabytes transferred this slot
        # 12: line3[1]: Client IP (if available)
        # 13: line3[2]: Virtual Host & Port (if available)
        # 14: line3[3]: Request Contents (if available)
        if line1.nil? then line1 = line.match(/\<tr\>\<td\>\<b\>([0-9\-]+)<\/b><\/td><td>(\d+)<\/td><td>(\d+)\/(\d+)\/(\d+)<\/td><td>([_SRWKDCLGI.]+)/)
        elsif line2.nil? then line2 = line.match(/\<\/td\>\<td\>([0-9.]+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>(\d+)\<\/td\>\<td\>([0-9.]+)\<\/td\>\<td\>([0-9.]+)\<\/td\>\<td\>([0-9.]+)/)
        elsif line3.nil? then line3 = line.match(/<\/td><td>(\d+\.\d+\.\d+\.\d+)<\/td><td[^>]*>([a-zA-Z0-9.:]*)<\/td><td[^>]*>(.*)<\/td><\/tr>/) end

        if !line1.nil? && !line2.nil? && !line3.nil?
          # Concatenate all 3 match lines into one big array to process/report.
          reqmatch = line1.captures.concat(line2.captures.concat(line3.captures))
          reqstats << reqmatch
          # process_extended_stats(reqmatch, "Requests", @reqarray)
          # Clear contents of 3 line matches after they've been processed
          line1 = line2 = line3 = nil
        end
      }

      if !reqstats.empty? then process_extended_stats reqstats, "Requests", @req_metrics, ["PID", "VHost"] end
      if !sslstats.empty? then process_extended_stats sslstats, "SSLCache", @ssl_metrics, ["CacheType"] end
      if !wsstats.empty? then process_extended_stats wsstats, "WebServers", @ws_metrics, ["PID"] end
    end

    def process_stats(statshash)
      statshash.each_key { |skey|
        statstree = "HTTPD"
        case 
        when skey.start_with?("Scoreboard")
          statstree = "#{statstree}/#{skey}"
        when @metric_types[skey] == "workers"
          statstree = "#{statstree}/Workers/#{skey}"
        when @metric_types[skey] == "connections"
          statstree = "#{statstree}/Connections/#{skey}"
        when @metric_types[skey] == "%"
          statshash[skey] = 100 * statshash[skey].to_f
          statstree = "#{statstree}/#{skey}"
        else
          statstree = "#{statstree}/#{skey}"
        end
        report_metric_check_debug statstree, @metric_types[skey], statshash[skey]
      }
    end

    def process_extended_stats(thesestats, statstablename, statsarray, titlearray)
      workersout = Hash.new
      thesestats.each{|s|
        statbase = "HTTPD/#{statstablename}"
        titlearray.each{ |t|
          t_index = statsarray.index(t)
          if !t_index.nil?
            if s[t_index] == "" then statbase = "#{statbase}/No#{t}"
            else statbase = "#{statbase}/#{s[t_index]}" end
          end
        }
        s.each_index { |s_index|
          stattype = @extended_metric_types[statsarray[s_index]]
          case stattype
          when "workers"
            workerstring = "#{statbase}/#{statsarray[s_index]}/#{@scoreboard_values[s[s_index]]}"
            if workersout[workerstring].nil? then workersout[workerstring] = 1
            else workersout[workerstring] = workersout[workerstring] + 1 end
          when "boolean"
              if s[s_index] == "yes" then s[s_index] = "1"
              else s[s_index] = "0" end
              statname = "#{statbase}/#{statsarray[s_index]}"
              report_metric_check_debug statname, stattype, s[s_index]
          when "string"
            # Do nothing with strings for now.
          else
            statname = "#{statbase}/#{statsarray[s_index]}"
            report_metric_check_debug statname, stattype, s[s_index]
          end
        }
      }

      if !workersout.empty? then workersout.each { |wk, wv| report_metric_check_debug wk, "workers", wv } end
    end

    def report_metric_check_debug(metricname, metrictype, metricvalue)
      if "#{self.debug}" == "true"
        puts("#{metricname}[#{metrictype}] : #{metricvalue}")
      else
        report_metric metricname, metrictype, metricvalue
      end
    end
  end
  
  NewRelic::Plugin::Setup.install_agent :apachehttpd, self

  # Launch the agent; this never returns.
  #
  NewRelic::Plugin::Run.setup_and_run

end
