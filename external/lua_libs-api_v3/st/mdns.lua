-- Copyright (c) 2022 SmartThings.
local mdns_rpc = _envlibrequire("mdns")

--- @class mdns
local mdns = {}

--- @class ServiceInfo
--- @field public name string the informational name of the service record
--- @field public service_type string the service type, which should match the one passed in during the query
--- @field public domain string the domain on which the service is located, which should match the one passed in during the query
local ServiceInfo = {}

--- @class HostInfo
--- @field public name string The hostname on the domain.
--- @field public address string The IP address as a string at which the host can be reached.
--- @field public port integer The port number as an integer for the service on the host
local HostInfo = {}

--- @class RawTxtRecord
--- @field public text string[] an array of raw byte strings. Each element in the array represents a record in its entirety as a single byte string; this means that for key-value type records, the string has the entire <key=value> contents as a single item.
local RawTxtRecord = {}

--- @class ServiceDiscoveryEvent
--- @field private iface_info table
--- @field public service_info ServiceInfo
--- @field public host_info HostInfo
--- @field public txt RawTxtRecord
local ServiceDiscoveryEvent = {}

--- @class ServiceDiscoveryResponse
--- All responses to a service discovery request.
---
--- @see ServiceDiscoveryEvent
---
--- @field public found ServiceDiscoveryEvent[] Information about found hosts for the given service type
local ServiceDiscoveryResponse = {}

--- Perform mdns/DNS-SD discovery for service types on the given domain.
---
--- Service types in a search query are often prefixed with underscores by
--- convention to avoid collisions with existing hostnames.
---
--- For network services, they are often composed of two parts:
--- The unique service name, followed by a dot, and then the underlying
--- transport protocol being used. For example, the Philips Hue bridge
--- advertises itself as the "hue" service, and because it's a REST API it
--- goes over TCP. As such, to search for Hue bridges on the local domain,
--- you should use `_hue._tcp` as the service name, and `local` as the domain.
--- Another example would be Apple's AirPlay service, which is also TCP-backed
--- and advertises itself as "airplay", meaning the search term would use
--- `_airplay._tcp` on the local domain (again noting the underscores).
---
--- Replies to the query should be a deduplicated list of responses; however,
--- if a service supports IPv4 and IPv6 you may receive multiple responses
--- for the same host name, one for each interface. The host_info portion of
--- the response has helper methods `:is_valid_ipv4()` and `:is_valid_ipv6()`
--- to help work with this.
---
--- Philips Hue discover example:
--- ```
---     local discover_responses = mdns.discover("_hue._tcp", "local") or {} -- scan for Hue bridges on the local network
---
---     for idx, found in ipairs(discover_responses.found) do
---         -- sanity check that the answer contains a response to the correct service type, and we only want to process ipv4
---         if answer ~= nil and answer.service_info.name == "_hue._tcp" and answer.host_info:is_valid_ipv4() then
---             -- process answer
---         end
---     end
--- ```
---
--- @param service_type string the service type to search for hosts on
--- @param domain string the domain to search for hosts on
--- @return ServiceDiscoveryResponse|nil the response to the query, or nil if there was an error.
--- @return nil|string error message if any
function mdns.discover(service_type, domain)
  return mdns_rpc.discover(service_type, domain)
end

--- Resolve the IP address needed to interact with a service given the host name, service type,
--- and domain. Note that "resolve" in the context of DNS Service Discovery over mDNS can refer
--- to resolving a PTR record to an SRV record, or refer to resolving an SRV record to an A/AAAA record.
--- What this API does is:
---
---   - Given a hostname and a service type, find all of the A/AAAA records that resolve the `host`
---     argument by performing a browse for the given service type and following the PTR and SRV
---     records to find all of the relevant hostnames.
---
--- If you don't know the specific host name of the host providing the service, the `discover` API
--- will instead perform browse for the given service type and return all of the SRV,PTR,TXT, and
--- A/AAAA record information for all responders for that service on the given domain.
---
--- @see mdns.discover
---
--- @param host string the hostname to resolve
--- @param service_type string the service type to search for hosts on
--- @param domain string the domain to search for hosts on
--- @return HostInfo[]|nil the response to the query, or nil if there was an error.
--- @return nil|string error message if any
function mdns.resolve(host, service_type, domain)
  local browse, err = mdns.discover(service_type, domain)
  if err ~= nil then return browse, err end

  local resolved = {}
  if not (browse and browse.found and #(browse.found) > 0) then return resolved end

  for _, event in ipairs(browse.found) do
    local base_hostname = event.host_info.name:sub(1, -(#("." .. domain) + 1))
    if event.service_info.service_type == service_type and event.service_info.domain == domain and
        (event.host_info.name == host or base_hostname == host) then
      table.insert(resolved, event.host_info)
    end
  end

  return resolved
end

return mdns
