#!/usr/bin/perl -T
# nagios: -epn
#
#  Author: Hari Sekhon
#  Date: 2013-06-03 21:43:25 +0100 (Mon, 03 Jun 2013) 
#
#  http://github.com/harisekhon/nagios-plugins
#
#  License: see accompanying LICENSE file
#

$DESCRIPTION = "Nagios Plugin to check the number of Elasticsearch nodes available in a cluster

Tested on Elasticsearch 0.90.1, 1.2.1, 1.4.4";

$VERSION = "0.2";

use strict;
use warnings;
BEGIN {
    use File::Basename;
    use lib dirname(__FILE__) . "/lib";
}
use HariSekhonUtils;
use HariSekhon::Elasticsearch;

$ua->agent("Hari Sekhon $progname version $main::VERSION");

my $cluster;

%options = (
    %hostoptions,
    "C|cluster-name=s" =>  [ \$cluster, "Cluster name to expect (optional). Cluster name is used for auto-discovery and should be unique to each cluster in a single network" ],
    %thresholdoptions,
);
splice @usage_order, 6, 0, qw/cluster-name/;

get_options();

$host    = validate_host($host);
$port    = validate_port($port);
$cluster = validate_elasticsearch_cluster($cluster) if defined($cluster);
validate_thresholds(1, 1, { 'simple' => 'lower', 'positive' => 1, 'integer' => 1});

vlog2;
set_timeout();

$status = "OK";

$json = curl_elasticsearch "/_cluster/health";

my $nodes = get_field_int("number_of_nodes");
plural $nodes;
$msg .= "$nodes node$plural";
check_thresholds($nodes);

my $cluster_name = get_field("cluster_name");
$msg .= " in cluster '$cluster_name'";
check_string($cluster_name, $cluster);
$msg .= " | nodes=$nodes";
msg_perf_thresholds(0, 1);

vlog2;
quit $status, $msg;
